import ARKit
import Foundation
import RealityKit
import UIKit

@MainActor
final class AROverlayEngine: ObservableObject {
    @Published var instructionSteps: [ARInstructionStep] = []
    @Published var trackingState = "Move the camera toward the appliance"
    @Published var isARSupported = ARWorldTrackingConfiguration.isSupported

    private var placedOverlay = false

    func loadSteps(for applianceType: ApplianceType) {
        instructionSteps = ComponentLabelingEngine().steps(for: applianceType)
    }

    func configure(_ arView: ARView) {
        arView.environment.background = .cameraFeed()

        guard ARWorldTrackingConfiguration.isSupported else {
            trackingState = "AR is unavailable on this simulator or device"
            return
        }

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
        trackingState = "Tracking appliance surfaces"
    }

    func updateOverlay(in arView: ARView) {
        guard !placedOverlay else { return }
        placedOverlay = true

        let anchor = AnchorEntity(world: SIMD3<Float>(0, -0.12, -0.72))
        for (index, step) in instructionSteps.enumerated() {
            let marker = ModelEntity(
                mesh: .generateBox(size: SIMD3<Float>(0.05, 0.05, 0.012)),
                materials: [SimpleMaterial(color: step.isWarningZone ? UIColor.systemOrange : UIColor.systemCyan, isMetallic: false)]
            )
            marker.name = step.component
            marker.position = SIMD3<Float>(Float(index) * 0.09 - 0.13, Float(index % 2) * 0.08, 0)
            anchor.addChild(marker)

            let pointer = ModelEntity(
                mesh: .generateBox(size: SIMD3<Float>(0.012, 0.012, 0.22)),
                materials: [SimpleMaterial(color: UIColor.systemGreen.withAlphaComponent(0.86), isMetallic: false)]
            )
            pointer.position = SIMD3<Float>(marker.position.x, marker.position.y - 0.08, -0.08)
            pointer.orientation = simd_quatf(angle: .pi / 4, axis: SIMD3<Float>(1, 0, 0))
            anchor.addChild(pointer)
        }

        arView.scene.addAnchor(anchor)
        trackingState = "AR maintenance labels active"
    }

    func pause(_ arView: ARView) {
        arView.session.pause()
        placedOverlay = false
    }
}

final class ApplianceTrackingEngine {
    func trackingHint(for applianceType: ApplianceType) -> String {
        if applianceType.isHighRisk {
            return "Keep distance and scan external labels, controls, and warning indicators only."
        }
        return "Center the appliance and move slowly so FixLens can identify visible maintenance components."
    }
}

final class ComponentLabelingEngine {
    func steps(for applianceType: ApplianceType) -> [ARInstructionStep] {
        applianceType.maintenanceComponents.enumerated().map { index, component in
            ARInstructionStep(
                number: index + 1,
                component: component,
                title: component,
                detail: detail(for: component, applianceType: applianceType),
                isWarningZone: applianceType.isHighRisk && index > 1
            )
        }
    }

    private func detail(for component: String, applianceType: ApplianceType) -> String {
        if applianceType.isHighRisk {
            return "Identify this external area only. Stop before covers, sealed parts, gas, electrical, or high-voltage components."
        }
        return "Inspect this area for debris, wear, warning indicators, or cleaning needs approved by the manufacturer."
    }
}
