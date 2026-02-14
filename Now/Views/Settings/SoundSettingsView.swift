import SwiftUI
import SwiftData

struct SoundSettingsView: View {
    @Query private var settingsArray: [AppSettings]

    private var settings: AppSettings {
        settingsArray.first ?? AppSettings()
    }

    var body: some View {
        List {
            Section {
                Toggle("Sound", isOn: Binding(
                    get: { settings.soundEnabled },
                    set: { settings.soundEnabled = $0 }
                ))
                .tint(Color.nowAccent)

                Toggle("Vibration", isOn: Binding(
                    get: { settings.vibrationEnabled },
                    set: { settings.vibrationEnabled = $0 }
                ))
                .tint(Color.nowAccent)
            } header: {
                Text("Session Feedback")
            } footer: {
                Text("Control whether you hear a chime and feel a vibration at the start and end of your meditation sessions.")
            }
        }
        .navigationTitle("Sound & Vibration")
    }
}
