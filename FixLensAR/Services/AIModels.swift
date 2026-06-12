import Foundation

struct ApplianceRecognitionResult: Hashable {
    let applianceType: ApplianceType
    let modelPlaceholder: String
    let identifiedComponents: [String]
    let maintenanceStatus: String
    let healthScore: Int
    let confidence: Double
    let warnings: [String]
    let recommendations: [String]
}

struct MaintenanceGuide: Identifiable, Hashable {
    let id = UUID()
    let applianceType: ApplianceType
    let title: String
    let estimatedTimeMinutes: Int
    let difficulty: MaintenanceDifficulty
    let requiredTools: [String]
    let safetyWarnings: [String]
    let steps: [String]
}

struct TroubleshootingResult: Hashable {
    let summary: String
    let possibleCauses: [String]
    let maintenanceActions: [String]
    let warnings: [String]
    let escalationAdvice: String
}

struct ErrorCodeResult: Hashable {
    let code: String
    let explanation: String
    let possibleCauses: [String]
    let troubleshootingSteps: [String]
    let warnings: [String]
    let escalationAdvice: String
}

struct VoiceAssistantResponse: Hashable {
    let summary: String
    let spokenResponse: String
    let suggestedActions: [String]
    let warnings: [String]
}

struct HealthInsight: Identifiable, Hashable {
    let id = UUID()
    let applianceID: UUID
    let applianceName: String
    let healthScore: Int
    let riskScore: Int
    let insight: String
    let nextAction: String
}

struct ARInstructionStep: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    let component: String
    let title: String
    let detail: String
    let isWarningZone: Bool
}

protocol ApplianceRecognitionService {
    func recognizeAppliance(scanContext: String) async throws -> ApplianceRecognitionResult
}

protocol TroubleshootingService {
    func troubleshoot(applianceType: ApplianceType, symptoms: String, errorCode: String?) async throws -> TroubleshootingResult
}

protocol MaintenanceGuideService {
    func maintenanceGuides(for applianceType: ApplianceType) async throws -> [MaintenanceGuide]
}

protocol ErrorCodeService {
    func interpretErrorCode(_ code: String, applianceType: ApplianceType) async throws -> ErrorCodeResult
}

protocol ApplianceHealthService {
    func evaluateHealth(for appliances: [Appliance], tasks: [MaintenanceTask]) async throws -> [HealthInsight]
}

protocol VoiceAssistantService {
    func answerVoiceQuestion(_ transcript: String, applianceType: ApplianceType?) async throws -> VoiceAssistantResponse
}
