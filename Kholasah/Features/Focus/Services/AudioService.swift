// MARK: - شرح الملف
// يدير تشغيل الملفات الصوتية المحلية والتنقل بينها، ويحسب وقت الاستماع الفعلي لتحديد نهاية الجلسة.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import Foundation
import AVFoundation
import Observation

/// Owns local playback and counts only time spent listening, across track changes.
// يحصر الوصول إلى هذا النوع في الممثل الرئيسي لتنسيق التغييرات المرتبطة بالواجهة.
@MainActor
// يتيح لـ SwiftUI تتبع الخصائص المقروءة وتحديث الأجزاء التي تعتمد عليها عند تغيرها.
@Observable
final class FocusAudioPlayer {
    // أسماء صور المقاطع؛ ترتيبها يطابق ملفات الموسيقى.
    static let artworkNames = ["sandHouse", "khobar", "car", "mountain"]

    // هل الصوت قيد التشغيل؟
    // private(set) يسمح بقراءة القيمة من الخارج، ويقصر تعديلها على هذا النوع.
    private(set) var isPlaying = false
    // فهرس المقطع المحدد داخل قائمة الأصوات.
    private(set) var selectedIndex = 0
    // وقت الاستماع المتراكم بالثواني قبل فترة التشغيل الحالية.
    private(set) var elapsedTime: TimeInterval = 0
    // رسالة تعذر تحميل الصوت أو تشغيله.
    // علامة ? تعني قيمة اختيارية قد تكون nil؛ يجب التحقق منها قبل استخدامها.
    private(set) var playbackError: String?
    // موضع التشغيل الحالي داخل الملف بالثواني.
    private(set) var currentTime: TimeInterval = 0
    // المدة الكاملة للمقطع بالثواني.
    private(set) var duration: TimeInterval = 0

    // خاصية تربط شريط التقدم بموضع الصوت؛ الكتابة فيها تستدعي seek.
    var playbackPosition: TimeInterval {
        get { currentTime }
        set { seek(to: newValue) }
    }

    // الحد الزمني لجلسة الاستماع بالثواني.
    let sessionDuration: TimeInterval

    // مشغل AVAudioPlayer للملف الصوتي الحالي.
    // يستبعد هذا المرجع الداخلي من تتبع Observation؛ لا يلغي دوره في تنفيذ العمليات.
    @ObservationIgnored private var player: AVAudioPlayer?
    // المهمة غير المتزامنة التي تراقب وقت الاستماع.
    @ObservationIgnored private var sessionTask: Task<Void, Never>?
    // وقت بدء فترة التشغيل الحالية اعتمادًا على مدة تشغيل النظام.
    @ObservationIgnored private var startedAt: TimeInterval?

    // اسم صورة المقطع الحالي في موارد التطبيق.
    var artworkName: String { Self.artworkNames[selectedIndex] }

    // المهيئ init يجهز النسخة ويستقبل القيم أو الخدمات اللازمة؛ self تشير إلى النسخة الحالية.
    init(sessionDuration: TimeInterval = 15 * 60) {
        self.sessionDuration = sessionDuration
    }

    // يختار الصوت بحسب صورته؛ إعادة اختيار الصوت الحالي لا تعيد موضعه أو جلسته.
    func select(artworkName: String) {
        // Reopening the current sound preserves its playback position and session.
        if self.artworkName == artworkName, player != nil { return }
        pause()
        player = nil
        elapsedTime = 0
        selectedIndex = Self.artworkNames.firstIndex(of: artworkName) ?? 0
        prepareTrack()
    }

    // يبدأ تشغيل الصوت ويتابع وقت الاستماع حتى بلوغ حد الجلسة.
    func play() {
        // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
        guard !isPlaying else { return }
        if elapsedTime >= sessionDuration {
            elapsedTime = 0
            player?.currentTime = 0
        }
        // يجمع عمليات قد ترمي أخطاء؛ يعالج catch الخطأ بدل إيقاف مسار التطبيق دون معالجة.
        do {
            try loadTrackIfNeeded()
            #if os(iOS) || os(visionOS)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
            guard player?.play() == true else {
                throw CocoaError(.fileReadUnknown)
            }
            playbackError = nil
            isPlaying = true
            startedAt = ProcessInfo.processInfo.systemUptime
            // مرجع weak لا يحتفظ بالكائن بقوة عند إنشاء المهمة؛ guard let يفك المرجع أثناء التنفيذ.
            sessionTask = Task { [weak self] in
                while !Task.isCancelled {
                    do {
                        try await Task.sleep(for: .milliseconds(50))
                    } catch {
                        return
                    }
                    guard let self else { return }
                    self.updatePlaybackTime()
                    if self.player?.isPlaying != true {
                        self.pause()
                        return
                    }
                    if self.listeningTime >= self.sessionDuration {
                        self.pause()
                        self.elapsedTime = self.sessionDuration
                        self.player?.currentTime = 0
                        self.updatePlaybackTime()
                        return
                    }
                }
            }
        } catch {
            playbackError = error.localizedDescription
            pause()
            print("Focus audio could not play: \(error)")
        }
    }

    // يوقف التشغيل مؤقتًا مع الاحتفاظ بالتقدم الحالي.
    func pause() {
        elapsedTime = min(listeningTime, sessionDuration)
        startedAt = nil
        player?.pause()
        updatePlaybackTime()
        isPlaying = false
        sessionTask?.cancel()
        sessionTask = nil
        #if os(iOS) || os(visionOS)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif
    }

    // يبدل بين تشغيل الصوت وإيقافه مؤقتًا حسب الحالة.
    func togglePlayback() {
        if isPlaying { pause() } else { play() }
    }

    // ينقل التشغيل إلى موضع صالح؛ اختيار نهاية المقطع يعيده إلى البداية.
    func seek(to time: TimeInterval) {
        guard let player, duration > 0, time.isFinite else { return }
        // At the end of a looping track, continue from its beginning.
        player.currentTime = time >= duration ? 0 : max(0, time)
        updatePlaybackTime()
    }

    // يعيد موضع الصوت إلى البداية؛ لا يمدد جلسة استماع مكتملة.
    func replay() {
        seek(to: 0)
        // Replay must never reset or extend a completed listening session.
        guard listeningTime < sessionDuration else { return }
        play()
    }

    // ينسخ موضع الصوت ومدته من المشغل إلى الخصائص التي تعرضها الواجهة.
    private func updatePlaybackTime() {
        currentTime = player?.currentTime ?? 0
        duration = player?.duration ?? 0
    }

    // يحمل ملف الموسيقى عند غياب المشغل ويضبط تكراره المستمر.
    private func loadTrackIfNeeded() throws {
        if player == nil {
            let name = "music\(selectedIndex + 1)"
            guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
                throw CocoaError(.fileNoSuchFile)
            }
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.prepareToPlay()
        }
        updatePlaybackTime()
    }

    // يجهز المقطع ويخزن رسالة خطأ إن تعذر تحميله.
    private func prepareTrack() {
        currentTime = 0
        duration = 0
        do {
            try loadTrackIfNeeded()
            playbackError = nil
        } catch {
            playbackError = error.localizedDescription
        }
    }

    // ينتقل إلى المقطع التالي.
    func next() { changeTrack(by: 1) }
    // ينتقل إلى المقطع السابق.
    func previous() { changeTrack(by: -1) }

    // مجموع الوقت المتراكم ووقت الاستماع في فترة التشغيل الحالية.
    private var listeningTime: TimeInterval {
        elapsedTime + (startedAt.map { ProcessInfo.processInfo.systemUptime - $0 } ?? 0)
    }

    // ينتقل بين المقاطع بشكل دائري ويحافظ على حالة التشغيل السابقة.
    private func changeTrack(by offset: Int) {
        let resume = isPlaying
        pause()
        // باقي القسمة % يعيد الفهرس إلى بداية القائمة أو نهايتها عند تجاوز الحدود.
        selectedIndex = (selectedIndex + offset + Self.artworkNames.count) % Self.artworkNames.count
        player = nil
        prepareTrack()
        if resume { play() }
    }
}
