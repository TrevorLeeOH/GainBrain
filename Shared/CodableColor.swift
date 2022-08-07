//
//  CodableColor.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/15/22.
//

import Foundation
import SwiftUI


struct CodableColor: Codable, Hashable {
    
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    var a: CGFloat
        
    public func toColor() -> Color {
        return Color(red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
    }
    
}
