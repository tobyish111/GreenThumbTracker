//
//  BackgroundTaskManager.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 5/6/25.
//

import Foundation
import BackgroundTasks
import Foundation
import UserNotifications

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    private let taskIdentifier = "com.yourcompany.greenthumbtracker.frostCheck"

    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            self.handleFrostCheckTask(task: task as! BGAppRefreshTask)
        }
    }

    func scheduleFrostCheck() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 12 * 60 * 60) // Every 12 hours

        do {
            try BGTaskScheduler.shared.submit(request)
            print("🌡️ Frost check task scheduled")
        } catch {
            print("⚠️ Failed to schedule frost check: \(error)")
        }
    }

    private func handleFrostCheckTask(task: BGAppRefreshTask) {
        scheduleFrostCheck() // Schedule next one

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        queue.addOperation {
            WeatherChecker.shared.checkForFrostAndNotify()

            task.setTaskCompleted(success: true)
        }
    }
}
