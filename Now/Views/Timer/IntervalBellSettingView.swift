import SwiftUI
import SwiftData

struct IntervalBellSettingView: View {
    @Query private var settingsArray: [AppSettings]
    @Environment(\.modelContext) private var modelContext

    private var settings: AppSettings {
        settingsArray.first ?? AppSettings()
    }

    private let options: [(label: String, value: Int)] = [
        ("Off", 0),
        ("Every 2 min", 2),
        ("Every 5 min", 5),
        ("Every 10 min", 10)
    ]

    var body: some View {
        List {
            Section {
                ForEach(options, id: \.value) { option in
                    Button {
                        settings.intervalBellMinutes = option.value
                    } label: {
                        HStack {
                            Text(option.label)
                                .foregroundStyle(Color.nowPrimary)
                            Spacer()
                            if settings.intervalBellMinutes == option.value {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.nowAccent)
                            }
                        }
                    }
                }
            } header: {
                Text("Interval Bell")
            } footer: {
                Text("A gentle bell will sound at regular intervals during your meditation session.")
            }
        }
        .navigationTitle("Interval Bell")
    }
}
