//
//  MobilityView.swift
//  EverForm
//
//  Mobility feature page
//

import SwiftUI

struct MobilityView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var journalStore: JournalStore

    @State private var selectedDate = Date()
    @State private var selectedRegions: Set<JournalBodyRegion> = []
    @State private var routineSteps = JournalMobilityStep.defaultSteps
    @State private var selectedDuration = 10
    @State private var isSessionActive = false
    @State private var sessionSeconds = 0
    @State private var timer: Timer?
    @State private var showingSaveConfirmation = false
    @State private var autoStartSession = false

    private let durations = [5, 10, 15, 20, 30]

    init(autoStartSession: Bool = false) {
        self._autoStartSession = State(initialValue: autoStartSession)
    }

    var body: some View {
        let palette = Theme.palette(colorScheme)

        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                // Focus Section
                EFCard {
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        HStack {
                            Image(systemName: "figure.flexibility")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.purple)

                            Text("Focus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(palette.textPrimary)

                            Spacer()
                        }

                        VStack(spacing: Theme.Spacing.md) {
                            Text("Select body regions to focus on")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(palette.textSecondary)

                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 8),
                                GridItem(.flexible(), spacing: 8),
                                GridItem(.flexible(), spacing: 8)
                            ], spacing: 8) {
                                ForEach(JournalBodyRegion.allCases, id: \.self) { region in
                                    Button(action: {
                                        toggleRegion(region)
                                    }) {
                                        Text(region.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(selectedRegions.contains(region) ? .white : palette.textPrimary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(selectedRegions.contains(region) ? palette.accent : palette.surface)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(palette.stroke, lineWidth: selectedRegions.contains(region) ? 0 : 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .frame(minHeight: 44)
                                }
                            }
                        }
                    }
                }

                // Routine Section
                EFCard {
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.green)

                            Text("Routine")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(palette.textPrimary)

                            Spacer()

                            Button(action: addRoutineStep) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(palette.accent)
                            }
                            .accessibilityLabel("Add routine step")
                        }

                        ForEach(routineSteps.indices, id: \.self) { index in
                            MobilityStepRow(
                                step: $routineSteps[index],
                                onDelete: { removeRoutineStep(at: index) }
                            )
                        }
                    }
                }

                // Session Section
                if isSessionActive {
                    EFCard {
                        VStack(spacing: Theme.Spacing.md) {
                            HStack {
                                Image(systemName: "timer")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(.orange)

                                Text("Session Active")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(palette.textPrimary)

                                Spacer()
                            }

                            Text(formatTime(sessionSeconds))
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundStyle(palette.textPrimary)

                            HStack(spacing: Theme.Spacing.md) {
                                EFPillButton(
                                    title: "Pause",
                                    style: .secondary
                                ) {
                                    pauseSession()
                                }

                                EFPillButton(
                                    title: "Complete",
                                    style: .primary,
                                    color: .green
                                ) {
                                    completeSession()
                                }
                            }
                        }
                    }
                }

                // Action Buttons
                VStack(spacing: Theme.Spacing.md) {
                    if !isSessionActive {
                        // Duration picker
                        EFCard {
                            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                                Text("Session Duration")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(palette.textPrimary)

                                Picker("Duration", selection: $selectedDuration) {
                                    ForEach(durations, id: \.self) { duration in
                                        Text("\(duration) min").tag(duration)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }

                        EFPillButton(
                            title: "Start Session",
                            style: .primary,
                            color: .purple
                        ) {
                            startSession()
                        }
                        .disabled(selectedRegions.isEmpty)
                    }

                    if !isSessionActive {
                        EFPillButton(
                            title: "Save Routine",
                            style: .primary
                        ) {
                            saveMobility()
                        }
                        .disabled(selectedRegions.isEmpty)
                    }
                }

                Spacer(minLength: 100)
            }
            .padding(Theme.Spacing.lg)
        }
        .background(palette.background)
        .navigationTitle("Mobility")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if autoStartSession {
                startSession()
            }
        }
        .alert("Mobility Saved!", isPresented: $showingSaveConfirmation) {
            Button("OK") { }
        } message: {
            Text("Your mobility session has been saved successfully.")
        }
    }


    // MARK: - Helper Methods

    private func toggleRegion(_ region: JournalBodyRegion) {
        if selectedRegions.contains(region) {
            selectedRegions.remove(region)
        } else {
            selectedRegions.insert(region)
        }

        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }

    private func addRoutineStep() {
        routineSteps.append(JournalMobilityStep(title: "", repsOrSecs: "30s"))
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }

    private func removeRoutineStep(at index: Int) {
        routineSteps.remove(at: index)
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }

    private func startSession() {
        isSessionActive = true
        sessionSeconds = selectedDuration * 60

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if sessionSeconds > 0 {
                sessionSeconds -= 1
            } else {
                completeSession()
            }
        }

        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    private func pauseSession() {
        isSessionActive = false
        timer?.invalidate()
        timer = nil

        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }

    private func completeSession() {
        pauseSession()
        sessionSeconds = 0

        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        // Auto-save when session completes
        saveMobility()
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    private func saveMobility() {
        let entry = JournalMobilityEntry(
            date: selectedDate,
            focusAreas: Array(selectedRegions),
            durationMin: selectedDuration,
            routine: routineSteps.filter { !$0.title.isEmpty }
        )

        journalStore.addMobility(entry)
        showingSaveConfirmation = true

        // Reset form
        selectedRegions.removeAll()
        routineSteps = JournalMobilityStep.defaultSteps
    }
}

// MARK: - Mobility Step Row Component

private struct MobilityStepRow: View {
    @Binding var step: JournalMobilityStep
    let onDelete: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let palette = Theme.palette(colorScheme)

        VStack(spacing: 8) {
            HStack {
                TextField("Exercise name", text: $step.title)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 16, weight: .medium))

                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.red)
                }
                .frame(width: 44, height: 44)
                .accessibilityLabel("Remove step")
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration/Reps")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(palette.textSecondary)

                    TextField("30s", text: $step.repsOrSecs)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                }

                Spacer()
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        MobilityView()
            .environmentObject(JournalStore())
    }
}
