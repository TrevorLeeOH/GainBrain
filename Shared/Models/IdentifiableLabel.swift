//
//  Type.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/6/22.
//

import Foundation


class IdentifiableLabel: Equatable {
    
    public var id: Int64
    public var name: String
    
    init(id: Int64 = -1, name: String = "") {
        self.id = id
        self.name = name
    }
    
    static func == (lhs: IdentifiableLabel, rhs: IdentifiableLabel) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func toString() -> String {
        return "id: \(id), name: \(name)"
    }
    
}
