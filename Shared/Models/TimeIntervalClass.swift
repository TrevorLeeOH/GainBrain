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
        let hoursStr = hours > 0 ? String(hours) + " hrs, " : ""
        let minutesStr = minutes > 0 ? String(minutes) + " min, " : ""
        let secondsStr = String(seconds) + " sec"

        return hoursStr + minutesStr + secondsStr;
    }
    
    func toTimeInterval() -> TimeInterval {
        return Double((hours * 3600) + (minutes * 60) + seconds)
    }
}
