//
//  OverviewRootView.swift
//  EverForm
//
//  Created by Gemini on 18/11/2025.
//

import SwiftUI

struct OverviewView: View {
  @Environment(\.colorScheme) private var scheme
  @Environment(ThemeManager.self) private var themeManager
  @State private var selectedPeriod: FocusTimeframe = .today
  @State private var isFocusPanelVisible = false

  // Layout tracking
  @State private var heroFrame: CGRect = .zero

  // Menu states
  @State private var isProfileMenuPresented = false
  @State private var isNotificationsMenuPresented = false

  // Feature presentation states
  @State private var isPresentingTraining = false
  @State private var isPresentingNutrition = false
  @State private var isPresentingRecovery = false
  @State private var isPresentingMobility = false
  @State private var isPresentingBreathwork = false
  @State private var isPresentingFixPain = false
  @State private var isPresentingLookMaxing = false
  @State private var isPresentingConnectedDevices = false
  @State private var hydrationMl = 0

  private let kpiCards = KPIItem.mock
  private let planCards = PlanItem.mock
  private let quickActions = QuickActionItem.mock
  private let hydrationTarget = 2000

  var body: some View {
    NavigationStack {
      EFScreenContainer {
        ZStack(alignment: .top) {
          // Layer 1: Main Content
          ScrollView {
            LazyVStack(spacing: 24) {
              // Top Bar (Spacer)
              Color.clear
                .frame(height: 44)
                .padding(.top, 8)

              // Hero Card
              OverviewHero(
                isFocusPanelVisible: $isFocusPanelVisible, selectedPeriod: $selectedPeriod
              )
              .padding(.horizontal, 20)
              .zIndex(100)
              .onPreferenceChange(BoundsPreferenceKey.self) { bounds in
                self.heroFrame = bounds
              }

              // Content below
              VStack(spacing: 24) {
                VStack(spacing: 16) {
                  EFSectionHeader(
                    title: "Key Metrics",
                    subtitle: metricsSubtitle
                  )
                  LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16)
                  {
                    ForEach(dynamicKPIs) { card in
                      KPICard(item: card)
                    }
                  }
                }
                .padding(.horizontal, 20)

                VStack(spacing: 16) {
                  EFSectionHeader(
                    title: "Today's Plan",
                    subtitle: "Stay on track with your preset routine",
                    actionTitle: "View All"
                  ) {
                    DebugLog.info("Overview: View All plan tapped")
                  }
                  LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12)
                  {
                    ForEach(planCards) { card in
                      OverviewPlanCard(item: card) {
                        switch card.title {
                        case "Training": isPresentingTraining = true
                        case "Nutrition": isPresentingNutrition = true
                        case "Recovery": isPresentingRecovery = true
                        case "Mobility": isPresentingMobility = true
                        default: break
                        }
                      }
                    }
                  }
                }
                .padding(.horizontal, 20)

                VStack(spacing: 16) {
                  EFSectionHeader(
                    title: "Quick Actions",
                    subtitle: "Log essentials or access tools in seconds"
                  )

                  ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                      ForEach(quickActions) { action in
                        QuickActionCard(item: action) {
                          switch action.title {
                          case "Add Water":
                            logWater()
                          case "Breathwork":
                            isPresentingBreathwork = true
                          case "Fix Pain":
                            isPresentingFixPain = true
                          case "Look Maxing":
                            isPresentingLookMaxing = true
                          default: break
                          }
                        }
                      }
                    }
                    .padding(.vertical, 2)
                  }

                  Text("Tip: Logging water right after meals keeps your hydration streak alive.")
                    .font(EverFont.caption)
                    .foregroundStyle(themeManager.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
              }
              // Scale down slightly when focus panel is open to add depth
              .scaleEffect(isFocusPanelVisible ? 0.98 : 1.0)
              .animation(.spring, value: isFocusPanelVisible)
            }
            .padding(.bottom, 32)
          }
          .scrollDisabled(isFocusPanelVisible)

          // Top Bar Layer (Always on top for hit testing, but below menus)
          VStack(spacing: 0) {
            OverviewTopBar(
              onProfileTap: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                  isProfileMenuPresented.toggle()
                  isNotificationsMenuPresented = false
                  isFocusPanelVisible = false
                }
              },
              onNotificationsTap: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                  isNotificationsMenuPresented.toggle()
                  isProfileMenuPresented = false
                  isFocusPanelVisible = false
                }
              }
            )
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer()
          }
          .zIndex(105)

          // Layer 2: Dimming Layer for Focus Panel
          if isFocusPanelVisible {
            Color.black.opacity(0.15)
              .ignoresSafeArea()
              .transition(.opacity)
              .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                  isFocusPanelVisible = false
                }
              }
              .zIndex(109)  // Just below menus (110+) but above content

            // Layer 3: Focus Overlay
            // Position logic:
            // heroFrame.maxY is the global Y coordinate of the bottom of the hero card.
            // Since ZStack is ignoring safe area or aligned to top, we can use padding to push it down.
            // We add a small gap (12pts) as requested.
            // Fallback to 220 if heroFrame isn't ready.
            let topOffset = (heroFrame.maxY > 0 ? heroFrame.maxY : 220) + 12

            FocusOverlayView(
              selection: $selectedPeriod,
              items: focusItemsForSelection
            )
            .padding(.horizontal, 16)
            .padding(.top, topOffset)
            .transition(
              .asymmetric(
                insertion: .opacity
                  .combined(with: .scale(scale: 0.95, anchor: .top))
                  .combined(with: .offset(y: -30)),
                removal: .opacity
                  .combined(with: .offset(y: -30))
              )
            )
            .zIndex(110)
          }

          // Profile Menu Overlay
          if isProfileMenuPresented {
            Color.black.opacity(0.2)
              .ignoresSafeArea()
              .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                  isProfileMenuPresented = false
                }
              }
              .zIndex(120)

            ProfileMenuPopoverView(
              isPresented: $isProfileMenuPresented,
              onConnectedDevicesTap: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                  isProfileMenuPresented = false
                  isPresentingConnectedDevices = true
                }
              }
            )
              .frame(width: 280)
              .padding(.top, 60)
              .padding(.leading, 16)
              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
              .zIndex(121)
              .transition(.opacity)
          }

          // Notifications Menu Overlay
          if isNotificationsMenuPresented {
            Color.black.opacity(0.2)
              .ignoresSafeArea()
              .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                  isNotificationsMenuPresented = false
                }
              }
              .zIndex(120)

            NotificationsPopoverView(isPresented: $isNotificationsMenuPresented)
              .frame(width: 300)
              .padding(.top, 60)
              .padding(.trailing, 16)
              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
              .zIndex(121)
              .transition(.opacity)
          }
        }
      }
      // Consolidated Navigation Logic (Push to keep TabBar visible)
      .navigationDestination(isPresented: $isPresentingTraining) {
        TrainingStartView()
      }
      .navigationDestination(isPresented: $isPresentingRecovery) {
        RecoveryStartView()
      }
      .navigationDestination(isPresented: $isPresentingNutrition) {
        NutritionStartView()
      }
      .navigationDestination(isPresented: $isPresentingMobility) {
        MobilityStartView()
      }
      .navigationDestination(isPresented: $isPresentingBreathwork) {
        BreathworkStartView()
      }
      .navigationDestination(isPresented: $isPresentingFixPain) {
        FixPainStartView()
      }
      .navigationDestination(isPresented: $isPresentingLookMaxing) {
        LookMaxingStartView()
      }
      // Connected Devices can remain a sheet if preferred, or push.
      // Keeping as sheet for now as it's a settings-like flow, or push if desired.
      // Let's push it for consistency with the "no floating content" goal.
      .navigationDestination(isPresented: $isPresentingConnectedDevices) {
        ConnectedDevicesView()
      }
    }
  }

  // Moved from extension to inside struct to avoid scope issues
  var dynamicKPIs: [KPIItem] {
    kpiCards.map { card in
      guard card.subtitle == "Hydration" else { return card }
      let progress = max(0.02, min(Double(hydrationMl) / Double(hydrationTarget), 1.0))
      let caption: String
      if hydrationMl == 0 {
        caption = "needs attention"
      } else if hydrationMl < hydrationTarget {
        caption = "\(hydrationMl) / \(hydrationTarget) ml"
      } else {
        caption = "goal met"
      }

      return KPIItem(
        icon: card.icon,
        title: "\(hydrationMl) ml",
        subtitle: card.subtitle,
        caption: caption,
        accent: card.accent,
        progress: progress
      )
    }
  }

  var focusItemsForSelection: [FocusItem] {
    switch selectedPeriod {
    case .today: return FocusItem.mockToday
    case .week: return FocusItem.mockWeek
    case .month: return FocusItem.mockMonth
    }
  }

  func logWater(amount: Int = 250) {
    hydrationMl = min(hydrationMl + amount, hydrationTarget)
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }

  var metricsSubtitle: String {
    switch selectedPeriod {
    case .today: return "Live snapshot for today"
    case .week: return "Week-to-date progress"
    case .month: return "Month-to-date progress"
    }
  }
}