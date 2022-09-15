//
//  DateExtension.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/13/22.
//

import Foundation

extension Date {
    
    func toLocalFormattedString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy @ h:mm a"
        return dateFormatter.string(from: self)
    }
    
    func toDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: self)
    }
    
}
