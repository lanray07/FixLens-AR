import SwiftData
import SwiftUI

struct VoiceAssistantView: View {
    @EnvironmentObject private var services: AppServices
    @EnvironmentObject private var speech: SpeechRecognitionService
    @EnvironmentObject private var recording: VoiceRecordingService
    @EnvironmentObject private var waveform: WaveformAnimationManager
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = VoiceAssistantViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SectionHeader(
                    title: "Voice Guidance",
                    subtitle: "Ask maintenance questions, hear responses, and save transcripts.",
                    icon: "waveform.circle"
                )

                GlassCard {
                    VStack(spacing: 18) {
                        VoiceWaveformView(samples: waveform.samples)
                        Picker("Appliance", selection: $viewModel.selectedType) {
                            ForEach(ApplianceType.allCases.filter { $0 != .unknown }) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)

                        HStack(spacing: 12) {
                            Button {
                                if recording.isRecording {
                                    viewModel.stopListening(speech: speech, recording: recording, waveform: waveform)
                                } else {
                                    viewModel.startListening(speech: speech, recording: recording, waveform: waveform)
                                }
                            } label: {
                                Label(recording.isRecording ? "Stop" : "Listen", systemImage: recording.isRecording ? "stop.fill" : "mic.fill")
                                    .font(.headline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                    .background(recording.isRecording ? FixLensTheme.danger : FixLensTheme.electricBlue, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                                    .foregroundStyle(.white)
                            }
                            .buttonStyle(.plain)

                            Button {
                                Task {
                                    await viewModel.submit(service: services.voiceAssistant, context: modelContext)
                                }
                            } label: {
                                Label("Ask", systemImage: "arrow.up.circle.fill")
                                    .font(.headline.weight(.semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                    .background(FixLensTheme.emerald, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                                    .foregroundStyle(.black)
                            }
                            .buttonStyle(.plain)
                            .disabled(viewModel.isProcessing)
                        }
                    }
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Live transcription")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                        TextEditor(text: $viewModel.transcript)
                            .scrollContentBackground(.hidden)
                            .foregroundStyle(.white)
                            .frame(minHeight: 120)
                            .padding(10)
                            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }

                if viewModel.isProcessing {
                    LoadingStateView(title: "Preparing safe voice guidance")
                }

                if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(message: errorMessage)
                }

                if let response = viewModel.response {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeader(title: response.summary, icon: "speaker.wave.2.fill")
                            ForEach(response.suggestedActions, id: \.self) { action in
                                Label(action, systemImage: "checkmark.shield")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.84))
                            }
                        }
                    }
                    SafetyBanner(title: "Voice safety limits", warnings: response.warnings)
                }
            }
            .padding(20)
        }
        .background(PremiumBackground())
        .navigationTitle("Voice")
        .task {
            await speech.requestAuthorization()
        }
    }
}
