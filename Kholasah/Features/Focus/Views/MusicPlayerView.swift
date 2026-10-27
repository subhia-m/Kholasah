// MARK: - شرح الملف
// واجهة التحكم بالصوت: تشغيل وإيقاف مؤقت وتنقل وإعادة تشغيل وتحريك موضع الاستماع.
// للقراءة: let يثبت القيمة، وvar يسمح بتغييرها، وprivate يحصر الوصول في نطاق التعريف.

import SwiftUI

struct MusicPlayerView: View {
    // العنوان المستخدم لهذا العنصر.
    let title: LocalizedStringKey
    // اسم صورة المقطع الحالي في موارد التطبيق.
    let artworkName: String

    // إجراء من بيئة SwiftUI لإغلاق العرض الحالي بحسب طريقة تقديمه.
    // @Environment يقرأ قيمة أو كائنًا توفره بيئة SwiftUI لهذا العرض.
    @Environment(\.dismiss) private var dismiss
    // مشغل الصوت المشترك الذي تنعكس حالته على الواجهة.
    let audioPlayer: FocusAudioPlayer
    // يمنع إعادة اختيار المقطع في كل ظهور للواجهة.
    // @State حالة تملكها الواجهة وتحافظ SwiftUI عليها بين تحديثاتها؛ الرمز $ يتيح ربطها بعنصر إدخال.
    @State private var hasSelectedTrack = false

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        // يضع العناصر في طبقات متراكبة؛ العناصر اللاحقة تظهر فوق السابقة.
        ZStack {
            AppColors.lightPage
                .ignoresSafeArea()

            // يرتب العناصر عموديًا؛ spacing يحدد المسافة بينها.
            VStack(spacing: 0) {
                MusicPlayerHeader {
                    dismiss()
                }
                    // يضيف مسافة حول العنصر؛ ترتيب معدلات العرض يؤثر في النتيجة.
                    .padding(.bottom, 40)

                MusicArtworkPlaceholder(
                    title: title,
                    imageName: audioPlayer.artworkName
                )
                .padding(.horizontal, 30)

                Spacer(minLength: 40)

                MusicPlaybackControls(
                    isPlaying: audioPlayer.isPlaying,
                    onPlayPause: audioPlayer.togglePlayback,
                    onPrevious: audioPlayer.previous,
                    onNext: audioPlayer.next,
                    onReplay: audioPlayer.replay,
                    audioPlayer: audioPlayer
                )
                    .padding(.horizontal, 52)

                Spacer(minLength: 64)
            }
            .padding(.top, 8)
        }
        .toolbar(.hidden, for: .navigationBar)
        // ينفذ الإجراء عند ظهور الواجهة.
        .onAppear {
            // يتحقق من شرط لازم للاستمرار؛ ينفذ مسار الخروج عند عدم تحققه.
            guard !hasSelectedTrack else { return }
            hasSelectedTrack = true
            audioPlayer.select(artworkName: artworkName)
        }
    }
}

private struct MusicPlayerHeader: View {
    // إجراء الرجوع الذي يمرره العرض الأب.
    let onBack: () -> Void

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        ZStack {
            Text("Focus")
                .font(.system(.largeTitle, design: .rounded, weight: .regular))
                .foregroundStyle(AppColors.burgundy)

            // يرتب العناصر أفقيًا.
            HStack {
                // الجزء التنفيذي يحدد ما يحدث عند الضغط، وlabel يحدد شكل الزر إن وُجد.
                Button(action: onBack) {
                    Image(systemName: "chevron.backward")
                        // يضبط مساحة تخطيط العنصر ومحاذاته.
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
                    .buttonStyle(.plain)
                    // يوفر اسمًا تقرؤه التقنيات المساعدة مثل VoiceOver.
                    .accessibilityLabel("Back")
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background {
                        Circle()
                            .fill(AppColors.darkPage.opacity(0.45))
                    }

                Spacer()
            }
        }
        .padding(.horizontal, 18)
    }
}

private struct MusicArtworkPlaceholder: View {
    // العنوان المستخدم لهذا العنصر.
    let title: LocalizedStringKey
    // اسم الصورة المستخدمة في الموارد.
    let imageName: String

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        Color.clear
            .aspectRatio(3 / 4, contentMode: .fit)
            .overlay {
                Image(imageName)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(Color.black.opacity(0.12), lineWidth: 1)
            }
            // Scaled artwork can extend beyond its clipped layout for hit testing.
            .allowsHitTesting(false)
            .accessibilityLabel(title)
    }
}

private struct MusicPlaybackControls: View {
    // هل الصوت قيد التشغيل؟
    let isPlaying: Bool
    // إجراء تبديل تشغيل الصوت وإيقافه مؤقتًا.
    let onPlayPause: () -> Void
    // إجراء الانتقال إلى الصوت السابق.
    let onPrevious: () -> Void
    // إجراء الانتقال إلى الصوت التالي.
    let onNext: () -> Void
    // إجراء إعادة الصوت إلى بدايته.
    let onReplay: () -> Void
    // مشغل الصوت المشترك الذي تنعكس حالته على الواجهة.
    // @Bindable يتيح إنشاء روابط $ لخصائص كائن يدعم Observation.
    @Bindable var audioPlayer: FocusAudioPlayer

    // يبني محتوى العرض من البيانات الحالية؛ some View يخفي النوع التفصيلي لتركيب الواجهة.
    var body: some View {
        VStack(spacing: 34) {
            VStack(spacing: 4) {
                Slider(value: $audioPlayer.playbackPosition, in: 0...max(audioPlayer.duration, 1)) {
                    Text("Playback position")
                }
                .tint(.primary)
                .disabled(audioPlayer.duration <= 0)

                HStack {
                    Text(Self.timeString(audioPlayer.currentTime))
                    Spacer()
                    Text(Self.timeString(audioPlayer.duration))
                }
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.primary)
            }
            .environment(\.layoutDirection, .leftToRight)

            ZStack {
                HStack(spacing: 20) {
                    Button("Previous", systemImage: "backward.end.fill") {
                        onPrevious()
                    }
                    .accessibilityLabel("Previous sound")

                    Button(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause.fill" : "play.fill") {
                        onPlayPause()
                    }
                    .font(.system(size: 36))
                    .accessibilityLabel(isPlaying ? "Pause sound" : "Play sound")

                    Button("Next", systemImage: "forward.end.fill") {
                        onNext()
                    }
                    .accessibilityLabel("Next sound")
                }

                HStack {
                    Spacer()

                    Button("Replay", systemImage: "arrow.counterclockwise", action: onReplay)
                        .accessibilityLabel("Replay sound")
                }
            }
            .environment(\.layoutDirection, .leftToRight)
            .labelStyle(.iconOnly)
            .font(.system(size: 25))
            .foregroundStyle(AppColors.burgundy)
        }
    }

    // يحوّل الثواني إلى نص بصيغة دقائق وثوانٍ مع خانتين لكل جزء.
    private static func timeString(_ time: TimeInterval) -> String {
        let seconds = Int(max(0, time))
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

// معاينة داخل Xcode لتجربة الواجهة دون المرور بمسار التطبيق كاملًا.
#Preview {
    // حاوية تدير الانتقال إلى شاشات التفاصيل والرجوع منها.
    NavigationStack {
        MusicPlayerView(
            title: "Sound",
            artworkName: "khobar",
            audioPlayer: FocusAudioPlayer()
        )
    }
}
