import SwiftUI

struct WatchDurationPickerView: View {
    @Bindable var viewModel: WatchTimerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(viewModel.timerPresets, id: \.self) { preset in
                Button {
                    viewModel.selectedDuration = preset
                    dismiss()
                } label: {
                    HStack {
                        Text("\(preset / 60) min")
                            .font(.system(size: 17, design: .rounded))
                        Spacer()
                        if preset == viewModel.selectedDuration {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.purple)
                        }
                        if preset == 480 {
                            Text("goal")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Duration")
    }
}
