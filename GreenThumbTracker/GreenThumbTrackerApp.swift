//
//  GreenThumbTrackerApp.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/20/25.
//

import SwiftUI
import Foundation
import WeatherKit
import CoreLocation
import UserNotifications

@main
struct GreenThumbTrackerApp: App {
    @StateObject var conflictManager = ConflictController.shared
    @StateObject var networkMonitor = NetworkMonitor()
    @StateObject var appState = AppState()
    @State private var notificationBannerMessage: String? = nil
    @State private var showBanner: Bool = false

    let notificationDelegate = NotificationDelegate()
    
    init() {
        UIView.appearance().overrideUserInterfaceStyle = .light
        print("✅ Injecting AppState and NetworkMonitor into RootViewRouter")
    }
    var body: some Scene {
        
        WindowGroup {
            RootViewRouter()
                .environmentObject(appState)
                .environmentObject(networkMonitor)
                .sheet(item: Binding<ConflictController.ConflictJob?>(
                    get: { conflictManager.queue.first },
                    set: { _ in ConflictController.shared.dequeue() }
                )) { job in
                    job.resolveUI()
                }

                // Overlay goes here, not inside .sheet
                .overlay(
                    VStack {
                        if showBanner, let message = notificationBannerMessage {
                            Text(message)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.white.opacity(0.95))
                                .foregroundColor(.black)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                                .padding(.top, 60)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        Spacer()
                    }
                    .animation(.easeInOut, value: showBanner)
                )

                .onAppear {
                    BackgroundTaskManager.shared.registerBackgroundTasks()
                    BackgroundTaskManager.shared.scheduleFrostCheck()
                    //Login persistence
                       if let token = UserDefaults.standard.string(forKey: "authToken") {
                           appState.authToken = token
                           appState.isLoggedIn = true
                       }

                    UNUserNotificationCenter.current().delegate = notificationDelegate

                    DispatchQueue.main.async {
                        // Sync setup
                        SyncManager.shared.startMonitoring(networkMonitor: networkMonitor)

                        // Preload caches
                        if let regions = TreflePersistentCacheManager.shared.load([TrefleDistributionRegion].self, from: "regions.json") {
                            TrefleRegionCache.shared.allRegions = regions
                            TrefleRegionCache.shared.isLoaded = true
                            print("📦 Preloaded regions into memory: \(regions.count)")
                        }
                        if let plants = TreflePersistentCacheManager.shared.load([TreflePlant].self, from: "plants.json") {
                            TreflePlantCache.shared.allPlants = plants
                            TreflePlantCache.shared.isLoaded = true
                            print("📦 Preloaded plants into memory: \(plants.count)")
                        }
                        if let families = TreflePersistentCacheManager.shared.load([TrefleFamily].self, from: "families.json") {
                            TrefleFamilyCache.shared.allFamilies = families
                            TrefleFamilyCache.shared.isLoaded = true
                            print("📦 Preloaded families into memory: \(families.count)")
                        }

                        // Location & notifications
                        CLLocationManager().requestWhenInUseAuthorization()
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                            DispatchQueue.main.async {
                                if granted {
                                    notificationBannerMessage = "✅ Frost warnings enabled — you'll be alerted to protect your plants during cold weather."
                                } else {
                                    notificationBannerMessage = "⚠️ Notifications disabled — frost warnings won't be delivered to help protect your plants."
                                }
                                showBanner = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    showBanner = false
                                }
                            }
                        }
                    }
                }
        }

    }

}


