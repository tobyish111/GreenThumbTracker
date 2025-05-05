//
//  NetworkMonitor.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 5/3/25.
//

import Foundation
import Network
import Combine

class NetworkMonitor: ObservableObject {
    @Published var isConnected: Bool = false

    private var monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        self.monitor = NWPathMonitor()
        self.monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        self.monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}

