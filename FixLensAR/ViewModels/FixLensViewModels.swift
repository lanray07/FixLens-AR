import AVFoundation
import Foundation
import SwiftData
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var selectedRole: UserRole = .homeowner
    @Published var selectedPropertyType: PropertyType = .house
    @Published var applianceCount = 6
    @Published var selectedGoals: Set<MaintenanceGoal> = [.reduceCallouts, .extendLifespan, .organizeRecords]

    func toggleGoal(_ goal: MaintenanceGoal) {
        if selectedGoals.contains(goal) {
            selectedGoals.remove(goal)
        } else {
            selectedGoals.insert(goal)
        }
    }

    func complete(context: ModelContext) {
        let profile = HomeProfile(
            homeownerRole: selectedRole,
            propertyType: selectedPropertyType,
            applianceCount: applianceCount,
            goals: Array(selectedGoals)
        )
        context.insert(profile)

        let defaultTypes: [ApplianceType] = selectedRole == .landlord || selectedRole == .propertyManager
            ? [.boiler, .washingMachine, .fridge, .dishwasher, .electricalPanel]
            : [.boiler, .washingMachine, .dishwasher]

        for (index, type) in defaultTypes.enumerated() {
            let appliance = Appliance(
                applianceType: type,
                modelPlaceholder: "\(type.displayName) Model Placeholder",
                installDate: Calendar.current.date(byAdding: .year, value: -index - 1, to: .now),
                healthScore: max(62, 92 - index * 7)
            )
            context.insert(appliance)

            let task = MaintenanceTask(
                applianceId: appliance.id,
                title: type.isHighRisk ? "Book qualified service check" : "Routine \(type.displayName.lowercased()) maintenance",
                dueDate: Calendar.current.date(byAdding: .day, value: 7 + index * 12, to: .now) ?? .now,
                category: type.isHighRisk ? "Professional" : "Routine",
                safetyLevel: type.isHighRisk ? .professionalOnly : .normal
            )
            context.insert(task)
        }

        try? context.save()
    }
}

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var insights: [HealthInsight] = []
    @Published var isLoadingInsights = false
    @Published var errorMessage: String?

    func refresh(appliances: [Appliance], tasks: [MaintenanceTask], service: any ApplianceHealthService) async {
        guard !appliances.isEmpty else {
            insights = []
            return
        }

        isLoadingInsights = true
        defer { isLoadingInsights = false }

        do {
            insights = try await service.evaluateHealth(for: appliances, tasks: tasks)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@MainActor
final class ScannerViewModel: ObservableObject {
    @Published var scanContext = "washing machine with filter drawer"
    @Published var result: ApplianceRecognitionResult?
    @Published var isScanning = false
    @Published var errorMessage: String?

    func performScan(context: ModelContext, service: any ApplianceRecognitionService) async {
        isScanning = true
        defer { isScanning = false }

        do {
            let recognition = try await service.recognizeAppliance(scanContext: scanContext)
            let appliance = Appliance(
                applianceType: recognition.applianceType,
                modelPlaceholder: recognition.modelPlaceholder,
                installDate: nil,
                healthScore: recognition.healthScore
            )
            context.insert(appliance)

            let scan = ScanResult(
                applianceId: appliance.id,
                applianceType: recognition.applianceType,
                identifiedComponents: recognition.identifiedComponents,
                confidence: recognition.confidence
            )
            context.insert(scan)

            for (index, recommendation) in recognition.recommendations.enumerated() {
                let dueDate = Calendar.current.date(byAdding: .day, value: (index + 1) * 7, to: .now) ?? .now
                context.insert(MaintenanceTask(
                    applianceId: appliance.id,
                    title: recommendation,
                    dueDate: dueDate,
                    category: recognition.applianceType.isHighRisk ? "Safety" : "Maintenance",
                    safetyLevel: recognition.applianceType.isHighRisk ? .professionalOnly : .normal
                ))
            }

            try? context.save()
            result = recognition
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@MainActor
final class MaintenanceGuidesViewModel: ObservableObject {
    @Published var selectedType: ApplianceType = .washingMachine
    @Published var guides: [MaintenanceGuide] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(service: any MaintenanceGuideService) async {
        isLoading = true
        defer { isLoading = false }

        do {
            guides = try await service.maintenanceGuides(for: selectedType)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@MainActor
final class TroubleshooterViewModel: ObservableObject {
    @Published var selectedType: ApplianceType = .washingMachine
    @Published var symptoms = ""
    @Published var errorCode = ""
    @Published var result: TroubleshootingResult?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func troubleshoot(service: any TroubleshootingService) async {
        guard !symptoms.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Describe the symptom first."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            result = try await service.troubleshoot(
                applianceType: selectedType,
                symptoms: symptoms,
                errorCode: errorCode.isEmpty ? nil : errorCode
            )
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@MainActor
final class ErrorCodeScannerViewModel: ObservableObject {
    @Published var selectedType: ApplianceType = .dishwasher
    @Published var code = "E24"
    @Published var recognizedText: [String] = []
    @Published var result: ErrorCodeResult?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let ocrService = OCRScannerService()

    func mockScanDisplay() async {
        recognizedText = await ocrService.mockRecognizeDisplay()
        code = recognizedText.first ?? code
    }

    func interpret(service: any ErrorCodeService, context: ModelContext) async {
        guard !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Enter or scan an error code."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let interpretation = try await service.interpretErrorCode(code, applianceType: selectedType)
            context.insert(ErrorCode(code: interpretation.code, explanation: interpretation.explanation))
            try? context.save()
            result = interpretation
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@MainActor
final class VoiceAssistantViewModel: ObservableObject {
    @Published var selectedType: ApplianceType = .washingMachine
    @Published var transcript = ""
    @Published var response: VoiceAssistantResponse?
    @Published var isProcessing = false
    @Published var errorMessage: String?

    private let synthesizer = AVSpeechSynthesizer()

    func startListening(speech: SpeechRecognitionService, recording: VoiceRecordingService, waveform: WaveformAnimationManager) {
        recording.startRecording()
        speech.startMockListening()
        waveform.start()
        transcript = speech.transcript
    }

    func stopListening(speech: SpeechRecognitionService, recording: VoiceRecordingService, waveform: WaveformAnimationManager) {
        recording.stopRecording()
        speech.stopListening()
        waveform.stop()
    }

    func submit(service: any VoiceAssistantService, context: ModelContext) async {
        guard !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Ask a maintenance question first."
            return
        }

        isProcessing = true
        defer { isProcessing = false }

        do {
            let reply = try await service.answerVoiceQuestion(transcript, applianceType: selectedType)
            context.insert(VoiceTranscript(transcript: transcript, generatedResponse: reply.summary))
            try? context.save()
            response = reply
            speak(reply.spokenResponse)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.47
        synthesizer.speak(utterance)
    }
}

@MainActor
final class ReportsViewModel: ObservableObject {
    struct SharePayload: Identifiable {
        let id = UUID()
        let url: URL
    }

    @Published var sharePayload: SharePayload?
    @Published var isExporting = false
    @Published var errorMessage: String?

    func export(appliances: [Appliance], tasks: [MaintenanceTask], context: ModelContext, pdfService: PDFReportService) {
        isExporting = true
        defer { isExporting = false }

        do {
            let safetyNotes = Array(Set(appliances.flatMap { SafetyPolicy.warnings(for: $0.applianceType) })).sorted()
            let payload = MaintenanceReportPayload(
                title: "Maintenance Report",
                subtitle: "Appliance inventory, open maintenance tasks, and safety notes.",
                generatedAt: .now,
                appliances: appliances,
                tasks: tasks,
                safetyNotes: safetyNotes.isEmpty ? [SafetyPolicy.educationalDisclaimer] : safetyNotes
            )
            let url = try pdfService.makeReport(payload: payload)
            context.insert(MaintenanceReport(applianceId: nil, reportType: "Property Report", generatedFilePath: url.path))
            try? context.save()
            sharePayload = SharePayload(url: url)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
