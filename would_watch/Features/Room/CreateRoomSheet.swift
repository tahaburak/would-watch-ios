//
//  CreateRoomSheet.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import SwiftUI

struct CreateRoomSheet: View {
    @ObservedObject var roomViewModel: RoomViewModel
    @StateObject private var socialViewModel = SocialViewModel()
    @Environment(\.dismiss) var dismiss

    @State private var roomName: String = ""
    @State private var selectedFriends: Set<String> = []
    @State private var showError: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Room Details")) {
                    TextField("Room Name", text: $roomName)
                        .textInputAutocapitalization(.words)
                }

                Section(header: Text("Invite Friends")) {
                    if socialViewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else if socialViewModel.friends.isEmpty {
                        Text("No friends to invite")
                            .foregroundColor(.secondary)
                            .font(AppFonts.bodyMedium)
                    } else {
                        ForEach(socialViewModel.friends) { friend in
                            FriendSelectionRow(
                                friend: friend,
                                isSelected: selectedFriends.contains(friend.id)
                            ) {
                                toggleFriendSelection(friend.id)
                            }
                        }
                    }
                }

                if !selectedFriends.isEmpty {
                    Section {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.blue)
                            Text("\(selectedFriends.count) friend\(selectedFriends.count == 1 ? "" : "s") selected")
                                .font(AppFonts.bodyMedium)
                        }
                    }
                }
            }
            .navigationTitle("Create Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        Task {
                            await createRoom()
                        }
                    }
                    .disabled(roomName.isEmpty || roomViewModel.isLoading)
                }
            }
            .task {
                await socialViewModel.loadFriends()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage = roomViewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }

    private func toggleFriendSelection(_ friendId: String) {
        if selectedFriends.contains(friendId) {
            selectedFriends.remove(friendId)
        } else {
            selectedFriends.insert(friendId)
        }
    }

    private func createRoom() async {
        let success = await roomViewModel.createRoom(
            name: roomName,
            participants: Array(selectedFriends)
        )

        if success {
            dismiss()
        } else {
            showError = true
        }
    }
}

struct FriendSelectionRow: View {
    let friend: Friend
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(friend.username.prefix(1).uppercased())
                            .font(AppFonts.titleSmall)
                            .foregroundColor(.blue)
                    )

                Text(friend.username)
                    .font(AppFonts.bodyLarge)
                    .foregroundColor(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CreateRoomSheet(roomViewModel: RoomViewModel())
}
