//
//  RoomView.swift
//  Float4
//
//  Created by Anantika Mannby on 9/16/25.
//

import SwiftUI

struct RoomView: View {
    @AppStorage("username") private var username: String = ""
    @AppStorage("roomName") private var roomName: String = ""
    @AppStorage("selectedMoodRaw") private var selectedMoodRaw: String = FlowTheme.Mood.calm.rawValue
    @AppStorage("moodIntensity") private var moodIntensity: Double = 0.6
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = true

    @State private var isInhaling: Bool = false
    @State private var isShowingMoodSheet: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var inhaleStartDate: Date? = nil
    @State private var isExhaling: Bool = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var isPressing: Bool = false
    @State private var exhaleTask: Task<Void, Never>? = nil
    @State private var navigateToOnboarding: Bool = false
    @State private var scaleTimer: Timer? = nil

    private let maxScaleDelta: CGFloat = 0.3
    private let inhaleTargetSeconds: Double = 3.0
    private let minExhaleSeconds: Double = 0.5
    private let maxExhaleSeconds: Double = 8.0

    private var selectedMood: FlowTheme.Mood {
        FlowTheme.Mood(rawValue: selectedMoodRaw) ?? .calm
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            FlowTheme.backgroundGradient(for: selectedMood, intensity: moodIntensity)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Button { isShowingMoodSheet = true } label: { Text("change mood") }
                        .buttonStyle(FlowBorderedButtonStyle())
                }
                .padding([.top, .horizontal])

                Spacer()

                VStack(spacing: 12) {
                    TimelineView(.animation) { context in
                        ZStack {
                            Button { } label: {
                                ZStack {
                                    Circle()
                                        .fill(.regularMaterial)
                                        .opacity(isPressing ? 0.95 : 1.0)
                                        .frame(width: 200, height: 200)
                                    Text(isExhaling ? "Exhale" : (isPressing ? "Inhale" : "Hold to inhale"))
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(.primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule(style: .continuous)
                                                .fill(.thinMaterial)
                                        )
                                }
                            }
                            .scaleEffect(buttonScale)
                            .onLongPressGesture(minimumDuration: 0, maximumDistance: 60, pressing: { pressing in
                                if pressing {
                                    exhaleTask?.cancel()
                                    isExhaling = false
                                    if !isPressing {
                                        inhaleStartDate = Date()
                                    }
                                    isPressing = true
                                    isInhaling = true
                                } else {
                                    guard isPressing else { return }
                                    isPressing = false
                                    isInhaling = false
                                    let held = max(0, Date().timeIntervalSince(inhaleStartDate ?? Date()))
                                    inhaleStartDate = nil
                                    let exhaleDuration = min(max(held, minExhaleSeconds), maxExhaleSeconds)
                                    isExhaling = true
                                    exhaleTask?.cancel()
                                    exhaleTask = Task {
                                        await MainActor.run {
                                            withAnimation(.easeInOut(duration: exhaleDuration)) {
                                                buttonScale = 1.0
                                            }
                                        }
                                        try? await Task.sleep(nanoseconds: UInt64(exhaleDuration * 1_000_000_000))
                                        if !Task.isCancelled {
                                            await MainActor.run {
                                                isExhaling = false
                                            }
                                        }
                                    }
                                }
                            }, perform: { })
                        }
                        .onChange(of: context.date) { _, newDate in
                            if isPressing, let start = inhaleStartDate {
                                let elapsed = max(0, newDate.timeIntervalSince(start))
                                let progress = min(elapsed / inhaleTargetSeconds, 1.0)
                                let targetScale = 1.0 + maxScaleDelta * progress
                                if abs(targetScale - buttonScale) > 0.0001 {
                                    buttonScale = targetScale
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
        }
        .navigationTitle(roomName.isEmpty ? "your room" : roomName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
            }
        }
        .sheet(isPresented: $isShowingMoodSheet) {
            MoodSheet(
                selectedMoodRaw: $selectedMoodRaw,
                moodIntensity: $moodIntensity
            )
            .presentationDetents([.medium])
        }
        .navigationDestination(isPresented: $navigateToOnboarding) {
            OnboardingView(isPresented: $navigateToOnboarding)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
        }
        .onDisappear {
            scaleTimer?.invalidate()
            exhaleTask?.cancel()
        }
    }
}

#Preview {
    NavigationStack {
        RoomView()
    }
}

private struct MoodSheet: View {
    @Binding var selectedMoodRaw: String
    @Binding var moodIntensity: Double
    @Environment(\.dismiss) private var dismiss

    private var selectedMood: FlowTheme.Mood {
        FlowTheme.Mood(rawValue: selectedMoodRaw) ?? .calm
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("change mood")
                    .font(.title2.bold())
                    .foregroundStyle(FlowTheme.textPrimary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach([FlowTheme.Mood.calm, .focus, .uplift, .cozy, .night, .zen], id: \.self) { mood in
                        Button {
                            selectedMoodRaw = mood.rawValue
                        } label: {
                            HStack {
                                Text(mood.displayName)
                                    .foregroundStyle(FlowTheme.textPrimary)
                                Spacer()
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, minHeight: 64)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(FlowTheme.backgroundGradient(for: mood, intensity: moodIntensity))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(mood.rawValue == selectedMoodRaw ? FlowTheme.accentPrimary : FlowTheme.stroke, lineWidth: mood.rawValue == selectedMoodRaw ? 2 : 1)
                            )
                        }
                    }
                }

                VStack(spacing: 6) {
                    Text("intensity")
                        .font(.subheadline)
                        .foregroundStyle(FlowTheme.textSecondary)
                    Slider(value: $moodIntensity, in: 0...1)
                }
                .padding(.horizontal, 8)

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done") { dismiss() }
                }
            }
        }
    }
}


