//
//  WeatherChecker.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 5/6/25.
//

import Foundation
import WeatherKit
import CoreLocation
import UserNotifications

class WeatherChecker: NSObject, CLLocationManagerDelegate {
    static let shared = WeatherChecker()

       private let service = WeatherService.shared
       private let locationManager = CLLocationManager()
       private var lastNotifiedDate: Date?

       override init() {
           super.init()
           locationManager.delegate = self
           locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
       }

       /// Public method to start frost check, used by app or background task
       func checkForFrostAndNotify() {
           // Avoid notifying more than once every 12 hours
           if let last = lastNotifiedDate, Date().timeIntervalSince(last) < 12 * 60 * 60 {
               print("⏱ Skipping frost check — already notified within 12 hours.")
               return
           }

           print("📡 Requesting location for frost check...")
           locationManager.requestLocation()
           
#if targetEnvironment(simulator)
    print("🧊 Simulator mode: Pretending it’s 28°F to trigger frost warning")
    self.sendFrostNotification()
    return
#endif

       }

       // MARK: - CLLocationManagerDelegate

       func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           guard let loc = locations.first else {
               print("⚠️ No valid location received.")
               return
           }

           print("📍 Location received: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")

           Task {
               do {
                   let weather = try await service.weather(for: loc)
                   let temp = weather.currentWeather.temperature.converted(to: .fahrenheit).value
                   print("🌡️ Current temperature: \(temp)°F")

                   if temp <= 32 {
                       lastNotifiedDate = Date()
                       sendFrostNotification()
                   } else {
                       print("✅ No frost warning needed.")
                   }
               } catch {
                   print("❌ Failed to fetch weather:", error.localizedDescription)
               }
           }
       }

       func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print("❌ Location failed:", error.localizedDescription)
       }

       // MARK: - Notification
        func sendFrostNotification() {
           let content = UNMutableNotificationContent()
           content.title = "🌡️ Frost Warning"
           content.body = "It’s below 32°F — protect your plants!"
           content.sound = .default

           let request = UNNotificationRequest(
               identifier: UUID().uuidString,
               content: content,
               trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
           )

           UNUserNotificationCenter.current().add(request) { error in
               if let error = error {
                   print("❌ Notification error: \(error.localizedDescription)")
               } else {
                   print("✅ Frost warning notification scheduled.")
               }
           }
       }
   }

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list]) // Show banner + play sound
    }
}
