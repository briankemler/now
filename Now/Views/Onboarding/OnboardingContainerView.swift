import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = OnboardingViewModel()
    @State private var healthKitService = HealthKitService()
    @State private var notificationService = NotificationService()
    @State private var requestHealthKit = true

    var body: some View {
        VStack {
            TabView(selection: $viewModel.currentPage) {
                WelcomePageView()
                    .tag(0)

                GoalExplanationPageView()
                    .tag(1)

                HealthKitPermissionPageView(
                    requestHealthKit: $requestHealthKit,
                    isAvailable: healthKitService.isAvailable
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // Bottom buttons
            HStack {
                if viewModel.currentPage > 0 {
                    Button("Back") {
                        withAnimation {
                            viewModel.currentPage -= 1
                        }
                    }
                    .foregroundStyle(Color.nowSecondary)
                }

                Spacer()

                if viewModel.isLastPage {
                    Button {
                        Task {
                            await viewModel.completeOnboarding(
                                modelContext: modelContext,
                                healthKitService: healthKitService,
                                notificationService: notificationService,
                                requestHealthKit: requestHealthKit
                            )
                        }
                    } label: {
                        Text("Get Started")
                            .font(NowDesign.Typography.subheading)
                            .foregroundStyle(.white)
                            .padding(.horizontal, NowDesign.Spacing.lg)
                            .padding(.vertical, NowDesign.Spacing.md)
                            .background(Color.nowAccent)
                            .clipShape(RoundedRectangle(cornerRadius: NowDesign.Radius.md))
                    }
                } else {
                    Button {
                        withAnimation {
                            viewModel.nextPage()
                        }
                    } label: {
                        Text("Continue")
                            .font(NowDesign.Typography.subheading)
                            .foregroundStyle(.white)
                            .padding(.horizontal, NowDesign.Spacing.lg)
                            .padding(.vertical, NowDesign.Spacing.md)
                            .background(Color.nowAccent)
                            .clipShape(RoundedRectangle(cornerRadius: NowDesign.Radius.md))
                    }
                }
            }
            .padding(.horizontal, NowDesign.Spacing.lg)
            .padding(.bottom, NowDesign.Spacing.lg)
        }
    }
}
