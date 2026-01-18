//
//  SettingsSheet.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var viewModel: ProfileViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedPrivacy: PrivacySetting = .friends

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Privacy")) {
                    ForEach(PrivacySetting.allCases, id: \.self) { privacy in
                        Button(action: {
                            selectedPrivacy = privacy
                            Task {
                                await viewModel.updatePrivacy(privacy)
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(privacy.displayName)
                                        .font(AppFonts.bodyLarge)
                                        .foregroundColor(.primary)

                                    Text(privacy.description)
                                        .font(AppFonts.bodySmall)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if selectedPrivacy == privacy {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                Section(header: Text("Account")) {
                    Button(action: {
                        Task {
                            await authViewModel.logout()
                            dismiss()
                        }
                    }) {
                        HStack {
                            Text("Log Out")
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                    }
                }

                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
            .onAppear {
                if let currentPrivacy = viewModel.profile?.privacy {
                    selectedPrivacy = currentPrivacy
                }
            }
        }
    }
}

#Preview {
    SettingsSheet(viewModel: ProfileViewModel(), authViewModel: AuthViewModel())
}
