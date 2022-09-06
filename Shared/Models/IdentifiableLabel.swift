//
//  Type.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/6/22.
//

import Foundation


class IdentifiableLabel: Identifiable {
    public var id: Int64
    public var name: String
    
    init(id: Int64 = -1, name: String = "") {
        self.id = id
        self.name = name
    }
}
