//
//  DateFormatterUtils.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/23/25.
//

import Foundation


//date formater
public func formattedDate(_ rawDate: String) -> String {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let displayFormatter = DateFormatter()
    displayFormatter.dateStyle = .medium // ex: Mar 22, 2025
    displayFormatter.timeStyle = .short //ex. 2.00PM
    displayFormatter.locale = .current  //uses users locale (AM/PM)
    displayFormatter.timeZone = .current    //auto converts from UTC

    if let date = isoFormatter.date(from: rawDate) {
        return displayFormatter.string(from: date)
    } else {
        return rawDate
    }
}
