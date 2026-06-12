import AVFoundation
import Foundation

@MainActor
final class VoiceRecordingService: ObservableObject {
    @Published var hasMicrophonePermission = false
    @Published var isRecording = false

    func requestPermissionIfNeeded() async {
        hasMicrophonePermission = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func startRecording() {
        isRecording = true
    }

    func stopRecording() {
        isRecording = false
    }
}
