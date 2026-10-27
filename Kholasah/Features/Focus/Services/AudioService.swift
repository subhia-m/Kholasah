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
    }

    func play() {
        guard !isPlaying else { return }
        if elapsedTime >= sessionDuration {
            elapsedTime = 0
            player?.currentTime = 0
        }
        do {
            if player == nil {
                let name = "music\(selectedIndex + 1)"
                guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
                    throw CocoaError(.fileNoSuchFile)
                }
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = -1
                player?.prepareToPlay()
            }
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
                    if self.player?.isPlaying != true {
                        self.pause()
                        return
                    }
                    if self.listeningTime >= self.sessionDuration {
                        self.pause()
                        self.elapsedTime = self.sessionDuration
                        self.player?.currentTime = 0
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
        if resume { play() }
    }
}


protocol AudioService: Sendable {
    var isPlaying: Bool { get async }
    func play() async
    func pause() async
}
