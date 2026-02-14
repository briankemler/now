import SwiftUI
import SwiftData

struct NotificationSettingsView: View {
    @Query private var settingsArray: [AppSettings]
    @Environment(\.modelContext) private var modelContext
    @State private var notificationService = NotificationService()
    @State private var permissionGranted = false

    private var settings: AppSettings {
        settingsArray.first ?? AppSettings()
    }

    private var reminderTime: Date {
        get {
            var components = DateComponents()
            components.hour = settings.notificationHour
            components.minute = settings.notificationMinute
            return Calendar.current.date(from: components) ?? Date()
        }
        nonmutating set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            settings.notificationHour = components.hour ?? 8
            settings.notificationMinute = components.minute ?? 0
            Task {
                await notificationService.scheduleDailyReminder(
                    hour: settings.notificationHour,
                    minute: settings.notificationMinute
                )
            }
        }
    }

    var body: some View {
        List {
            Section {
                Toggle("Daily Reminder", isOn: Binding(
                    get: { settings.notificationEnabled },
                    set: { newValue in
                        settings.notificationEnabled = newValue
                        if newValue {
                            Task {
                                let granted = try? await notificationService.requestPermission()
                                if granted == true {
                                    await notificationService.scheduleDailyReminder(
                                        hour: settings.notificationHour,
                                        minute: settings.notificationMinute
                                    )
                                }
                            }
                        } else {
                            notificationService.cancelDailyReminder()
                        }
                    }
                ))
                .tint(Color.nowAccent)

                if settings.notificationEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: Binding(get: { reminderTime }, set: { reminderTime = $0 }),
                        displayedComponents: .hourAndMinute
                    )
                }
            } footer: {
                Text("Receive a gentle reminder each day at your chosen time.")
            }

            if !permissionGranted && settings.notificationEnabled {
                Section {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Enable in Settings", systemImage: "gear")
                    }
                } footer: {
                    Text("Notification permission is required. Tap to open Settings.")
                }
            }
        }
        .navigationTitle("Reminders")
        .task {
            permissionGranted = await notificationService.isPermissionGranted()
        }
    }
}
