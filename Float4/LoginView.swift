//
//  LoginView.swift
//  Float4
//
//  Created by Anantika Mannby on 9/16/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var navigateToOnboarding: Bool = false
    @Environment(\.dismiss) private var dismiss

    private var isEmailValid: Bool {
        // Very lightweight email check suitable for inline hinting
        email.contains("@") && email.contains(".") && email.count >= 5
    }

    private var isPasswordValid: Bool {
        password.count >= 6
    }

    private var canSubmit: Bool {
        isEmailValid && isPasswordValid
    }

    var body: some View {
        ZStack {
            FlowTheme.bg.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("login")
                    .font(.largeTitle.bold())
                    .foregroundStyle(FlowTheme.textPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    TextField("email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.next)
                        .flowField()

                    if !email.isEmpty && !isEmailValid {
                        Text("enter a valid email address")
                            .font(FlowTheme.Fonts.caption)
                            .foregroundStyle(FlowTheme.danger)
                    }

                    SecureField("password", text: $password)
                        .textContentType(.password)
                        .submitLabel(.go)
                        .flowField()

                    if !password.isEmpty && !isPasswordValid {
                        Text("password must be at least 6 characters")
                            .font(FlowTheme.Fonts.caption)
                            .foregroundStyle(FlowTheme.danger)
                    }
                }

                VStack(spacing: 12) {
                    Button {
                        if canSubmit { navigateToOnboarding = true }
                    } label: {
                        Text("log in").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(FlowProminentButtonStyle())
                    .disabled(!canSubmit)
                    .opacity(canSubmit ? 1 : 0.6)

                    Button {
                        navigateToOnboarding = true
                    } label: {
                        Text("continue as guest").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(FlowBorderedButtonStyle())
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("login")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: { Image(systemName: "chevron.backward") }
            }
        }
        .navigationDestination(isPresented: $navigateToOnboarding) {
            OnboardingView(isPresented: $navigateToOnboarding)
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}


