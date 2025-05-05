//
//  RecordSyncable.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 5/3/25.
//

import Foundation

//defining the interface in which structs conform too
protocol RecordSyncable {
    var id: UUID { get }
    var date: Date { get }
    var isSynced: Bool { get set }
    var backendId: Int? { get set }
}
