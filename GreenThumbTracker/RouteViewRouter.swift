//
//  RouteViewRouter.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 5/5/25.
//

import SwiftUI

struct RootViewRouter: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
        @EnvironmentObject var appState: AppState
        @EnvironmentObject var networkMonitor: NetworkMonitor

        var body: some View {
            Group {
                if isLoggedIn {
                    HomePageView()
                        .environmentObject(appState)
                        .environmentObject(networkMonitor)
                        .transition(.scale(scale: 1.1).combined(with: .opacity))
                } else {
                    LoginView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: isLoggedIn)
        }
    }

#Preview {
    RootViewRouter()
}
