import Foundation

final class MockAIService: ApplianceRecognitionService, TroubleshootingService, MaintenanceGuideService, ErrorCodeService, ApplianceHealthService, VoiceAssistantService {
    private let prompt = "You are FixLens AR, a home maintenance assistant. Help users understand appliances, perform safe maintenance, and identify possible issues. Do not provide gas engineering advice, electrical certification, dangerous repair instructions, or safety-critical guidance beyond educational maintenance information."

    func recognizeAppliance(scanContext: String) async throws -> ApplianceRecognitionResult {
        try await Task.sleep(nanoseconds: 450_000_000)
        let type = detectAppliance(from: scanContext)
        let warnings = SafetyPolicy.warnings(for: type)

        return ApplianceRecognitionResult(
            applianceType: type,
            modelPlaceholder: "\(type.displayName) Model Placeholder",
            identifiedComponents: type.maintenanceComponents,
            maintenanceStatus: type.isHighRisk ? "External inspection only" : "Routine maintenance available",
            healthScore: type.isHighRisk ? 72 : 86,
            confidence: type == .unknown ? 0.54 : 0.91,
            warnings: warnings,
            recommendations: recommendations(for: type)
        )
    }

    func troubleshoot(applianceType: ApplianceType, symptoms: String, errorCode: String?) async throws -> TroubleshootingResult {
        try await Task.sleep(nanoseconds: 520_000_000)
        let codeText = errorCode?.isEmpty == false ? " The displayed code \(errorCode ?? "") may indicate a manufacturer-specific condition." : ""

        return TroubleshootingResult(
            summary: "The symptom may relate to routine maintenance, blocked airflow, filter condition, drainage, or a manufacturer-specific alert.\(codeText)",
            possibleCauses: [
                "A filter, seal, vent, or visible component may need inspection.",
                "A sensor or warning indicator may be reporting a routine maintenance state.",
                "The manufacturer manual may list a model-specific cause."
            ],
            maintenanceActions: safeMaintenanceActions(for: applianceType),
            warnings: SafetyPolicy.warnings(for: applianceType),
            escalationAdvice: SafetyPolicy.escalationAdvice(for: applianceType)
        )
    }

    func maintenanceGuides(for applianceType: ApplianceType) async throws -> [MaintenanceGuide] {
        try await Task.sleep(nanoseconds: 300_000_000)
        let warnings = SafetyPolicy.warnings(for: applianceType)
        let difficulty: MaintenanceDifficulty = applianceType.isHighRisk ? .professional : .easy

        return [
            MaintenanceGuide(
                applianceType: applianceType,
                title: "Routine visual check",
                estimatedTimeMinutes: 6,
                difficulty: .easy,
                requiredTools: ["Torch", "Manufacturer manual"],
                safetyWarnings: warnings,
                steps: [
                    "Confirm the appliance is in a safe, normal operating state.",
                    "Check visible labels, displays, vents, and accessible controls.",
                    "Look for leaks, heat damage, unusual smells, or warning indicators.",
                    "Record findings in the appliance history."
                ]
            ),
            MaintenanceGuide(
                applianceType: applianceType,
                title: applianceType.isHighRisk ? "Professional service preparation" : "Filter or surface care",
                estimatedTimeMinutes: applianceType.isHighRisk ? 4 : 12,
                difficulty: difficulty,
                requiredTools: applianceType.isHighRisk ? ["Service history", "Photos of labels"] : ["Microfibre cloth", "Warm water", "Manufacturer-approved cleaner"],
                safetyWarnings: warnings,
                steps: applianceType.isHighRisk ? [
                    "Photograph the external model label and any visible warning state.",
                    "Do not open covers, sealed panels, or safety-critical parts.",
                    "Book a qualified professional and share the saved report."
                ] : [
                    "Power down only where the manufacturer manual recommends it.",
                    "Remove loose debris from accessible filter or surface areas.",
                    "Clean gently using manufacturer-approved materials.",
                    "Reassemble and log the maintenance date."
                ]
            )
        ]
    }

    func interpretErrorCode(_ code: String, applianceType: ApplianceType) async throws -> ErrorCodeResult {
        try await Task.sleep(nanoseconds: 360_000_000)

        return ErrorCodeResult(
            code: code.uppercased(),
            explanation: "This code may indicate a manufacturer-specific warning. FixLens AR treats error-code guidance as informational and recommends confirming with the appliance manual.",
            possibleCauses: [
                "Routine maintenance alert",
                "Blocked or restricted airflow/water path",
                "Sensor warning or service reminder"
            ],
            troubleshootingSteps: safeMaintenanceActions(for: applianceType),
            warnings: SafetyPolicy.warnings(for: applianceType),
            escalationAdvice: SafetyPolicy.escalationAdvice(for: applianceType)
        )
    }

    func evaluateHealth(for appliances: [Appliance], tasks: [MaintenanceTask]) async throws -> [HealthInsight] {
        try await Task.sleep(nanoseconds: 220_000_000)

        return appliances.map { appliance in
            let relatedTasks = tasks.filter { $0.applianceId == appliance.id }
            let overdueCount = relatedTasks.filter { !$0.completed && $0.dueDate < .now }.count
            let riskScore = min(100, max(4, 100 - appliance.healthScore + overdueCount * 12 + (appliance.applianceType.isHighRisk ? 10 : 0)))

            return HealthInsight(
                applianceID: appliance.id,
                applianceName: appliance.applianceType.displayName,
                healthScore: appliance.healthScore,
                riskScore: riskScore,
                insight: overdueCount > 0 ? "Maintenance is overdue. Prioritize routine checks and update the service log." : "Maintenance rhythm looks healthy.",
                nextAction: appliance.applianceType.isHighRisk ? "Review external status and book qualified service if anything looks abnormal." : "Run a routine visual check this week."
            )
        }
    }

    func answerVoiceQuestion(_ transcript: String, applianceType: ApplianceType?) async throws -> VoiceAssistantResponse {
        try await Task.sleep(nanoseconds: 420_000_000)
        let type = applianceType ?? .unknown

        return VoiceAssistantResponse(
            summary: "I can guide safe, routine maintenance and help identify visible appliance areas.",
            spokenResponse: "Here is the safe path. I can show external components, routine cleaning points, and when to stop. For gas, electrical, high voltage, or sealed systems, contact a qualified professional.",
            suggestedActions: safeMaintenanceActions(for: type),
            warnings: SafetyPolicy.warnings(for: type)
        )
    }

    private func detectAppliance(from context: String) -> ApplianceType {
        let lowered = context.lowercased()
        if lowered.contains("boiler") { return .boiler }
        if lowered.contains("washer") || lowered.contains("washing") { return .washingMachine }
        if lowered.contains("dishwasher") { return .dishwasher }
        if lowered.contains("fridge") || lowered.contains("refrigerator") { return .fridge }
        if lowered.contains("freezer") { return .freezer }
        if lowered.contains("oven") { return .oven }
        if lowered.contains("hob") || lowered.contains("cooktop") { return .hob }
        if lowered.contains("radiator") { return .radiator }
        if lowered.contains("thermostat") { return .thermostat }
        if lowered.contains("hvac") || lowered.contains("air") { return .hvac }
        if lowered.contains("water heater") { return .waterHeater }
        if lowered.contains("panel") || lowered.contains("breaker") { return .electricalPanel }
        return [.washingMachine, .dishwasher, .fridge, .boiler, .radiator].randomElement() ?? .unknown
    }

    private func recommendations(for applianceType: ApplianceType) -> [String] {
        if applianceType.isHighRisk {
            return [
                "Capture the model label and service history.",
                "Perform external visual checks only.",
                "Escalate unsafe, gas, electrical, or sealed-system concerns to a qualified professional."
            ]
        }

        return [
            "Inspect accessible filters, seals, vents, or drawers.",
            "Clean manufacturer-approved maintenance areas.",
            "Set a reminder for the next routine check."
        ]
    }

    private func safeMaintenanceActions(for applianceType: ApplianceType) -> [String] {
        if applianceType.isHighRisk {
            return [
                "Use AR labels to identify external controls, warning indicators, and service labels.",
                "Do not open sealed panels, gas components, electrical internals, or high-voltage areas.",
                "Contact a qualified professional if the warning persists or the appliance appears unsafe."
            ]
        }

        return [
            "Inspect accessible filters, seals, vents, and visible controls.",
            "Clean only manufacturer-approved parts.",
            "Log the result and schedule the next maintenance reminder."
        ]
    }
}
