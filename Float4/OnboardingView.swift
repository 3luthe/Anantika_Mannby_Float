//
//  OnboardingView.swift
//  Float4
//
//  Created by Anantika Mannby on 9/16/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var selection: Int = 0
    @Environment(\.dismiss) private var dismiss
    var isPresented: Binding<Bool>? = nil

    // Persisted onboarding state
    @AppStorage("username") private var username: String = ""
    @AppStorage("roomName") private var roomName: String = ""
    @AppStorage("selectedMoodRaw") private var selectedMoodRaw: String = FlowTheme.Mood.calm.rawValue
    @AppStorage("moodIntensity") private var moodIntensity: Double = 0.6
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("labelsEnabled") private var labelsEnabled: Bool = true
    @AppStorage("audioEnabled") private var audioEnabled: Bool = false
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false

    @State private var navigateToRoom: Bool = false
    @State private var navigateToLogin: Bool = false

    private var selectedMood: FlowTheme.Mood {
        FlowTheme.Mood(rawValue: selectedMoodRaw) ?? .calm
    }

    var body: some View {
        ZStack {
            FlowTheme.backgroundGradient(for: selectedMood, intensity: moodIntensity)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $selection) {
                    VStack(spacing: 12) {
                        Spacer()
                        Text("hi. i'm float.")
                            .font(.largeTitle.bold())
                            .foregroundStyle(FlowTheme.textPrimary)
                        Text("we'll set your space.")
                            .font(.title3)
                            .foregroundStyle(FlowTheme.textSecondary)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .tag(0)

                    VStack(spacing: 16) {
                        Spacer()
                        Text("hey \(firstName(from: username))")
                            .font(.largeTitle.bold())
                            .foregroundStyle(FlowTheme.textPrimary)
                        TextField("your name", text: $username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .onChange(of: username) { _, newValue in
                                username = newValue.lowercased()
                            }
                            .flowField()

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .tag(1)

                    VStack(spacing: 16) {
                        Spacer()
                        Text("name your room")
                            .font(.title.bold())
                            .foregroundStyle(FlowTheme.textPrimary)
                        HStack(spacing: 8) {
                            ForEach(["bubble room", "quiet corner", "drift den"], id: \.self) { suggestion in
                                Button {
                                    roomName = suggestion
                                } label: {
                                    Text(suggestion)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule().fill(FlowTheme.bg)
                                        )
                                        .overlay(
                                            Capsule().stroke(roomName == suggestion ? FlowTheme.accentPrimary : FlowTheme.stroke, lineWidth: 1)
                                        )
                                        .foregroundStyle(roomName == suggestion ? FlowTheme.accentPrimary : FlowTheme.textPrimary)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        TextField("room name", text: $roomName)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .onChange(of: roomName) { _, newValue in
                                roomName = newValue.lowercased()
                            }
                            .flowField()

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .tag(2)

                    VStack(spacing: 16) {
                        Spacer()
                        Text("choose a mood")
                            .font(.title.bold())
                            .foregroundStyle(FlowTheme.textPrimary)
                        moodGrid
                        VStack(spacing: 6) {
                            Text("intensity")
                                .font(.subheadline)
                                .foregroundStyle(FlowTheme.textSecondary)
                            Slider(value: $moodIntensity, in: 0...1)
                        }
                        .padding(.horizontal, 8)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .tag(3)

                    VStack(spacing: 16) {
                        Spacer()
                        Text("micro settings")
                            .font(.title.bold())
                            .foregroundStyle(FlowTheme.textPrimary)

                        settingsToggle(title: "Haptics", isOn: $hapticsEnabled, detail: "Subtle taps to guide actions.")
                        settingsToggle(title: "Labels", isOn: $labelsEnabled, detail: "Text labels for clarity.")
                        settingsToggle(title: "Audio", isOn: $audioEnabled, detail: "Ambient sound (mock only).")

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: selection)

                navButtons
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToRoom) {
            RoomView()
        }
        .navigationDestination(isPresented: $navigateToLogin) {
            LoginView()
        }
        .toolbar {
            if selection == 0 {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            selection = 0
        }
    }

    private var navButtons: some View {
        HStack(spacing: 12) {
            if selection > 0 {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) { 
                        selection = max(0, selection - 1) 
                    }
                } label: {
                    Text("back")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(FlowBorderedButtonStyle())
            } else {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) { 
                        selection = 4 
                    }
                } label: {
                    Text("skip")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(FlowBorderedButtonStyle())
            }

            Button {
                handlePrimary()
            } label: {
                Text(primaryTitle(for: selection))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(FlowProminentButtonStyle())
            .disabled(primaryDisabled(for: selection))
        }
    }

    private func primaryTitle(for index: Int) -> String {
        switch index {
        case 0: return "let's begin"
        case 1, 2, 3: return "next"
        default: return "enter float"
        }
    }

    private func primaryDisabled(for index: Int) -> Bool {
        switch index {
        case 1: return username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 2: return roomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default: return false
        }
    }

    private func firstName(from fullName: String) -> String {
        let trimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        let parts = trimmed.split(separator: " ")
        if let first = parts.first {
            return String(first)
        }
        return trimmed
    }

    private func handlePrimary() {
        if selection < 4 {
            withAnimation(.easeInOut(duration: 0.3)) { 
                selection += 1 
            }
        } else {
            hasOnboarded = true
            navigateToRoom = true
        }
    }

    private var moodGrid: some View {
        let moods: [FlowTheme.Mood] = [.calm, .focus, .uplift, .cozy, .night, .zen]
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(moods, id: \.self) { mood in
                Button {
                    selectedMoodRaw = mood.rawValue
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mood.displayName)
                                .font(.headline)
                                .foregroundStyle(.black)
                            Text(mood.subtitle)
                                .font(.caption)
                                .foregroundStyle(.primary)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(FlowTheme.backgroundGradient(for: mood, intensity: mood == selectedMood ? max(moodIntensity, 0.5) : 1.0))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(mood == selectedMood ? FlowTheme.accentPrimary : FlowTheme.stroke, lineWidth: mood == selectedMood ? 2 : 1)
                    )
                }
            }
        }
    }

    private func settingsToggle(title: String, isOn: Binding<Bool>, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle(title, isOn: isOn)
            Text(detail)
                .font(.caption)
                .foregroundStyle(FlowTheme.textSecondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(FlowTheme.surface)
        )
    }
}

#Preview {
    NavigationStack {
        OnboardingView()
    }
}


