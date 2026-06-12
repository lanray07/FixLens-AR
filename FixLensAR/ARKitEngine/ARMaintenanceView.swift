import RealityKit
import SwiftUI

struct ARMaintenanceView: UIViewRepresentable {
    @ObservedObject var engine: AROverlayEngine
    let applianceType: ApplianceType

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        engine.loadSteps(for: applianceType)
        engine.configure(arView)
        engine.updateOverlay(in: arView)
        return arView
    }

    func updateUIView(_ arView: ARView, context: Context) {
        engine.updateOverlay(in: arView)
    }

    static func dismantleUIView(_ arView: ARView, coordinator: ()) {
        arView.session.pause()
    }
}
