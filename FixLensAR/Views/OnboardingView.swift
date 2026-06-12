import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = OnboardingViewModel()

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("FixLens AR")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Point your camera. Understand what to do next.")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(FixLensTheme.secondaryText)
                    Text("See maintenance instructions directly on the appliance.")
                        .font(.headline)
                        .foregroundStyle(FixLensTheme.emerald)
                }
                .padding(.top, 36)

                SafetyBanner(title: "Safety-first guidance", warnings: [
                    SafetyPolicy.educationalDisclaimer,
                    SafetyPolicy.professionalEscalation
                ])

                GlassCard {
                    VStack(alignment: .leading, spacing: 18) {
                        SectionHeader(title: "Your role", subtitle: "FixLens builds the dashboard around how you care for property.", icon: "person.crop.circle.badge.checkmark")
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(UserRole.allCases) { role in
                                SelectableOptionButton(
                                    title: role.rawValue,
                                    isSelected: viewModel.selectedRole == role
                                ) {
                                    viewModel.selectedRole = role
                                }
                            }
                        }
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 18) {
                        SectionHeader(title: "Property profile", subtitle: "Set the maintenance rhythm for this home.", icon: "building.2")
                        Picker("Property type", selection: $viewModel.selectedPropertyType) {
                            ForEach(PropertyType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)

                        Stepper(value: $viewModel.applianceCount, in: 1...80) {
                            HStack {
                                Text("Appliances")
                                    .foregroundStyle(.white)
                                Spacer()
                                Text("\(viewModel.applianceCount)")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(FixLensTheme.electricBlue)
                            }
                        }
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 18) {
                        SectionHeader(title: "Maintenance goals", subtitle: "Choose what FixLens should optimize for.", icon: "scope")
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(MaintenanceGoal.allCases) { goal in
                                SelectableOptionButton(
                                    title: goal.rawValue,
                                    isSelected: viewModel.selectedGoals.contains(goal)
                                ) {
                                    viewModel.toggleGoal(goal)
                                }
                            }
                        }
                    }
                }

                PrimaryActionButton(title: "Generate Home Profile", systemImage: "sparkles") {
                    viewModel.complete(context: modelContext)
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 20)
        }
        .background(PremiumBackground())
    }
}

private struct SelectableOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? .black : .white)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.horizontal, 10)
                .background(isSelected ? FixLensTheme.emerald : Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isSelected ? FixLensTheme.emerald : Color.white.opacity(0.12), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}
