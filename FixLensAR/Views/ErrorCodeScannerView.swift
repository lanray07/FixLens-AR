import SwiftData
import SwiftUI

struct ErrorCodeScannerView: View {
    @EnvironmentObject private var services: AppServices
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ErrorCodeScannerViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SectionHeader(
                    title: "Error Code Scanner",
                    subtitle: "OCR architecture for appliance displays and warning indicators.",
                    icon: "text.viewfinder"
                )

                GlassCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Picker("Appliance", selection: $viewModel.selectedType) {
                            ForEach(ApplianceType.allCases.filter { $0 != .unknown }) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)

                        TextField("Code", text: $viewModel.code)
                            .textInputAutocapitalization(.characters)
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        HStack(spacing: 12) {
                            Button {
                                Task { await viewModel.mockScanDisplay() }
                            } label: {
                                Label("Mock OCR", systemImage: "viewfinder")
                                    .font(.headline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                    .background(FixLensTheme.electricBlue, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                                    .foregroundStyle(.white)
                            }
                            .buttonStyle(.plain)

                            Button {
                                Task {
                                    await viewModel.interpret(service: services.errorCodes, context: modelContext)
                                }
                            } label: {
                                Label("Explain", systemImage: "sparkles")
                                    .font(.headline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                    .background(FixLensTheme.emerald, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                                    .foregroundStyle(.black)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if !viewModel.recognizedText.isEmpty {
                    ReportPreviewView(title: "Recognized display text", rows: viewModel.recognizedText)
                }

                if viewModel.isLoading {
                    LoadingStateView(title: "Interpreting code")
                }

                if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(message: errorMessage)
                }

                if let result = viewModel.result {
                    ErrorCodeCard(result: result)
                    SafetyBanner(title: "Error-code safety guidance", warnings: result.warnings + [result.escalationAdvice])
                }
            }
            .padding(20)
        }
        .background(PremiumBackground())
        .navigationTitle("Error Code")
    }
}
