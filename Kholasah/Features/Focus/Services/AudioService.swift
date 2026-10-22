import Foundation

protocol AudioService: Sendable {
    var isPlaying: Bool { get async }
    func play() async
    func pause() async
}
