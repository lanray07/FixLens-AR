import Foundation

final class RemoteAIService: ApplianceRecognitionService, TroubleshootingService, MaintenanceGuideService, ErrorCodeService, ApplianceHealthService, VoiceAssistantService {
    private let endpoint: URL?
    private let session: URLSession

    init(endpoint: URL? = URL(string: "https://YOUR_BACKEND_URL.com/fixlens-ar"), session: URLSession = .shared) {
        self.endpoint = endpoint
        self.session = session
    }

    func recognizeAppliance(scanContext: String) async throws -> ApplianceRecognitionResult {
        let response = try await request(module: "applianceRecognition", scanData: scanContext)
        let type = ApplianceType(rawValue: response.applianceType ?? "") ?? .unknown
        return ApplianceRecognitionResult(
            applianceType: type,
            modelPlaceholder: "Remote model placeholder",
            identifiedComponents: response.recommendations.isEmpty ? type.maintenanceComponents : response.recommendations,
            maintenanceStatus: response.summary,
            healthScore: 80,
            confidence: 0.86,
            warnings: response.warnings,
            recommendations: response.recommendations
        )
    }

    func troubleshoot(applianceType: ApplianceType, symptoms: String, errorCode: String?) async throws -> TroubleshootingResult {
        let response = try await request(module: "troubleshooting", applianceType: applianceType.rawValue, errorCode: errorCode, scanData: symptoms)
        return TroubleshootingResult(
            summary: response.summary,
            possibleCauses: response.recommendations,
            maintenanceActions: response.maintenanceSteps,
            warnings: response.warnings,
            escalationAdvice: SafetyPolicy.escalationAdvice(for: applianceType)
        )
    }

    func maintenanceGuides(for applianceType: ApplianceType) async throws -> [MaintenanceGuide] {
        let response = try await request(module: "maintenanceGuide", applianceType: applianceType.rawValue)
        return [
            MaintenanceGuide(
                applianceType: applianceType,
                title: "Remote maintenance guide",
                estimatedTimeMinutes: 10,
                difficulty: applianceType.isHighRisk ? .professional : .moderate,
                requiredTools: ["Manufacturer manual"],
                safetyWarnings: response.warnings,
                steps: response.maintenanceSteps
            )
        ]
    }

    func interpretErrorCode(_ code: String, applianceType: ApplianceType) async throws -> ErrorCodeResult {
        let response = try await request(module: "errorCode", applianceType: applianceType.rawValue, errorCode: code)
        return ErrorCodeResult(
            code: code,
            explanation: response.summary,
            possibleCauses: response.recommendations,
            troubleshootingSteps: response.maintenanceSteps,
            warnings: response.warnings,
            escalationAdvice: SafetyPolicy.escalationAdvice(for: applianceType)
        )
    }

    func evaluateHealth(for appliances: [Appliance], tasks: [MaintenanceTask]) async throws -> [HealthInsight] {
        appliances.map {
            HealthInsight(
                applianceID: $0.id,
                applianceName: $0.applianceType.displayName,
                healthScore: $0.healthScore,
                riskScore: max(0, 100 - $0.healthScore),
                insight: "Remote health scoring placeholder.",
                nextAction: SafetyPolicy.safeActionSummary(for: $0.applianceType)
            )
        }
    }

    func answerVoiceQuestion(_ transcript: String, applianceType: ApplianceType?) async throws -> VoiceAssistantResponse {
        let response = try await request(module: "voiceAssistant", applianceType: applianceType?.rawValue, voiceTranscript: transcript)
        return VoiceAssistantResponse(
            summary: response.summary,
            spokenResponse: response.summary,
            suggestedActions: response.maintenanceSteps,
            warnings: response.warnings
        )
    }

    private func request(
        module: String,
        applianceType: String? = nil,
        errorCode: String? = nil,
        voiceTranscript: String? = nil,
        scanData: String? = nil
    ) async throws -> RemoteAIResponse {
        guard let endpoint else {
            throw RemoteAIServiceError.missingEndpoint
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(RemoteAIRequest(
            module: module,
            applianceType: applianceType ?? "",
            errorCode: errorCode ?? "",
            voiceTranscript: voiceTranscript ?? "",
            scanData: scanData ?? ""
        ))

        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(RemoteAIResponse.self, from: data)
    }
}

private struct RemoteAIRequest: Encodable {
    let module: String
    let applianceType: String
    let errorCode: String
    let voiceTranscript: String
    let scanData: String
}

private struct RemoteAIResponse: Decodable {
    let maintenanceSteps: [String]
    let warnings: [String]
    let recommendations: [String]
    let summary: String
    let applianceType: String?

    private enum CodingKeys: String, CodingKey {
        case maintenanceSteps
        case warnings
        case recommendations
        case summary
        case applianceType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        maintenanceSteps = try container.decodeIfPresent([String].self, forKey: .maintenanceSteps) ?? []
        warnings = try container.decodeIfPresent([String].self, forKey: .warnings) ?? []
        recommendations = try container.decodeIfPresent([String].self, forKey: .recommendations) ?? []
        summary = try container.decodeIfPresent(String.self, forKey: .summary) ?? "Remote AI response placeholder."
        applianceType = try container.decodeIfPresent(String.self, forKey: .applianceType)
    }
}

private enum RemoteAIServiceError: Error {
    case missingEndpoint
}
