//
//  Cardio.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/15/22.
//

import Foundation

struct Cardio: Codable, Hashable {
    static var STATISTIC_TYPES: [String] = ["Duration", "Distance", "Speed", "Resistance", "Incline"]
    
    var type: String
    var tags: [String]
    
    var statistics: Dictionary<String, Double>
    
    init(type: String, tags: [String], statistics: Dictionary<String, Double>) {
        self.type = type
        self.tags = tags
        self.statistics = statistics
    }
    static func getTypeUrl() -> URL {
        let url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("CardioTypes.txt")
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
        return url
    }
    
    static func getTagUrl() -> URL {
        let url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("CardioTags.txt")
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
        return url
    }
}

