//
//  OnlineDocView.swift
//  DevLokosOnlineDocSwiftUI
//
//  Created by Kevinho Morales on 1/4/25.
//

import SwiftUI

struct OnlineDocView: View {
    @StateObject private var viewModel = OnlineDocViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 12) {
            Text("ONLINE DOCUMENT")
                .font(.headline)

            Text("Online Users: \(viewModel.activeViewers)")
                .font(.subheadline)
                .foregroundColor(.gray)

            if let message = viewModel.notificationMessage {
                Text(message)
                    .padding(8)
                    .background(Color.yellow)
                    .cornerRadius(8)
                    .transition(.opacity)
            }

            TextEditor(text: $viewModel.content)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .onChange(of: viewModel.content) { oldText, newText in
                    viewModel.updateContent(newText)
                }

            Spacer()
        }
        .padding()
        .animation(.easeInOut, value: viewModel.notificationMessage)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background || newPhase == .inactive {
                viewModel.removeViewer()
            }
        }
    }
}
