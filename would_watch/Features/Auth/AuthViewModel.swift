//
//  AuthViewModel.swift
//  would_watch
//
//  Created by Claude on 17/01/2026.
//

import Foundation
import Combine
import SwiftUI

final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    @MainActor
    func login() async {
        guard validateInputs() else { return }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await authService.login(email: email, password: password)
            currentUser = response.user
            isAuthenticated = true
            // Show success toast
            ToastManager.shared.show(message: "Welcome back!", type: .success)
        } catch {
            // Show error toast with user-friendly message
            let message = error.localizedDescription
            ToastManager.shared.show(message: message, type: .error)
            errorMessage = message
        }

        isLoading = false
    }

    @MainActor
    func signUp() async {
        guard validateInputs() else { return }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await authService.signUp(email: email, password: password)
            currentUser = response.user
            isAuthenticated = true
            // Show success toast
            ToastManager.shared.show(message: "Account created successfully!", type: .success)
        } catch {
            // Show error toast
            let message = error.localizedDescription
            ToastManager.shared.show(message: message, type: .error)
            errorMessage = message
        }

        isLoading = false
    }

    @MainActor
    func logout() async {
        isLoading = true

        do {
            try await authService.logout()
            currentUser = nil
            isAuthenticated = false
            email = ""
            password = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func validateInputs() -> Bool {
        errorMessage = nil

        guard !email.isEmpty else {
            let message = "Email is required"
            errorMessage = message
            ToastManager.shared.show(message: message, type: .error)
            return false
        }

        guard email.contains("@") && email.contains(".") else {
            let message = "Invalid email format"
            errorMessage = message
            ToastManager.shared.show(message: message, type: .error)
            return false
        }

        guard !password.isEmpty else {
            let message = "Password is required"
            errorMessage = message
            ToastManager.shared.show(message: message, type: .error)
            return false
        }

        guard password.count >= 6 else {
            let message = "Password must be at least 6 characters"
            errorMessage = message
            ToastManager.shared.show(message: message, type: .error)
            return false
        }

        return true
    }
}
