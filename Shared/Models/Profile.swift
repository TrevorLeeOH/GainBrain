//
//  Profile.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/13/22.
//

import Foundation
import SwiftUI

struct Profile: Identifiable, Codable, Hashable {
    var name: String
    var color: CodableColor
    var id: UUID
    
    init(name: String, color: CodableColor, id: UUID = UUID()) {
        self.name = name
        self.color = color
        self.id = id
    }
    
    static func getProfiles() -> [Profile] {
        
        var profiles: [Profile] = []
        
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: getProfileDirectory(), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
            for url in urls {
                do {
                    try profiles.append(load(url: url))
                } catch {
                    print("Failed to load a profile")
                }
            }
            
        } catch {
            print("Failed to get profiles")
        }
        
        return profiles
    }
    
    static func getProfile(id: UUID) throws -> Profile {
        do {
            let url = try getProfileDirectory().appendingPathComponent(id.uuidString)
            return try load(url: url)
        }
    }
    
    static func load(url: URL) throws -> Profile {
        let decoder = JSONDecoder()
        let profileData: Data = try Data(contentsOf: url)
        let loadedProfile: Profile = try decoder.decode(Profile.self, from: profileData)
        return loadedProfile
    }
    
    static func createProfile(profile: Profile) throws {
        let filePath: URL = try getProfileDirectory()
        let fileName: String = profile.id.uuidString
        let url = filePath.appendingPathComponent(fileName)
        let encoder = JSONEncoder()
        let profileData = try encoder.encode(profile)
        try profileData.write(to: url)
    }
    
    static func deleteProfile(profileId: UUID) throws {
        try FileManager.default.removeItem(at: getProfileDirectory().appendingPathComponent(profileId.uuidString))
        try WorkoutDao.deleteAllForProfile(profileId)
    }
    
    static func getProfileDirectory() throws -> URL {
        let profileUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Profiles")
        if !FileManager.default.fileExists(atPath: profileUrl.path) {
            try FileManager.default.createDirectory(at: profileUrl, withIntermediateDirectories: true, attributes: nil)
        }
        return profileUrl
    }
    
    
}

