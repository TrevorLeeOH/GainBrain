//
//  WeightLifting.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/15/22.
//

import Foundation

struct WeightLifting: Codable, Hashable {
    var type: String
    var tags: [String]
    var sets: [WeightLiftingSet]
    
    static func getTypeUrl() -> URL {
        let url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("WeightLiftingTypes.txt")
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
        return url
    }
    
    static func getTagUrl() -> URL {
        let url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("WeightLiftingTags.txt")
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
        return url
    }
}

class WeightLiftingBuilder: ObservableObject {
    @Published var type: String
    @Published var tags: [String]
    @Published var weightAsOffset: Bool
    @Published var individualWeight: Bool
    @Published var sets: [WeightLiftingSet] = []
    
    init(type: String, tags: [String], weightAsOffset: Bool, individualWeight: Bool) {
        self.type = type
        self.tags = tags
        self.weightAsOffset = weightAsOffset
        self.individualWeight = individualWeight
    }
    
    public func toStruct() -> WeightLifting {
        return WeightLifting(type: type, tags: tags, sets: sets)
    }
    
}

struct WeightLiftingSet: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var weight: Double
    var reps: Int
    
    init(weight: Double, reps: Int) {
        self.weight = weight
        self.reps = reps
    }
}

