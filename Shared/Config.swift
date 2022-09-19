//
//  Config.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/19/22.
//

import Foundation

class Config: Codable {
    
    static var instance: Config = get()
    static var configUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Config")
    
    public var metricWeights: Bool = false
    public var metricDistances: Bool = false
    
    init(metricWeights: Bool = false, metricDistances: Bool = false) {
        self.metricWeights = metricWeights
        self.metricDistances = metricDistances
    }
    
    static func get() -> Config {
        if FileManager.default.fileExists(atPath: configUrl.path) {
            do {
                let configData = try Data(contentsOf: configUrl)
                let jsonDecoder = JSONDecoder()
                return try jsonDecoder.decode(Config.self, from: configData)
                
            } catch {
                print(error.localizedDescription)
            }
        }
        return Config()
    }
    
    
    static func update(config: Config) throws {
        do {
            let encoder = JSONEncoder()
            let configData = try encoder.encode(config)
            try configData.write(to: Config.configUrl)
            instance.metricWeights = config.metricWeights
            instance.metricDistances = config.metricDistances
        }
    }
    
}

extension Double {
    public func lbsToKg() -> Double {
        return self / 2.205
    }
    
    public func kgToLbs() -> Double {
        return self * 2.205
    }
    
    public func milesToKilometers() -> Double {
        return self * 1.609
    }
    
    public func kilometersToMiles() -> Double {
        return self / 1.609
    }
}
