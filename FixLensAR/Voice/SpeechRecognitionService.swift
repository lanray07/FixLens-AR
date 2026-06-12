import Foundation
import Speech

@MainActor
final class SpeechRecognitionService: ObservableObject {
    @Published var transcript = ""
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    @Published var isListening = false

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_GB"))

    func requestAuthorization() async {
        authorizationStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    func startMockListening() {
        isListening = true
        transcript = "How do I clean this filter safely?"
    }

    func stopListening() {
        isListening = false
    }

    var isAvailable: Bool {
        recognizer?.isAvailable == true
    }
}
