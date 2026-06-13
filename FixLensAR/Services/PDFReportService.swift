import Foundation
import UIKit

struct MaintenanceReportPayload {
    let title: String
    let subtitle: String
    let generatedAt: Date
    let appliances: [Appliance]
    let tasks: [MaintenanceTask]
    let safetyNotes: [String]
}

final class PDFReportService {
    func makeReport(payload: MaintenanceReportPayload) throws -> URL {
        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)
        let safeTitle = payload.title.replacingOccurrences(of: " ", with: "-")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(safeTitle)-\(UUID().uuidString.prefix(8)).pdf")

        try renderer.writePDF(to: url) { context in
            context.beginPage()
            draw(payload: payload, in: pageBounds)
        }

        return url
    }

    private func draw(payload: MaintenanceReportPayload, in bounds: CGRect) {
        let margin: CGFloat = 48
        var cursorY: CGFloat = margin

        cursorY = draw("FixLens AR", at: cursorY, in: bounds, margin: margin, font: .systemFont(ofSize: 28, weight: .bold), color: .systemBlue)
        cursorY = draw(payload.title, at: cursorY + 10, in: bounds, margin: margin, font: .systemFont(ofSize: 20, weight: .semibold), color: .label)
        cursorY = draw(payload.subtitle, at: cursorY + 8, in: bounds, margin: margin, font: .systemFont(ofSize: 12), color: .secondaryLabel)
        cursorY = draw("Generated \(payload.generatedAt.formatted(date: .abbreviated, time: .shortened))", at: cursorY + 10, in: bounds, margin: margin, font: .systemFont(ofSize: 11), color: .secondaryLabel)

        cursorY += 22
        cursorY = draw("Appliance Health", at: cursorY, in: bounds, margin: margin, font: .systemFont(ofSize: 16, weight: .bold), color: .label)
        for appliance in payload.appliances.prefix(8) {
            cursorY = draw("• \(appliance.applianceType.displayName) - \(appliance.healthScore)% health - \(appliance.modelPlaceholder)", at: cursorY + 8, in: bounds, margin: margin, font: .systemFont(ofSize: 11), color: .label)
        }

        cursorY += 18
        cursorY = draw("Open Maintenance Tasks", at: cursorY, in: bounds, margin: margin, font: .systemFont(ofSize: 16, weight: .bold), color: .label)
        for task in payload.tasks.filter({ !$0.completed }).prefix(10) {
            cursorY = draw("• \(task.title) due \(task.dueDate.formatted(date: .abbreviated, time: .omitted))", at: cursorY + 8, in: bounds, margin: margin, font: .systemFont(ofSize: 11), color: .label)
        }

        cursorY += 18
        cursorY = draw("Safety Notes", at: cursorY, in: bounds, margin: margin, font: .systemFont(ofSize: 16, weight: .bold), color: .label)
        for note in payload.safetyNotes.prefix(8) {
            cursorY = draw("• \(note)", at: cursorY + 8, in: bounds, margin: margin, font: .systemFont(ofSize: 10), color: .systemRed)
        }
    }

    @discardableResult
    private func draw(_ text: String, at y: CGFloat, in bounds: CGRect, margin: CGFloat, font: UIFont, color: UIColor) -> CGFloat {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]
        let rect = CGRect(x: margin, y: y, width: bounds.width - margin * 2, height: 74)
        (text as NSString).draw(in: rect, withAttributes: attributes)
        return y + text.height(constrainedTo: rect.width, font: font) + 2
    }
}

private extension String {
    func height(constrainedTo width: CGFloat, font: UIFont) -> CGFloat {
        let rect = (self as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(rect.height)
    }
}
