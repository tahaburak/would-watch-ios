//
//  RoomsListView.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import SwiftUI

struct RoomsListView: View {
    @StateObject private var viewModel = RoomViewModel()
    @State private var showingCreateRoom = false

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.rooms.isEmpty {
                    ProgressView()
                } else if viewModel.rooms.isEmpty {
                    emptyStateView
                } else {
                    roomsList
                }
            }
            .navigationTitle("Rooms")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateRoom = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateRoom) {
                CreateRoomSheet(roomViewModel: viewModel)
            }
            .task {
                await viewModel.loadRooms()
            }
            .refreshable {
                await viewModel.loadRooms()
            }
        }
    }

    private var roomsList: some View {
        List {
            ForEach(viewModel.rooms) { room in
                RoomRowView(room: room)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Rooms Yet")
                .font(AppFonts.headlineSmall)
                .fontWeight(.semibold)

            Text("Create a room to start watching with friends")
                .font(AppFonts.bodyMedium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: {
                showingCreateRoom = true
            }) {
                Text("Create Room")
                    .font(AppFonts.labelLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .padding()
    }
}

struct RoomRowView: View {
    let room: Room

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(room.name)
                    .font(AppFonts.bodyLarge)
                    .fontWeight(.semibold)

                Spacer()

                statusBadge
            }

            if let participants = room.participants, !participants.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(participants.count) participant\(participants.count == 1 ? "" : "s")")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(.secondary)
                }
            }

            if let createdAt = room.createdAt {
                Text(relativeTime(from: createdAt))
                    .font(AppFonts.bodySmall)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var statusBadge: some View {
        Text(room.status.rawValue.capitalized)
            .font(AppFonts.labelSmall)
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.1))
            .cornerRadius(6)
    }

    private var statusColor: Color {
        switch room.status {
        case .active:
            return .green
        case .completed:
            return .blue
        case .cancelled:
            return .gray
        }
    }

    private func relativeTime(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    RoomsListView()
}
