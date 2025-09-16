//
//  ContentView.swift
//  Float4
//
//  Created by Anantika Mannby on 9/16/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingLearnMore: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                FlowTheme.bg.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    Text("float")
                        .font(FlowTheme.Fonts.display(56))
                        .foregroundStyle(FlowTheme.textPrimary)

                    Spacer()

                    VStack(spacing: 12) {
                        NavigationLink {
                            LoginView()
                        } label: {
                            Text("get started").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(FlowProminentButtonStyle())

                        Button {
                            isShowingLearnMore = true
                        } label: {
                            Text("learn more").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(FlowBorderedButtonStyle())
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    Text("v1.0 • made with care")
                        .font(.footnote)
                        .foregroundStyle(FlowTheme.textSecondary)
                }
                .padding(.vertical, 24)

                if isShowingLearnMore {
                    Color.black.opacity(0.2).ignoresSafeArea().transition(.opacity)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Spacer()
                            Button {
                                withAnimation { isShowingLearnMore = false }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(8)
                                    .foregroundStyle(FlowTheme.textPrimary)
                            }
                        }

                        Text("welcome to float").font(FlowTheme.Fonts.headline).foregroundStyle(FlowTheme.textPrimary)
                        Text("set your name, room, and vibe - then enter a calming space where a single button guides your breath.")
                            .font(.subheadline).foregroundStyle(FlowTheme.textSecondary)
                    }
                    .padding(16)
                    .flowCard()
                    .padding(24)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationBarHidden(true)
        }
        .tint(FlowTheme.accentPrimary)
    }
}

#Preview {
    ContentView()
}
