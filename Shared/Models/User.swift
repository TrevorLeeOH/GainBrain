//
//  User.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/5/22.
//

import Foundation
import SwiftUI

class User: Identifiable, Equatable, ObservableObject {
    
    public var userId: Int64
    @Published public var name: String
    @Published public var h: Double
    @Published public var s: Double
    @Published public var b: Double
    
    init(userId: Int64 = -1, name: String = "", h: Double = 0.0, s: Double = 0.0, b: Double = 0.0) {
        self.userId = userId
        self.name = name
        self.h = h
        self.s = s
        self.b = b
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.userId == rhs.userId
    }
    
    public func getColor() -> Color {
        return Color(hue: h, saturation: s, brightness: b)
    }
    
    public func duplicate() -> User {
        return User(userId: userId, name: name, h: h, s: s, b: b)
    }
    
}
