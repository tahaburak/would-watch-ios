//
//  PushNotificationService.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import Foundation
import UserNotifications

enum NotificationType: String {
    case roomInvite = "room_invite"
    case matchFound = "match_found"
    case participantJoined = "participant_joined"
}

struct NotificationPayload {
    let type: NotificationType
    let roomId: String?
    let movieId: Int?
    let title: String
    let body: String
}

@MainActor
final class PushNotificationService: NSObject, ObservableObject {
    static let shared = PushNotificationService()

    @Published var deviceToken: String?
    @Published var isAuthorized: Bool = false

    private override init() {
        super.init()
    }

    func requestAuthorization() async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted

            if granted {
                await registerForRemoteNotifications()
            }

            return granted
        } catch {
            print("Push notification authorization error: \(error)")
            return false
        }
    }

    func registerForRemoteNotifications() async {
        await UIApplication.shared.registerForRemoteNotifications()
    }

    func handleDeviceToken(_ token: Data) {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        deviceToken = tokenString

        // Send token to backend
        Task {
            await sendTokenToBackend(tokenString)
        }
    }

    func handleNotification(_ userInfo: [AnyHashable: Any]) -> NotificationPayload? {
        guard let typeString = userInfo["type"] as? String,
              let type = NotificationType(rawValue: typeString),
              let title = userInfo["title"] as? String,
              let body = userInfo["body"] as? String else {
            return nil
        }

        let roomId = userInfo["room_id"] as? String
        let movieId = userInfo["movie_id"] as? Int

        return NotificationPayload(
            type: type,
            roomId: roomId,
            movieId: movieId,
            title: title,
            body: body
        )
    }

    func scheduleLocalNotification(title: String, body: String, roomId: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        if let roomId = roomId {
            content.userInfo = ["room_id": roomId, "type": "room_invite"]
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Local notification error: \(error)")
            }
        }
    }

    private func sendTokenToBackend(_ token: String) async {
        // TODO: Send device token to backend
        // POST /api/devices/register
        // { "token": token, "platform": "ios" }
        print("Device token: \(token)")
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension PushNotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap
        let userInfo = response.notification.request.content.userInfo

        if let payload = handleNotification(userInfo) {
            handleNotificationTap(payload)
        }

        completionHandler()
    }

    private func handleNotificationTap(_ payload: NotificationPayload) {
        switch payload.type {
        case .roomInvite:
            if let roomId = payload.roomId {
                // Navigate to room via deep link
                if let url = URL(string: "wouldwatch://room/\(roomId)") {
                    Task { @MainActor in
                        await UIApplication.shared.open(url)
                    }
                }
            }

        case .matchFound:
            if let roomId = payload.roomId {
                // Navigate to room matches
                if let url = URL(string: "wouldwatch://room/\(roomId)") {
                    Task { @MainActor in
                        await UIApplication.shared.open(url)
                    }
                }
            }

        case .participantJoined:
            // Maybe navigate to room or show in-app alert
            break
        }
    }
}
