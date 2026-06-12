import Foundation
import SwiftData
import SwiftUI

enum UserRole: String, CaseIterable, Identifiable, Codable, Hashable {
    case homeowner = "Homeowner"
    case landlord = "Landlord"
    case propertyManager = "Property Manager"
    case maintenanceProfessional = "Maintenance Professional"
    case airbnbHost = "Airbnb Host"

    var id: String { rawValue }
}

enum PropertyType: String, CaseIterable, Identifiable, Codable, Hashable {
    case apartment = "Apartment"
    case house = "House"
    case townhouse = "Townhouse"
    case multiUnit = "Multi-unit"
    case shortTermRental = "Short-term Rental"

    var id: String { rawValue }
}

enum MaintenanceGoal: String, CaseIterable, Identifiable, Codable, Hashable {
    case reduceCallouts = "Reduce callouts"
    case extendLifespan = "Extend appliance lifespan"
    case organizeRecords = "Organize records"
    case learnRoutineCare = "Learn routine care"
    case trackPortfolio = "Track portfolio"

    var id: String { rawValue }
}

enum ApplianceType: String, CaseIterable, Identifiable, Codable, Hashable {
    case boiler = "Boiler"
    case washingMachine = "Washing Machine"
    case dishwasher = "Dishwasher"
    case fridge = "Fridge"
    case freezer = "Freezer"
    case oven = "Oven"
    case hob = "Hob"
    case radiator = "Radiator"
    case thermostat = "Thermostat"
    case hvac = "HVAC Unit"
    case waterHeater = "Water Heater"
    case electricalPanel = "Electrical Panel"
    case unknown = "Unknown Appliance"

    var id: String { rawValue }
    var displayName: String { rawValue }

    var symbolName: String {
        switch self {
        case .boiler: "flame"
        case .washingMachine: "washer"
        case .dishwasher: "water.waves"
        case .fridge: "refrigerator"
        case .freezer: "snowflake"
        case .oven: "oven"
        case .hob: "flame.circle"
        case .radiator: "heat.waves"
        case .thermostat: "thermometer.medium"
        case .hvac: "fan"
        case .waterHeater: "drop.degreesign"
        case .electricalPanel: "bolt.trianglebadge.exclamationmark"
        case .unknown: "questionmark.viewfinder"
        }
    }

    var isHighRisk: Bool {
        switch self {
        case .boiler, .hob, .waterHeater, .electricalPanel, .hvac:
            true
        default:
            false
        }
    }

    var maintenanceComponents: [String] {
        switch self {
        case .boiler:
            ["Pressure gauge", "External controls", "Vent area", "Service label"]
        case .washingMachine:
            ["Detergent drawer", "Door seal", "Drain filter", "Water inlet hose"]
        case .dishwasher:
            ["Filter basket", "Spray arm", "Door seal", "Salt reservoir"]
        case .fridge:
            ["Door gasket", "Condenser area", "Temperature control", "Drain channel"]
        case .freezer:
            ["Door gasket", "Defrost channel", "Vent area", "Temperature control"]
        case .oven:
            ["Door seal", "Interior liner", "Control panel", "Fan cover"]
        case .hob:
            ["Surface zones", "Control knobs", "Warning indicators", "Safety shutoff area"]
        case .radiator:
            ["Bleed valve", "Thermostatic valve", "Pipe connections", "Surface condition"]
        case .thermostat:
            ["Display", "Schedule controls", "Battery cover", "Temperature sensor"]
        case .hvac:
            ["Return vent", "Filter slot", "Drain line", "External service panel"]
        case .waterHeater:
            ["Temperature control", "Pressure relief label", "Drain valve", "Service label"]
        case .electricalPanel:
            ["Breaker labels", "Warning indicators", "Panel cover", "Clearance zone"]
        case .unknown:
            ["Visible label", "Control area", "Service badge", "Access panel"]
        }
    }
}

enum MaintenanceDifficulty: String, CaseIterable, Identifiable, Codable, Hashable {
    case easy = "Easy"
    case moderate = "Moderate"
    case professional = "Professional"

    var id: String { rawValue }
}

enum SafetyLevel: String, Codable, Hashable {
    case normal = "Normal"
    case caution = "Caution"
    case professionalOnly = "Professional Only"
}

enum SubscriptionPlan: String, CaseIterable, Identifiable, Codable, Hashable {
    case free = "Free"
    case proMonthly = "FixLens Pro Monthly"
    case proYearly = "FixLens Pro Yearly"
    case propertyProMonthly = "Property Pro Monthly"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .free: "Free"
        case .proMonthly: "FixLens Pro"
        case .proYearly: "FixLens Pro Yearly"
        case .propertyProMonthly: "Property Pro"
        }
    }

    var pricePlaceholder: String {
        switch self {
        case .free: "Included"
        case .proMonthly: "£9.99/mo"
        case .proYearly: "£79.99/yr"
        case .propertyProMonthly: "£24.99/mo"
        }
    }

    var features: [String] {
        switch self {
        case .free:
            ["Limited scans", "Basic maintenance guides", "Limited troubleshooting"]
        case .proMonthly, .proYearly:
            ["Unlimited scans", "AR overlays", "Voice guidance", "Appliance history", "Maintenance calendar"]
        case .propertyProMonthly:
            ["Multiple properties", "Appliance inventory", "Advanced reports", "Landlord dashboard"]
        }
    }
}

@Model
final class HomeProfile {
    @Attribute(.unique) var id: UUID
    var homeownerRoleRaw: String
    var propertyTypeRaw: String
    var applianceCount: Int
    var goalsStorage: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        homeownerRole: UserRole,
        propertyType: PropertyType,
        applianceCount: Int,
        goals: [MaintenanceGoal],
        createdAt: Date = .now
    ) {
        self.id = id
        homeownerRoleRaw = homeownerRole.rawValue
        propertyTypeRaw = propertyType.rawValue
        self.applianceCount = applianceCount
        goalsStorage = goals.map(\.rawValue).joined(separator: "|")
        self.createdAt = createdAt
    }

    var homeownerRole: UserRole {
        UserRole(rawValue: homeownerRoleRaw) ?? .homeowner
    }

    var propertyType: PropertyType {
        PropertyType(rawValue: propertyTypeRaw) ?? .house
    }

    var goals: [MaintenanceGoal] {
        goalsStorage
            .split(separator: "|")
            .compactMap { MaintenanceGoal(rawValue: String($0)) }
    }
}

@Model
final class Appliance {
    @Attribute(.unique) var id: UUID
    var applianceTypeRaw: String
    var modelPlaceholder: String
    var installDate: Date?
    var healthScore: Int
    var createdAt: Date
    var lastMaintenanceAt: Date?

    init(
        id: UUID = UUID(),
        applianceType: ApplianceType,
        modelPlaceholder: String,
        installDate: Date? = nil,
        healthScore: Int,
        createdAt: Date = .now,
        lastMaintenanceAt: Date? = nil
    ) {
        self.id = id
        applianceTypeRaw = applianceType.rawValue
        self.modelPlaceholder = modelPlaceholder
        self.installDate = installDate
        self.healthScore = healthScore
        self.createdAt = createdAt
        self.lastMaintenanceAt = lastMaintenanceAt
    }

    var applianceType: ApplianceType {
        get { ApplianceType(rawValue: applianceTypeRaw) ?? .unknown }
        set { applianceTypeRaw = newValue.rawValue }
    }
}

@Model
final class MaintenanceTask {
    @Attribute(.unique) var id: UUID
    var applianceId: UUID
    var title: String
    var dueDate: Date
    var completed: Bool
    var completedAt: Date?
    var category: String
    var safetyLevelRaw: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        applianceId: UUID,
        title: String,
        dueDate: Date,
        completed: Bool = false,
        completedAt: Date? = nil,
        category: String = "Routine",
        safetyLevel: SafetyLevel = .normal,
        createdAt: Date = .now
    ) {
        self.id = id
        self.applianceId = applianceId
        self.title = title
        self.dueDate = dueDate
        self.completed = completed
        self.completedAt = completedAt
        self.category = category
        safetyLevelRaw = safetyLevel.rawValue
        self.createdAt = createdAt
    }

    var safetyLevel: SafetyLevel {
        SafetyLevel(rawValue: safetyLevelRaw) ?? .normal
    }
}

@Model
final class ScanResult {
    @Attribute(.unique) var id: UUID
    var applianceId: UUID?
    var applianceTypeRaw: String
    var identifiedComponentsStorage: String
    var confidence: Double
    var createdAt: Date

    init(
        id: UUID = UUID(),
        applianceId: UUID?,
        applianceType: ApplianceType,
        identifiedComponents: [String],
        confidence: Double,
        createdAt: Date = .now
    ) {
        self.id = id
        self.applianceId = applianceId
        applianceTypeRaw = applianceType.rawValue
        identifiedComponentsStorage = identifiedComponents.joined(separator: "|")
        self.confidence = confidence
        self.createdAt = createdAt
    }

    var applianceType: ApplianceType {
        ApplianceType(rawValue: applianceTypeRaw) ?? .unknown
    }

    var identifiedComponents: [String] {
        identifiedComponentsStorage.split(separator: "|").map(String.init)
    }
}

@Model
final class ErrorCode {
    @Attribute(.unique) var id: UUID
    var code: String
    var explanation: String
    var createdAt: Date

    init(id: UUID = UUID(), code: String, explanation: String, createdAt: Date = .now) {
        self.id = id
        self.code = code
        self.explanation = explanation
        self.createdAt = createdAt
    }
}

@Model
final class VoiceTranscript {
    @Attribute(.unique) var id: UUID
    var transcript: String
    var generatedResponse: String
    var createdAt: Date

    init(id: UUID = UUID(), transcript: String, generatedResponse: String, createdAt: Date = .now) {
        self.id = id
        self.transcript = transcript
        self.generatedResponse = generatedResponse
        self.createdAt = createdAt
    }
}

@Model
final class MaintenanceReport {
    @Attribute(.unique) var id: UUID
    var applianceId: UUID?
    var reportType: String
    var generatedFilePath: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        applianceId: UUID?,
        reportType: String,
        generatedFilePath: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.applianceId = applianceId
        self.reportType = reportType
        self.generatedFilePath = generatedFilePath
        self.createdAt = createdAt
    }
}

@Model
final class SubscriptionState {
    @Attribute(.unique) var id: UUID
    var planRaw: String
    var isActive: Bool
    var renewalDate: Date?

    init(id: UUID = UUID(), plan: SubscriptionPlan, isActive: Bool, renewalDate: Date? = nil) {
        self.id = id
        planRaw = plan.rawValue
        self.isActive = isActive
        self.renewalDate = renewalDate
    }

    var plan: SubscriptionPlan {
        SubscriptionPlan(rawValue: planRaw) ?? .free
    }
}
