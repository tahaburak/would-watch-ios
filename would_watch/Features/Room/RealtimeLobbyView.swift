//
//  RealtimeLobbyView.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

struct RealtimeLobbyView: View {
    let roomId: String
    @StateObject private var viewModel = RoomViewModel()
    @StateObject private var realtimeService = RealtimeService.shared
    @State private var room: Room?
    @State private var showingVoting = false
    @State private var showingMatches = false
    @State private var showMatchNotification = false
    @State private var newParticipantName: String?
    @State private var cancellables = Set<AnyCancellable>()

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

            // Realtime notifications overlay
            if showMatchNotification {
                matchNotificationOverlay
            }

            if let participantName = newParticipantName {
                participantJoinedOverlay(name: participantName)
            }
        }
        .navigationTitle("Room")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            await loadRoom()
            setupRealtimeSubscriptions()
        }
        .onDisappear {
            realtimeService.unsubscribe(from: roomId)
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

                    // Live indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Live")
                            .font(AppFonts.labelSmall)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.top, 20)

                Divider()
                    .padding(.horizontal)

                // Participants with realtime updates
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Participants")
                            .font(AppFonts.titleLarge)
                            .fontWeight(.semibold)

                        Spacer()

                        Text("\(room.participants?.count ?? 0)")
                            .font(AppFonts.labelMedium)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(participantCountBackgroundColor)
                            .cornerRadius(8)
                    }

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

                                Spacer()

                                // Online indicator
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 10, height: 10)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    } else {
                        Text("No participants yet")
                            .foregroundColor(.secondary)
                            .font(AppFonts.bodyMedium)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .animation(.spring(), value: room.participants)

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
                    ShareLink(item: URL(string: "wouldwatch://room/\(room.id)")!, message: Text("Join my Would Watch room: \(room.name) - wouldwatch://room/\(room.id)")) {
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

    private var matchNotificationOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)

            Text("New Match Found!")
                .font(AppFonts.headlineSmall)
                .fontWeight(.bold)

            Text("Check the matches tab")
                .font(AppFonts.bodyMedium)
                .foregroundColor(.secondary)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(matchNotificationBackgroundColor)
                .shadow(radius: 20)
        )
        .transition(.scale.combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showMatchNotification = false
                }
            }
        }
    }

    private func participantJoinedOverlay(name: String) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "person.badge.plus")
                    .foregroundColor(.green)

                Text("\(name) joined!")
                    .font(AppFonts.bodyLarge)
                    .fontWeight(.semibold)
            }
            .padding()
            .background(participantOverlayBackgroundColor)
            .cornerRadius(12)
            .shadow(radius: 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    newParticipantName = nil
                }
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
        // Load room details from the service
        // This would call viewModel.getRoom(roomId)
    }

    private func setupRealtimeSubscriptions() {
        // Subscribe to realtime events
        realtimeService.subscribe(to: roomId)

        realtimeService.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { event in
                handleRealtimeEvent(event)
            }
            .store(in: &cancellables)
    }

    private func handleRealtimeEvent(_ event: RealtimeEvent) {
        switch event {
        case .participantJoined(let eventRoomId, let userId):
            guard eventRoomId == roomId else { return }
            withAnimation {
                newParticipantName = userId
            }
            // Refresh room data
            Task {
                await loadRoom()
            }

        case .participantLeft(let eventRoomId, _):
            guard eventRoomId == roomId else { return }
            // Refresh room data
            Task {
                await loadRoom()
            }

        case .participantReady(let eventRoomId, _):
            guard eventRoomId == roomId else { return }
            // Refresh room data
            Task {
                await loadRoom()
            }

        case .matchFound(let eventRoomId, _):
            guard eventRoomId == roomId else { return }
            withAnimation {
                showMatchNotification = true
            }
        }
    }

    // MARK: - Background Colors
    private var participantCountBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGray6)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }

    private var shareButtonBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGray5)
        #else
        return Color.gray.opacity(0.15)
        #endif
    }

    private var matchNotificationBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #else
        return Color(white: 1.0)
        #endif
    }

    private var participantOverlayBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #else
        return Color(white: 1.0)
        #endif
    }
}

#Preview {
    NavigationView {
        RealtimeLobbyView(roomId: "test-room-id")
    }
}
