//
//  ToastNotification.swift
//  would_watch
//
//  Created by Claude on 19/01/2026.
//

import SwiftUI
import Combine

enum ToastType {
    case success
    case error
    case info
    
    var color: Color {
        switch self {
        case .success:
            return .green
        case .error:
            return .red
        case .info:
            return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        case .info:
            return "info.circle.fill"
        }
    }
}

struct ToastNotification: View {
    let message: String
    let type: ToastType
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 12) {
                Image(systemName: type.icon)
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .accessibilityHidden(true)
                
                Text(message)
                    .font(AppFonts.bodyMedium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .accessibilityIdentifier("ToastMessage")
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(type.color)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 50)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier("ToastNotification")
            .accessibilityLabel(message)
            .accessibilityValue(message)
        }
    }
}

// MARK: - Toast Manager

@MainActor
final class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var isPresented: Bool = false
    @Published var message: String = ""
    @Published var type: ToastType = .info
    
    private var dismissTask: Task<Void, Never>?
    
    private init() {}
    
    func show(message: String, type: ToastType = .info, duration: TimeInterval = 3.0) {
        // Cancel any existing dismiss task
        dismissTask?.cancel()
        
        self.message = message
        self.type = type
        self.isPresented = true
        
        // Auto-dismiss after duration
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            if !Task.isCancelled {
                withAnimation {
                    self.isPresented = false
                }
            }
        }
    }
    
    func dismiss() {
        dismissTask?.cancel()
        withAnimation {
            isPresented = false
        }
    }
}

// MARK: - View Modifier

struct ToastModifier: ViewModifier {
    @StateObject private var toastManager = ToastManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if toastManager.isPresented {
                ToastNotification(
                    message: toastManager.message,
                    type: toastManager.type,
                    isPresented: $toastManager.isPresented
                )
                .zIndex(1000)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: toastManager.isPresented)
            }
        }
    }
}

extension View {
    func toastNotification() -> some View {
        modifier(ToastModifier())
    }
}
