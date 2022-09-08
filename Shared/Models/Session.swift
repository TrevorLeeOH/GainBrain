//
//  Session.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/8/22.
//

import Foundation

class Session {
    
    static func createSession(workouts: [Int64]) {
        let sessionUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Session")
        let encoder = JSONEncoder()
        do {
            let workoutData = try encoder.encode(workouts)
            try workoutData.write(to: sessionUrl)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func getSession() -> [WorkoutDTO]? {
        print("called get session")
        
        let sessionUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Session")
        
        if FileManager.default.fileExists(atPath: sessionUrl.path) {
            var workouts: [WorkoutDTO] = []
            do {
                let sessionData: Data = try String(contentsOfFile: sessionUrl.path).data(using: .utf8)!
                let decoder = JSONDecoder()
                let workoutsIds: [Int64] = try decoder.decode([Int64].self, from: sessionData)
                for id in workoutsIds {
                    do {
                        try workouts.append(WorkoutDao.get(workoutId: id))
                    } catch {
                        deleteSession()
                        return nil
                    }
                    
                }
            }  catch {
                print(error.localizedDescription)
            }
            return workouts
            
        } else {
            return nil
        }
    }
    
    static func sessionExists() -> Bool {
        let sessionUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Session")
        return FileManager.default.fileExists(atPath: sessionUrl.path)
    }
    
    static func deleteSession() {
        let sessionUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Session")
        do {
            try FileManager.default.removeItem(at: sessionUrl)
        } catch {
            print(error.localizedDescription)
        }
    }
}
