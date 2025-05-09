//
//  RouteViewRouter.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 5/5/25.
//

import SwiftUI

struct RootViewRouter: View {
        @EnvironmentObject var appState: AppState
        @EnvironmentObject var networkMonitor: NetworkMonitor

        var body: some View {
            Group {
                       if appState.isLoggedIn {
                           HomePageView()
                               .environmentObject(appState)
                               .environmentObject(networkMonitor)
                               .transition(.scale(scale: 1.1).combined(with: .opacity))
                       } else {
                           LoginView()
                               .environmentObject(appState)
                               .environmentObject(networkMonitor)
                               .transition(.opacity)
                       }
            }.onAppear{
                print("RootViewRouter is appearing at runtime! \(appState.isLoggedIn)")
            }
            .animation(.easeInOut(duration: 0.4), value: appState.isLoggedIn)
        }
    }
#if DEBUG
#Preview {
    RootViewRouter()
        .environmentObject(AppState())
        .environmentObject(NetworkMonitor())
}

#endif
