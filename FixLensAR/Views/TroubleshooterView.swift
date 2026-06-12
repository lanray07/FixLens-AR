import SwiftUI

struct TroubleshooterView: View {
    @EnvironmentObject private var services: AppServices
    @StateObject private var viewModel = TroubleshooterViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SectionHeader(
                    title: "AI Troubleshooter",
                    subtitle: "Cautious language, possible causes, and escalation advice.",
                    icon: "wrench.adjustable"
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

                        TextField("Error code, optional", text: $viewModel.errorCode)
                            .textInputAutocapitalization(.characters)
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        TextEditor(text: $viewModel.symptoms)
                            .scrollContentBackground(.hidden)
                            .foregroundStyle(.white)
                            .frame(minHeight: 140)
                            .padding(10)
                            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(alignment: .topLeading) {
                                if viewModel.symptoms.isEmpty {
                                    Text("Describe the symptom or attach notes...")
                                        .font(.subheadline)
                                        .foregroundStyle(.white.opacity(0.38))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 18)
                                }
                            }

                        PrimaryActionButton(title: "Analyze Safely", systemImage: "brain.head.profile", isLoading: viewModel.isLoading) {
                            Task {
                                await viewModel.troubleshoot(service: services.troubleshooting)
                            }
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(message: errorMessage)
                }

                if let result = viewModel.result {
                    TroubleshootingResultView(result: result)
                } else {
                    SafetyBanner(title: "Troubleshooting limits", warnings: SafetyPolicy.warnings(for: viewModel.selectedType))
                }
            }
            .padding(20)
        }
        .background(PremiumBackground())
        .navigationTitle("Troubleshoot")
    }
}

private struct TroubleshootingResultView: View {
    let result: TroubleshootingResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GlassCard {
                VStack(alignment: .leading, spacing: 14) {
                    Text(result.summary)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Possible causes")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                        ForEach(result.possibleCauses, id: \.self) { cause in
                            Label(cause, systemImage: "questionmark.circle")
                                .font(.caption)
                                .foregroundStyle(FixLensTheme.secondaryText)
                        }
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Maintenance actions")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                        ForEach(result.maintenanceActions, id: \.self) { action in
                            Label(action, systemImage: "checkmark.shield")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.84))
                        }
                    }
                }
            }

            SafetyBanner(title: "Escalation advice", warnings: result.warnings + [result.escalationAdvice])
        }
    }
}
