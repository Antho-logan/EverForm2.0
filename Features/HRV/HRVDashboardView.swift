//
//  HRVDashboardView.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

// TODO: Candidate for removal – appears unused in current EverForm flow.
import SwiftUI

struct HRVDashboardView: View {
  @StateObject private var viewModel = HRVDashboardViewModel()

  var body: some View {
    NavigationStack {
      ZStack {
        DesignSystem.Colors.background.ignoresSafeArea()

        ScrollView {
          VStack(spacing: 24) {

            // 1. Today Summary Card
            TodaySummaryCard(viewModel: viewModel)

            // 2. Trends Section
            VStack(spacing: 16) {
              HStack {
                Text("Trends")
                  .font(.app(.title))
                  .foregroundStyle(DesignSystem.Colors.textPrimary)
                Spacer()
                TimeRangePicker(selection: $viewModel.selectedTimeRange) {
                  viewModel.updateTimeRange($0)
                }
              }

              MetricSelector(selected: $viewModel.selectedMetric) {
                viewModel.updateMetric($0)
              }

              TrendChartCard(viewModel: viewModel)
            }

            // 3. Subjective State
            VStack(alignment: .leading, spacing: 16) {
              Text("Subjective State")
                .font(.app(.title))
                .foregroundStyle(DesignSystem.Colors.textPrimary)

              SubjectiveGrid(logs: viewModel.subjectiveLogs)
            }

            // 4. Active Recovery
            VStack(alignment: .leading, spacing: 16) {
              Text("Active Recovery")
                .font(.app(.title))
                .foregroundStyle(DesignSystem.Colors.textPrimary)

              RecoveryGrid(actions: viewModel.quickActions) { action in
                viewModel.logAction(action)
              }
            }

            // 5. Breathing Protocols
            VStack(alignment: .leading, spacing: 16) {
              Text("Breathing Protocols")
                .font(.app(.title))
                .foregroundStyle(DesignSystem.Colors.textPrimary)

              ForEach(viewModel.protocols) { protocolItem in
                ProtocolRow(protocolItem: protocolItem) {
                  viewModel.startSession()
                }
              }
            }

            // 6. Education Entry
            Button {
              viewModel.showingEducation = true
            } label: {
              HStack {
                Image(systemName: "info.circle")
                Text("What is HRV Biofeedback?")
              }
              .font(.app(.button))
              .foregroundStyle(DesignSystem.Colors.textSecondary)
              .padding()
            }

            Spacer(minLength: 40)
          }
          .padding(20)
        }
      }
      .navigationTitle("HRV Biofeedback")
      .navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $viewModel.showingEducation) {
        HRVEducationSheet()
      }
    }
  }
}

// MARK: - Subviews

struct TodaySummaryCard: View {
  @ObservedObject var viewModel: HRVDashboardViewModel

  var body: some View {
    EFCard(
      style: .gradient(
        LinearGradient(
          colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.5)], startPoint: .topLeading,
          endPoint: .bottomTrailing))
    ) {
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("Today's Session")
              .font(.app(.heading))
              .foregroundStyle(.white)
            Text(Date().formatted(date: .abbreviated, time: .omitted))
              .font(.app(.caption))
              .foregroundStyle(.white.opacity(0.8))
          }
          Spacer()
          if viewModel.isSessionCompletedToday {
            Label("Completed", systemImage: "checkmark.circle.fill")
              .font(.app(.caption))
              .foregroundStyle(.green)
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(.white.opacity(0.2))
              .clipShape(Capsule())
          } else {
            Label("Not done yet", systemImage: "circle")
              .font(.app(.caption))
              .foregroundStyle(.white.opacity(0.8))
          }
        }

        if viewModel.isSessionCompletedToday {
          HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
              Text("+12 ms")
                .font(.app(.largeTitle))
                .foregroundStyle(.white)
              Text("rMSSD Change")
                .font(.app(.caption))
                .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            MicroSparkline(data: [45, 48, 46, 52, 55, 53, 58], color: .white)
              .frame(width: 80, height: 40)
          }
        } else {
          Text("Take a moment to breathe and reset your nervous system.")
            .font(.app(.bodySecondary))
            .foregroundStyle(.white.opacity(0.9))
            .fixedSize(horizontal: false, vertical: true)
        }

        HStack(spacing: 12) {
          Button {
            viewModel.startSession()
          } label: {
            Text("Start Session")
              .font(.app(.button))
              .frame(maxWidth: .infinity)
              .padding(.vertical, 12)
              .background(Color.white)
              .foregroundStyle(Color.purple)
              .clipShape(RoundedRectangle(cornerRadius: 12))
          }

          Button {
            // Scroll to protocols (stub)
          } label: {
            Text("Choose Protocol")
              .font(.app(.button))
              .padding(.horizontal, 16)
              .padding(.vertical, 12)
              .background(.white.opacity(0.2))
              .foregroundStyle(.white)
              .clipShape(RoundedRectangle(cornerRadius: 12))
          }
        }
      }
    }
  }
}

struct TimeRangePicker: View {
  @Binding var selection: HRVTimeRange
  let onChange: (HRVTimeRange) -> Void

  var body: some View {
    Picker("Time Range", selection: $selection) {
      ForEach(HRVTimeRange.allCases) { range in
        Text(range.rawValue).tag(range)
      }
    }
    .pickerStyle(.segmented)
    .frame(width: 160)
    .onChange(of: selection) { newValue in
      onChange(newValue)
    }
  }
}

struct MetricSelector: View {
  @Binding var selected: HRVMetricType
  let onChange: (HRVMetricType) -> Void

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(HRVMetricType.allCases) { metric in
          Button {
            selected = metric
            onChange(metric)
          } label: {
            Text(metric.rawValue)
              .font(.app(.caption))
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .background(
                selected == metric
                  ? DesignSystem.Colors.accent : DesignSystem.Colors.backgroundSecondary
              )
              .foregroundStyle(selected == metric ? .white : DesignSystem.Colors.textSecondary)
              .clipShape(Capsule())
          }
        }
      }
    }
  }
}

struct TrendChartCard: View {
  @ObservedObject var viewModel: HRVDashboardViewModel

  var body: some View {
    EFCard {
      VStack(alignment: .leading, spacing: 16) {
        HStack(alignment: .firstTextBaseline) {
          Text(viewModel.currentMetricValue)
            .font(.app(.largeTitle))
            .foregroundStyle(DesignSystem.Colors.textPrimary)
          Text(viewModel.currentMetricUnit)
            .font(.app(.bodySecondary))
            .foregroundStyle(DesignSystem.Colors.textSecondary)

          Spacer()

          HStack(spacing: 4) {
            Image(systemName: viewModel.trendIcon)
            Text(viewModel.trendDescription)
          }
          .font(.app(.caption))
          .foregroundStyle(viewModel.trendColor)
          .padding(6)
          .background(viewModel.trendColor.opacity(0.1))
          .clipShape(Capsule())
        }

        HRVLineChart(
          data: viewModel.trendData, lineColor: DesignSystem.Colors.accent, showGradient: true
        )
        .frame(height: 150)
      }
    }
  }
}

struct SubjectiveGrid: View {
  let logs: [SubjectiveLog]

  let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  var body: some View {
    LazyVGrid(columns: columns, spacing: 12) {
      ForEach(logs) { log in
        EFCard(style: .standard) {
          VStack(alignment: .leading, spacing: 8) {
            Text(log.type.rawValue)
              .font(.app(.caption))
              .foregroundStyle(DesignSystem.Colors.textSecondary)

            HStack {
              Text(log.value)
                .font(.app(.heading))
                .foregroundStyle(DesignSystem.Colors.textPrimary)
              Spacer()
              // Micro trend indicator
              Image(
                systemName: log.trend == .up
                  ? "arrow.up.right" : (log.trend == .down ? "arrow.down.right" : "minus")
              )
              .font(.caption)
              .foregroundStyle(DesignSystem.Colors.neutral300)
            }
          }
        }
      }
    }
  }
}

struct RecoveryGrid: View {
  let actions: [HRVQuickAction]
  let onTap: (HRVQuickAction) -> Void

  let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  var body: some View {
    LazyVGrid(columns: columns, spacing: 12) {
      ForEach(actions) { action in
        Button {
          onTap(action)
        } label: {
          VStack(spacing: 8) {
            Image(systemName: action.icon)
              .font(.system(size: 24))
              .foregroundStyle(DesignSystem.Colors.accent)
            Text(action.title)
              .font(.app(.caption))
              .foregroundStyle(DesignSystem.Colors.textPrimary)
              .multilineTextAlignment(.center)
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
          .background(DesignSystem.Colors.cardBackground)
          .clipShape(RoundedRectangle(cornerRadius: 16))
        }
      }
    }
  }
}

struct ProtocolRow: View {
  let protocolItem: BreathingProtocol
  let onTap: () -> Void

  var body: some View {
    Button {
      onTap()
    } label: {
      EFCard {
        HStack(spacing: 16) {
          Circle()
            .fill(protocolItem.color.opacity(0.2))
            .frame(width: 48, height: 48)
            .overlay(
              Image(systemName: "lungs.fill")
                .foregroundStyle(protocolItem.color)
            )

          VStack(alignment: .leading, spacing: 4) {
            HStack {
              Text(protocolItem.name)
                .font(.app(.heading))
                .foregroundStyle(DesignSystem.Colors.textPrimary)
              Spacer()
              Text("\(protocolItem.durationMinutes) min")
                .font(.app(.caption))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            }

            Text(protocolItem.description)
              .font(.app(.bodySecondary))
              .foregroundStyle(DesignSystem.Colors.textSecondary)
              .lineLimit(1)

            Text(protocolItem.targetTag)
              .font(.app(.caption))
              .foregroundStyle(protocolItem.color)
              .padding(.top, 2)
          }
        }
      }
    }
  }
}
