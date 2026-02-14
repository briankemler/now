import SwiftUI
import SwiftData

struct GoalSettingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [UserGoal]
    @State private var selectedMinutes: Int = 8

    private var goal: UserGoal? {
        goals.first
    }

    var body: some View {
        List {
            Section {
                Picker("Daily Goal", selection: $selectedMinutes) {
                    ForEach(1...30, id: \.self) { minute in
                        Text("\(minute) \(minute == 1 ? "minute" : "minutes")").tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
            } header: {
                Text("Daily Goal")
            } footer: {
                Text("Set the number of minutes you want to meditate each day. The default is 8 minutes, based on research showing meaningful benefits at this duration.")
            }
        }
        .navigationTitle("Daily Goal")
        .onAppear {
            selectedMinutes = goal?.dailyGoalMinutes ?? 8
        }
        .onChange(of: selectedMinutes) { _, newValue in
            if let goal {
                goal.dailyGoalMinutes = newValue
                goal.modifiedDate = Date()
            } else {
                let newGoal = UserGoal(dailyGoalMinutes: newValue)
                modelContext.insert(newGoal)
            }
        }
    }
}
