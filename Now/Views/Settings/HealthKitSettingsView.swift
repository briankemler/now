import SwiftUI
import SwiftData

struct HealthKitSettingsView: View {
    @Query private var settingsArray: [AppSettings]
    @Environment(\.modelContext) private var modelContext
    @State private var healthKitService = HealthKitService()
    @State private var settingsVM = SettingsViewModel()
    @State private var notificationService = NotificationService()

    private var settings: AppSettings {
        settingsArray.first ?? AppSettings()
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Label("Status", systemImage: "heart.fill")
                        .foregroundStyle(Color.nowSuccess)
                    Spacer()
                    if healthKitService.isAuthorized {
                        Label("Connected", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(Color.nowSuccess)
                            .labelStyle(.titleOnly)
                    } else {
                        Text("Not Connected")
                            .foregroundStyle(.secondary)
                    }
                }

                if !healthKitService.isAuthorized && healthKitService.isAvailable {
                    Button {
                        Task {
                            try? await healthKitService.requestAuthorization()
                            settings.healthKitAuthorized = healthKitService.isAuthorized
                        }
                    } label: {
                        Label("Connect Apple Health", systemImage: "plus.circle")
                    }
                }
            } header: {
                Text("Apple Health Integration")
            } footer: {
                Text("When connected, your meditation sessions are saved as Mindful Minutes in Apple Health.")
            }

            if healthKitService.isAuthorized {
                Section("Sync Status") {
                    HStack {
                        Text("Sessions Synced")
                        Spacer()
                        Text("\(settingsVM.healthKitSyncedCount) of \(settingsVM.totalSessionCount)")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Button {
                    if let url = URL(string: "x-apple-health://") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open Health App", systemImage: "arrow.up.right.square")
                }
            }
        }
        .navigationTitle("Apple Health")
        .task {
            healthKitService.checkAuthorizationStatus()
            await settingsVM.refresh(
                modelContext: modelContext,
                notificationService: notificationService
            )
        }
    }
}
