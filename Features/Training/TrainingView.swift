//
//  TrainingView.swift
//  EverForm
//
//  Training feature page
//

import SwiftUI

struct TrainingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var journalStore: JournalStore

    @State private var selectedType: JournalTrainingType = .strength
    @State private var selectedDate = Date()
    @State private var exercises: [JournalExercise] = [JournalExercise()]
    @State private var notes = ""
    @State private var isTimerActive = false
    @State private var timerSeconds = 0
    @State private var timer: Timer?
    @State private var showingSaveConfirmation = false
    @State private var autoFocusTimer = false

    init(autoFocusTimer: Bool = false) {
        self._autoFocusTimer = State(initialValue: autoFocusTimer)
    }

    var body: some View {
        let palette = Theme.palette(colorScheme)

        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                // Plan Section
                EFCard {
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        HStack {
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(palette.accent)

                            Text("Plan")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(palette.textPrimary)

                            Spacer()
                        }

                        VStack(spacing: Theme.Spacing.md) {
                            // Training Type
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Type")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(palette.textSecondary)

                                Picker("Training Type", selection: $selectedType) {
                                    ForEach(JournalTrainingType.allCases, id: \.self) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }

                            // Date & Time
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Date & Time")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(palette.textSecondary)

                                DatePicker("", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.compact)
                            }
                        }
                    }
                }

                // Exercises Section
                EFCard {
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.orange)

                            Text("Exercises")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(palette.textPrimary)

                            Spacer()

                            Button(action: addExercise) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(palette.accent)
                            }
                            .accessibilityLabel("Add exercise")
                        }

                        ForEach(exercises.indices, id: \.self) { index in
                            ExerciseRow(
                                exercise: $exercises[index],
                                onDelete: { removeExercise(at: index) }
                            )
                        }
                    }
                }

                // Timer Section
                if isTimerActive || autoFocusTimer {
                    EFCard {
                        VStack(spacing: Theme.Spacing.md) {
                            HStack {
                                Image(systemName: "stopwatch")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(.blue)

                                Text("Workout Timer")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(palette.textPrimary)

                                Spacer()
                            }

                            Text(formatTime(timerSeconds))
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundStyle(palette.textPrimary)

                            HStack(spacing: Theme.Spacing.md) {
                                EFPillButton(
                                    title: isTimerActive ? "Pause" : "Start",
                                    style: isTimerActive ? .secondary : .primary
                                ) {
                                    toggleTimer()
                                }

                                EFPillButton(
                                    title: "Reset",
                                    style: .secondary
                                ) {
                                    resetTimer()
                                }
                            }
                        }
                    }
                }

                // Action Buttons
                VStack(spacing: Theme.Spacing.md) {
                    if !isTimerActive && !autoFocusTimer {
                        EFPillButton(
                            title: "Start Workout",
                            style: .primary,
                            color: .green
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                isTimerActive = true
                                startTimer()
                            }
                        }
                    }

                    EFPillButton(
                        title: "Save Session",
                        style: .primary
                    ) {
                        saveTrainingSession()
                    }
                    .disabled(exercises.allSatisfy { $0.name.isEmpty })
                }

                Spacer(minLength: 100)
            }
            .padding(Theme.Spacing.lg)
        }
        .background(palette.background)
        .navigationTitle("Training")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if autoFocusTimer {
                withAnimation(.spring(response: 0.3)) {
                    isTimerActive = true
                    startTimer()
                }
            }
        }
        .alert("Session Saved!", isPresented: $showingSaveConfirmation) {
            Button("OK") { }
        } message: {
            Text("Your training session has been saved successfully.")
        }
    }


    // MARK: - Helper Methods

    private func addExercise() {
        exercises.append(JournalExercise())
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }

    private func removeExercise(at index: Int) {
        exercises.remove(at: index)
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }

    private func toggleTimer() {
        if isTimerActive {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        isTimerActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timerSeconds += 1
        }

        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    private func pauseTimer() {
        isTimerActive = false
        timer?.invalidate()
        timer = nil

        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }

    private func resetTimer() {
        pauseTimer()
        timerSeconds = 0

        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    private func saveTrainingSession() {
        let validExercises = exercises.filter { !$0.name.isEmpty }

        let entry = JournalTrainingEntry(
            date: selectedDate,
            type: selectedType,
            durationMin: timerSeconds > 0 ? timerSeconds / 60 : nil,
            notes: notes.isEmpty ? nil : notes,
            exercises: validExercises
        )

        journalStore.addTraining(entry)
        showingSaveConfirmation = true

        // Reset form
        exercises = [JournalExercise()]
        notes = ""
        resetTimer()
    }
}

// MARK: - Exercise Row Component

private struct ExerciseRow: View {
    @Binding var exercise: JournalExercise
    let onDelete: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let palette = Theme.palette(colorScheme)

        VStack(spacing: 12) {
            HStack {
                TextField("Exercise name", text: $exercise.name)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 16, weight: .medium))

                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.red)
                }
                .frame(width: 44, height: 44)
                .accessibilityLabel("Remove exercise")
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sets")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(palette.textSecondary)

                    TextField("3", value: $exercise.sets, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 60)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Reps")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(palette.textSecondary)

                    TextField("10", value: $exercise.reps, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 60)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Weight (lbs)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(palette.textSecondary)

                    TextField("Optional", value: $exercise.weight, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                }

                Spacer()
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        TrainingView()
            .environmentObject(JournalStore())
    }
}
