//
//  RoomLobbyView.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct RoomLobbyView: View {
    let roomId: String
    @StateObject private var viewModel = RoomViewModel()
    @State private var room: Room?
    @State private var showingVoting = false
    @State private var showingMatches = false

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let room = room {
                lobbyContent(room)
            } else {
                Text("Unable to load room")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Room")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            await loadRoom()
        }
        .sheet(isPresented: $showingVoting) {
            if let room = room {
                VotingView(roomId: room.id)
            }
        }
        .sheet(isPresented: $showingMatches) {
            if let room = room {
                MatchesView(roomId: room.id)
            }
        }
    }

    @ViewBuilder
    private func lobbyContent(_ room: Room) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Room Header
                VStack(spacing: 12) {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text(room.name)
                        .font(AppFonts.headlineLarge)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    statusBadge(room.status)
                }
                .padding(.top, 20)

                Divider()
                    .padding(.horizontal)

                // Participants
                VStack(alignment: .leading, spacing: 12) {
                    Text("Participants")
                        .font(AppFonts.titleLarge)
                        .fontWeight(.semibold)

                    if let participants = room.participants, !participants.isEmpty {
                        ForEach(participants, id: \.self) { participant in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.blue)
                                    )

                                Text(participant)
                                    .font(AppFonts.bodyLarge)

                                if participant == room.hostId {
                                    Text("Host")
                                        .font(AppFonts.labelSmall)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                        }
                    } else {
                        Text("No participants yet")
                            .foregroundColor(.secondary)
                            .font(AppFonts.bodyMedium)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        showingVoting = true
                    }) {
                        HStack {
                            Image(systemName: "hand.thumbsup.fill")
                            Text("Start Voting")
                                .font(AppFonts.labelLarge)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(room.status != .active)

                    Button(action: {
                        showingMatches = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("View Matches")
                                .font(AppFonts.labelLarge)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }

                    // Share Button
                    ShareLink(item: "Join my Would Watch room: \(room.name) - ID: \(room.id)") {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Room")
                                .font(AppFonts.labelLarge)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(shareButtonBackgroundColor)
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
        }
    }

    private func statusBadge(_ status: RoomStatus) -> some View {
        Text(status.rawValue.capitalized)
            .font(AppFonts.labelMedium)
            .foregroundColor(statusColor(status))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor(status).opacity(0.1))
            .cornerRadius(8)
    }

    private func statusColor(_ status: RoomStatus) -> Color {
        switch status {
        case .active:
            return .green
        case .completed:
            return .blue
        case .cancelled:
            return .gray
        }
    }

    private func loadRoom() async {
        // Use the room service to load room details
        // For now, we'll simulate it with the viewModel
        // In a real app, you'd call viewModel.getRoom(roomId)
    }

    private var shareButtonBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGray5)
        #else
        return Color.gray.opacity(0.15)
        #endif
    }
}

#Preview {
    NavigationView {
        RoomLobbyView(roomId: "test-room-id")
    }
}
