//
//  LoginView.swift
//  would_watch
//
//  Created by Claude on 17/01/2026.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isSignUpMode = false
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo or App Name
                    VStack(spacing: 8) {
                        Image(systemName: "film")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)

                        Text("Would Watch")
                            .font(AppFonts.displayMedium)
                            .fontWeight(.bold)

                        Text("Discover movies together")
                            .font(AppFonts.bodyLarge)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                    // Input Fields
                    VStack(spacing: 16) {
                        TextField("Email", text: $viewModel.email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
#if canImport(UIKit)
                            .textContentType(.emailAddress)
#elseif canImport(AppKit)
                            .textContentType(.emailAddress)
#endif
                            .autocorrectionDisabled()
#if os(iOS)
                            .keyboardType(.emailAddress)
#endif
                            .disabled(viewModel.isLoading)
#if os(iOS)
                            .textInputAutocapitalization(.never)
#endif

                        SecureField("Password", text: $viewModel.password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
#if canImport(UIKit)
                            .textContentType(isSignUpMode ? .newPassword : .password)
#elseif canImport(AppKit)
                            .textContentType(.password)
#endif
                            .disabled(viewModel.isLoading)
                    }
                    .padding(.horizontal)

                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            Task {
                                if isSignUpMode {
                                    await viewModel.signUp()
                                } else {
                                    await viewModel.login()
                                }
                            }
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text(isSignUpMode ? "Sign Up" : "Log In")
                                        .font(AppFonts.labelLarge)
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(viewModel.isLoading)

                        Button(action: {
                            isSignUpMode.toggle()
                            viewModel.errorMessage = nil
                        }) {
                            Text(isSignUpMode ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                                .font(AppFonts.bodyMedium)
                                .foregroundColor(.blue)
                        }
                        .disabled(viewModel.isLoading)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            #if os(iOS)
            .navigationBarHidden(false)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                NetworkSettingsSheet(isPresented: $showSettings)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
