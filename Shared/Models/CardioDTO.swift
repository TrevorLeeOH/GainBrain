//
//  Cardio.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/15/22.
//

import Foundation

class CardioDTO: ObservableObject, Equatable, Identifiable {
        
    public var cardioId: Int64
    public var workoutId: Int64
    @Published public var cardioType: IdentifiableLabel
    @Published public var tags: [IdentifiableLabel]
    @Published public var duration: Double?
    @Published public var distance: Double?
    @Published public var speed: Double?
    @Published public var resistance: Double?
    @Published public var incline: Double?
    
    init(cardioId: Int64 = -1, workoutId: Int64 = -1, cardioType: IdentifiableLabel = IdentifiableLabel(), tags: [IdentifiableLabel] = [], duration: Double? = nil, distance: Double? = nil, speed: Double? = nil, resistance: Double? = nil, incline: Double? = nil) {
        self.cardioId = cardioId
        self.workoutId = workoutId
        self.cardioType = cardioType
        self.tags = tags
        self.duration = duration
        self.distance = distance
        self.speed = speed
        self.resistance = resistance
        self.incline = incline
    }
    
    static func == (lhs: CardioDTO, rhs: CardioDTO) -> Bool {
        return lhs.cardioId == rhs.cardioId
    }
    
    public func duplicate() -> CardioDTO {
        return CardioDTO(cardioId: cardioId, workoutId: workoutId, cardioType: cardioType, tags: tags, duration: duration, distance: distance, speed: speed, resistance: resistance, incline: incline)
    }
    
    public func toString() -> String {
        return "id: \(cardioId), type: \(cardioType.name), duration: \(duration ?? -1), distance: \(distance ?? -1), speed: \(speed ?? -1)"
    }
    
    
}

class CardioDTOArray: ObservableObject {
    
    @Published public var contents: [CardioDTO]
    
    init(_ contents: [CardioDTO] = []) {
        self.contents = contents
    }
}

