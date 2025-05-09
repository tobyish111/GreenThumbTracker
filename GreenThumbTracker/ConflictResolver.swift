//
//  ConflictResolver.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 5/3/25.
//
import SwiftUI
import Foundation
//conflict resolving logic
struct ConflictPair<T: RecordSyncable> {
    let local: T
    let remote: T
}

class ConflictResolver {
    static func detectConflicts<T: RecordSyncable>(
        local: [T],
        remote: [T],
        toleranceSeconds: TimeInterval = 60
    ) -> [ConflictPair<T>] {
        var result: [ConflictPair<T>] = []

        for localRecord in local where !localRecord.isSynced {
            if let match = remote.first(where: { abs($0.date.timeIntervalSince(localRecord.date)) < toleranceSeconds }) {
                result.append(ConflictPair(local: localRecord, remote: match))
            }
        }
        return result
    }
}
//app state class
//MARK: App State class, Persistency!
final class AppState: ObservableObject {
    @AppStorage("authToken") private var storedToken: String = ""

       @Published var authToken: String = ""
       @Published var isLoggedIn: Bool = false
       @Published var isOffline: Bool = false

       init() {
           self.authToken = storedToken
           self.isLoggedIn = !authToken.isEmpty

           if isLoggedIn {
               postLoginSetup()
           }
       }

       func setAuthToken(_ token: String) {
           self.authToken = token
           self.storedToken = token
           self.isLoggedIn = !token.isEmpty

           if isLoggedIn {
               postLoginSetup()
           }
       }

       func logout() {
           setAuthToken("")
       }

       func postLoginSetup() {
           // Trefle
           TrefleTokenManager.shared.fetchClientToken { success in
               print(success ? "✅ Trefle token fetched" : "❌ Trefle token failed")
           }

           // Backend token (optional)
           APIManager.shared.refreshBackendToken { success in
               print(success ? "✅ Backend token refreshed" : "❌ Backend token refresh failed")
           }
       }
}

