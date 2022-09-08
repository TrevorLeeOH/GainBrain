//
//  Cardio.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/15/22.
//

import Foundation

class CardioDTO: ObservableObject, Equatable {
    
    var cardioId: Int64
    var workoutId: Int64
    @Published var cardioType: IdentifiableLabel
    @Published var tags: [IdentifiableLabel]
    @Published var duration: Double?
    @Published var distance: Double?
    @Published var speed: Double?
    @Published var resistance: Double?
    @Published var incline: Double?
    
    init(cardioId: Int64 = -1, workoutId: Int64, cardioType: IdentifiableLabel = IdentifiableLabel(), tags: [IdentifiableLabel] = [], duration: Double? = nil, distance: Double? = nil, speed: Double? = nil, resistance: Double? = nil, incline: Double? = nil) {
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
}

