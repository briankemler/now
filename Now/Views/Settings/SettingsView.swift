import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsArray: [AppSettings]
    @State private var viewModel = SettingsViewModel()
    @State private var notificationService = NotificationService()

    private var settings: AppSettings {
        settingsArray.first ?? AppSettings()
    }

    var body: some View {
        NavigationStack {
            List {
                // Goal
                Section("Daily Goal") {
                    NavigationLink {
                        GoalSettingView()
                    } label: {
                        HStack {
                            Label("Goal", systemImage: "target")
                            Spacer()
                            Text("\(fetchGoalMinutes()) min")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Reminders
                Section("Reminders") {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label("Daily Reminder", systemImage: "bell")
                    }
                }

                // Sound & Haptics
                Section("Sound & Haptics") {
                    NavigationLink {
                        SoundSettingsView()
                    } label: {
                        Label("Sound & Vibration", systemImage: "speaker.wave.2")
                    }

                    NavigationLink {
                        IntervalBellSettingView()
                    } label: {
                        HStack {
                            Label("Interval Bell", systemImage: "bell.badge")
                            Spacer()
                            Text(intervalBellLabel)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Health
                Section("Health") {
                    NavigationLink {
                        HealthKitSettingsView()
                    } label: {
                        HStack {
                            Label("Apple Health", systemImage: "heart.fill")
                                .foregroundStyle(Color.nowSuccess)
                            Spacer()
                            Text(settings.healthKitAuthorized ? "Connected" : "Not Connected")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "https://now-meditation.app/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                }
            }
            .navigationTitle("Settings")
            .task {
                await viewModel.refresh(
                    modelContext: modelContext,
                    notificationService: notificationService
                )
            }
        }
    }

    private var intervalBellLabel: String {
        let interval = settings.intervalBellMinutes
        if interval == 0 { return "Off" }
        return "Every \(interval) min"
    }

    private func fetchGoalMinutes() -> Int {
        let descriptor = FetchDescriptor<UserGoal>()
        let goals = (try? modelContext.fetch(descriptor)) ?? []
        return goals.first?.dailyGoalMinutes ?? 8
    }
}
