//
//  ConflictController.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 5/3/25.
//

import Foundation
import SwiftUI
class ConflictController: ObservableObject {
    static let shared = ConflictController()

    @Published var queue: [ConflictJob] = []

    struct ConflictJob: Identifiable {
        let id = UUID()
        let resolveUI: () -> AnyView
    }

    func dequeue() {
        if !queue.isEmpty {
            queue.removeFirst()
        }
    }
}

extension Result {
    var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
}
