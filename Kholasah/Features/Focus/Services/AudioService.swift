import Foundation
import AVFoundation
import Observation

/// Owns local playback and counts only time spent listening, across track changes.
@MainActor
@Observable
final class FocusAudioPlayer {
    static let artworkNames = ["sandHouse", "khobar", "car", "mountain"]

    private(set) var isPlaying = false
    private(set) var selectedIndex = 0
    private(set) var elapsedTime: TimeInterval = 0
    private(set) var playbackError: String?
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0

    var playbackPosition: TimeInterval {
        get { currentTime }
        set { seek(to: newValue) }
    }

    let sessionDuration: TimeInterval

    @ObservationIgnored private var player: AVAudioPlayer?
    @ObservationIgnored private var sessionTask: Task<Void, Never>?
    @ObservationIgnored private var startedAt: TimeInterval?

    var artworkName: String { Self.artworkNames[selectedIndex] }

    init(sessionDuration: TimeInterval = 15 * 60) {
        self.sessionDuration = sessionDuration
    }

    func select(artworkName: String) {
        pause()
        player = nil
        elapsedTime = 0
        selectedIndex = Self.artworkNames.firstIndex(of: artworkName) ?? 0
        prepareTrack()
    }

    func play() {
        guard !isPlaying else { return }
        if elapsedTime >= sessionDuration {
            elapsedTime = 0
            player?.currentTime = 0
        }
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

    func togglePlayback() {
        if isPlaying { pause() } else { play() }
    }

    func seek(to time: TimeInterval) {
        guard let player, duration > 0, time.isFinite else { return }
        // At the end of a looping track, continue from its beginning.
        player.currentTime = time >= duration ? 0 : max(0, time)
        updatePlaybackTime()
    }

    func replay() {
        seek(to: 0)
        // Replay must never reset or extend a completed listening session.
        guard listeningTime < sessionDuration else { return }
        play()
    }

    private func updatePlaybackTime() {
        currentTime = player?.currentTime ?? 0
        duration = player?.duration ?? 0
    }

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

    func next() { changeTrack(by: 1) }
    func previous() { changeTrack(by: -1) }

    private var listeningTime: TimeInterval {
        elapsedTime + (startedAt.map { ProcessInfo.processInfo.systemUptime - $0 } ?? 0)
    }

    private func changeTrack(by offset: Int) {
        let resume = isPlaying
        pause()
        selectedIndex = (selectedIndex + offset + Self.artworkNames.count) % Self.artworkNames.count
        player = nil
        prepareTrack()
        if resume { play() }
    }
}


protocol AudioService: Sendable {
    var isPlaying: Bool { get async }
    func play() async
    func pause() async
}
