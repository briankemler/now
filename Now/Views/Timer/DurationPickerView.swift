import SwiftUI

struct DurationPickerView: View {
    @Binding var selectedDuration: Int
    @State private var showCustomPicker = false
    @State private var customMinutes: Int = 10
    var onStart: (Int) -> Void

    private let presets = NowDesign.timerPresets
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: NowDesign.Spacing.lg) {
            Text("Choose Duration")
                .font(NowDesign.Typography.heading)
                .foregroundStyle(Color.nowPrimary)

            LazyVGrid(columns: columns, spacing: NowDesign.Spacing.md) {
                ForEach(presets, id: \.self) { preset in
                    presetButton(preset)
                }
            }

            Button {
                showCustomPicker = true
            } label: {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Custom")
                }
                .font(NowDesign.Typography.subheading)
                .foregroundStyle(Color.nowAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, NowDesign.Spacing.md)
                .background(Color.nowAccent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: NowDesign.Radius.md))
            }
            .accessibilityLabel("Set custom duration")
        }
        .padding(NowDesign.Spacing.lg)
        .sheet(isPresented: $showCustomPicker) {
            customPickerSheet
        }
    }

    private func presetButton(_ preset: Int) -> some View {
        let isSelected = selectedDuration == preset
        let label = NowDesign.timerPresetLabels[preset] ?? "\(preset / 60) min"
        let isDefault = preset == 480

        return Button {
            selectedDuration = preset
            onStart(preset)
        } label: {
            VStack(spacing: NowDesign.Spacing.xs) {
                Text(label)
                    .font(NowDesign.Typography.subheading)
                if isDefault {
                    Text("goal")
                        .font(NowDesign.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, NowDesign.Spacing.md)
            .background(isSelected ? Color.nowAccent : Color.nowAccent.opacity(0.1))
            .foregroundStyle(isSelected ? .white : Color.nowAccent)
            .clipShape(RoundedRectangle(cornerRadius: NowDesign.Radius.md))
        }
        .accessibilityLabel("\(label)\(isDefault ? ", daily goal" : "")")
    }

    private var customPickerSheet: some View {
        NavigationStack {
            VStack(spacing: NowDesign.Spacing.lg) {
                Text("Custom Duration")
                    .font(NowDesign.Typography.heading)

                Picker("Minutes", selection: $customMinutes) {
                    ForEach(1...60, id: \.self) { minute in
                        Text("\(minute) min").tag(minute)
                    }
                }
                .pickerStyle(.wheel)

                Button {
                    let duration = customMinutes * 60
                    selectedDuration = duration
                    showCustomPicker = false
                    onStart(duration)
                } label: {
                    Text("Start")
                        .font(NowDesign.Typography.subheading)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, NowDesign.Spacing.md)
                        .background(Color.nowAccent)
                        .clipShape(RoundedRectangle(cornerRadius: NowDesign.Radius.md))
                }
            }
            .padding(NowDesign.Spacing.lg)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showCustomPicker = false }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
