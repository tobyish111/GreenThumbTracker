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

        var body: some Scene {
            WindowGroup {
                ZStack {
                    if isLoggedIn {
                        HomePageView()
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
                }
                .animation(.easeInOut(duration: 0.4), value: isLoggedIn)
            }
        }
    }
