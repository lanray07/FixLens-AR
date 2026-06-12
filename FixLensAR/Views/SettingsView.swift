import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var subscriptionStore: SubscriptionStore
    @Query private var profiles: [HomeProfile]
    @Query private var appliances: [Appliance]
    @Query private var tasks: [MaintenanceTask]
    @Query private var scans: [ScanResult]
    @Query private var errorCodes: [ErrorCode]
    @Query private var transcripts: [VoiceTranscript]
    @Query private var reports: [MaintenanceReport]
    @Query private var subscriptionStates: [SubscriptionState]
    @AppStorage("voiceResponsesEnabled") private var voiceResponsesEnabled = true
    @AppStorage("arLabelsEnabled") private var arLabelsEnabled = true
    @AppStorage("maintenanceNotificationsEnabled") private var notificationsEnabled = true
    @State private var showingDeleteConfirmation = false

    var body: some View {
        List {
            Section {
                NavigationLink(value: AppRoute.paywall) {
                    SettingsRow(title: "Subscription", subtitle: subscriptionStore.activePlan.displayName, icon: "creditcard")
                }
                Toggle(isOn: $voiceResponsesEnabled) {
                    SettingsRow(title: "Voice responses", subtitle: "Speech playback and transcripts", icon: "speaker.wave.2")
                }
                Toggle(isOn: $arLabelsEnabled) {
                    SettingsRow(title: "AR labels", subtitle: "Animated arrows, labels, and step overlays", icon: "arkit")
                }
                Toggle(isOn: $notificationsEnabled) {
                    SettingsRow(title: "Notifications", subtitle: "Maintenance reminders", icon: "bell.badge")
                }
            } header: {
                Text("Preferences")
            }

            Section {
                NavigationLink(value: AppRoute.portfolio) {
                    SettingsRow(title: "Property portfolio", subtitle: "Landlord and multi-property placeholder", icon: "building.2")
                }
                NavigationLink(value: AppRoute.reports) {
                    SettingsRow(title: "PDF reports", subtitle: "Export maintenance logs", icon: "doc.richtext")
                }
            } header: {
                Text("Records")
            }

            Section {
                SettingsRow(title: "Privacy Policy", subtitle: "Placeholder document", icon: "hand.raised")
                SettingsRow(title: "Terms", subtitle: "Placeholder document", icon: "doc.plaintext")
                SettingsRow(title: "Safety Disclaimer", subtitle: SafetyPolicy.educationalDisclaimer, icon: "exclamationmark.shield")
            } header: {
                Text("Legal")
            }

            Section {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete all data", systemImage: "trash")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(PremiumBackground())
        .navigationTitle("Settings")
        .confirmationDialog("Delete all FixLens AR data?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete all data", role: .destructive) {
                deleteAllData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes local profiles, appliances, scans, transcripts, reports, and subscription cache records.")
        }
    }

    private func deleteAllData() {
        profiles.forEach { modelContext.delete($0) }
        appliances.forEach { modelContext.delete($0) }
        tasks.forEach { modelContext.delete($0) }
        scans.forEach { modelContext.delete($0) }
        errorCodes.forEach { modelContext.delete($0) }
        transcripts.forEach { modelContext.delete($0) }
        reports.forEach { modelContext.delete($0) }
        subscriptionStates.forEach { modelContext.delete($0) }
        try? modelContext.save()
        subscriptionStore.activatePreviewPlan(.free)
    }
}

private struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(FixLensTheme.electricBlue)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(FixLensTheme.secondaryText)
                    .lineLimit(2)
            }
        }
    }
}
