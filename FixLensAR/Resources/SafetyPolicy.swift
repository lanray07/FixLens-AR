import Foundation

enum SafetyPolicy {
    static let educationalDisclaimer = "FixLens AR is an educational maintenance tool only. It is not professional repair advice, gas engineering advice, electrical certification, or a replacement for qualified tradespeople."

    static let professionalEscalation = "Stop and contact a qualified professional if you see gas, burning smells, exposed wiring, leaks near electrics, sealed-system parts, high voltage, carbon monoxide warnings, or anything you are unsure about."

    static func warnings(for applianceType: ApplianceType) -> [String] {
        var warnings = [
            "Follow the manufacturer manual before performing any maintenance.",
            "Switch off and isolate appliances only where the manual says it is safe to do so.",
            "Do not open sealed systems or bypass safety devices."
        ]

        if applianceType.isHighRisk {
            warnings.insert("Professional escalation recommended for gas, boiler, high-voltage, HVAC, or safety-critical work.", at: 0)
            warnings.append("FixLens AR can help identify external labels, filters, controls, and safe observation points, but it will not guide dangerous repair procedures.")
        }

        if applianceType == .electricalPanel {
            warnings.insert("Do not remove electrical panel covers or touch internal wiring.", at: 0)
        }

        if applianceType == .boiler || applianceType == .hob || applianceType == .waterHeater {
            warnings.insert("Do not attempt gas adjustments, combustion checks, flue work, or pressure-related repairs.", at: 0)
        }

        return warnings
    }

    static func escalationAdvice(for applianceType: ApplianceType) -> String {
        applianceType.isHighRisk ? professionalEscalation : "Use FixLens AR for routine maintenance guidance only. Escalate to a professional if the issue appears unsafe, hidden, sealed, or outside routine care."
    }

    static func safeActionSummary(for applianceType: ApplianceType) -> String {
        if applianceType.isHighRisk {
            return "Safe guidance is limited to external inspection, label reading, routine cleaning where manufacturer-approved, and professional escalation."
        }
        return "Safe guidance focuses on routine cleaning, visual checks, manufacturer-approved filter care, reminders, and maintenance record keeping."
    }
}
