//
//  TimeIntervalStruct.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/12/22.
//

import Foundation

class TimeIntervalClass: ObservableObject {
    @Published public var hours: Int
    @Published public var minutes: Int
    @Published public var seconds: Int
    
    init(hours: Int = 0, minutes: Int = 0, seconds: Int = 0) {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }
    
    init(timeInterval: TimeInterval) {
        var dur = timeInterval
        var hours: Int = 0
        var minutes: Int = 0
        var seconds: Int = 0

        while (dur >= 3600) {
            hours += 1
            dur -= 3600
        }
        while (dur >= 60) {
            minutes += 1
            dur -= 60
        }
        while (dur >= 1) {
            seconds += 1
            dur -= 1
        }

        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }
    
    func toString() -> String {
        var strMessageArray: [String] = []
        if hours > 0 {
            strMessageArray.append(String(hours) + " hrs")
        }
        if minutes > 0 {
            strMessageArray.append(String(minutes) + " min")
        }
        if seconds > 0 {
            strMessageArray.append(String(seconds) + " sec")
        }
        return strMessageArray.joined(separator: ", ")
    }
    
    func toShortString() -> String {
        if hours > 0 {
            return String(round(self.toTimeInterval() / 3600.0 * 10) / 10.0) + " hrs"
        } else if minutes > 0 {
            return String(round(self.toTimeInterval() / 60.0 * 10) / 10.0) + " min"
        } else {
            return String(Int(self.toTimeInterval())) + " sec"
        }
    }
    
    func toTimeInterval() -> TimeInterval {
        return Double((hours * 3600) + (minutes * 60) + seconds)
    }
    
    func setTimeInterval(timeInterval: TimeInterval) {
        var dur = timeInterval
        var hours: Int = 0
        var minutes: Int = 0
        var seconds: Int = 0

        while (dur >= 3600) {
            hours += 1
            dur -= 3600
        }
        while (dur >= 60) {
            minutes += 1
            dur -= 60
        }
        while (dur >= 1) {
            seconds += 1
            dur -= 1
        }

        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }
}
