//
//  GreenThumbTrackerApp.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/20/25.
//

import SwiftUI

@main
struct GreenThumbTrackerApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @StateObject var conflictManager = ConflictController.shared
    @StateObject var networkMonitor = NetworkMonitor()
    @StateObject var appState = AppState()

        var body: some Scene {
            WindowGroup {
                ZStack {
                    if isLoggedIn {
                        HomePageView()
                            .environmentObject(networkMonitor)
                            .transition(
                                .asymmetric(
                                    insertion: .scale(scale: 1.1).combined(with: .opacity),
                                    removal: .scale(scale: 0.9).combined(with: .opacity)
                                )
                            )
                    } else {
                        LoginView()
                            .transition(.opacity)
                    }
                }.sheet(item: Binding<ConflictController.ConflictJob?>(
                    get: { conflictManager.queue.first },
                    set: { _ in ConflictController.shared.dequeue() }
                )) { job in
                    job.resolveUI()
                }
                .onAppear{
                    SyncManager.shared.startMonitoring(networkMonitor: networkMonitor)
                }
                .animation(.easeInOut(duration: 0.4), value: isLoggedIn)
            }
        }
    }
