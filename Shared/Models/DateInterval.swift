//
//  DateInterval.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/27/22.
//

import Foundation


class DateIntervalClass {
    var years: Int
    var weeks: Int
    var days: Int
    
    init(years: Int, weeks: Int, days: Int) {
        self.years = years
        self.weeks = weeks
        self.days = days
    }
    
    init(timeInterval: TimeInterval) {
        var dur = timeInterval
        var years: Int = 0
        var weeks: Int = 0
        var days: Int = 0
        
        while dur >= 31536000 {
            dur -= 31536000
            years += 1
        }
        
        while dur >= 604800 {
            dur -= 604800
            weeks += 1
        }
        
        while dur >= 86400 {
            dur -= 86400
            days += 1
        }
        self.years = years
        self.weeks = weeks
        self.days = days
    }
    
    
    func toString() -> String {
        var strMessageArray: [String] = []
        if years > 0 {
            strMessageArray.append(String(years) + " yrs")
        }
        if weeks > 0 {
            strMessageArray.append(String(weeks) + " wks")
        }
        if days > 0 {
            strMessageArray.append(String(days) + " days")
        }
        return strMessageArray.joined(separator: ", ")
    }

}

extension DateInterval {
        
    func getDays() -> Double {
        return duration / 86400.0
    }
    
    func getWeeks() -> Double {
        return duration / 604800.0
    }
    
    func getYears() -> Double {
        return duration / 31536000.0
    }
    
    func getRate(count: Int) -> String {
        var dur = duration / Double(count)
        var years: Int = 0
        var weeks: Int = 0
        var days: Int = 0
        
        while dur >= 31536000 {
            dur -= 31536000
            years += 1
        }
        
        while dur >= 604800 {
            dur -= 604800
            weeks += 1
        }
        
        while dur >= 86400 {
            dur -= 86400
            days += 1
        }
        
        if years > 0 {
            if weeks == 0 {
                return "every \(years) year\(years > 1 ? "s" : "")"
            } else {
                return "every \(years)-\(years + 1) years"
            }
        } else if weeks > 0 {
            if days == 0 {
                return "every \(weeks) week\(weeks > 1 ? "s" : "")"
            } else {
                return "every \(weeks)-\(weeks + 1) weeks"
            }
        } else {
            return ""
        }
        
        
    }
}
