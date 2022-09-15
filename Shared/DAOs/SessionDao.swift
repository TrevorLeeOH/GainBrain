//
//  SessionDao.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/15/22.
//

import Foundation

class SessionDao {
    
    enum SessionDaoError: Error {
        case NoSessionExistsError
    }
    
    static func createSession(users: [User], workoutType: IdentifiableLabel) throws -> Session {
        do {
            var workouts: [WorkoutDTO] = []
            var workoutIds: [Int64] = []
            
            for i in 0..<users.count {
                let workout = try WorkoutDao.create(workout: WorkoutDTO(user: users[i], workoutType: workoutType))
                workouts.append(workout)
                workoutIds.append(workout.workoutId)
            }
            
            
            let sessionUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Session")
            let encoder = JSONEncoder()
            let workoutData = try encoder.encode(workoutIds)
            try workoutData.write(to: sessionUrl)
            
            return Session(workouts: workouts)
            
        }
    }
    
    static func updateSession(session: Session) throws {
        do {
            let sessionUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Session")
            
            var workoutIds: [Int64] = []
            
            for workout in session.workouts {
                workoutIds.append(workout.workoutId)
            }
            
            let encoder = JSONEncoder()
            let workoutData = try encoder.encode(workoutIds)
            try workoutData.write(to: sessionUrl)
        }
    }
    
    static func getSession() throws -> Session {
        print("called get session")
        
        let sessionUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Session")
        
        if FileManager.default.fileExists(atPath: sessionUrl.path) {
            do {
                let sessionData: Data = try Data(contentsOf: sessionUrl)
                let decoder = JSONDecoder()
                let workoutsIds: [Int64] = try decoder.decode([Int64].self, from: sessionData)
                
                var workouts: [WorkoutDTO] = []
                
                for workoutId in workoutsIds {
                    try workouts.append(WorkoutDao.get(workoutId: workoutId))
                }
                
                return Session(workouts: workouts)
            }
            
        } else {
            throw SessionDaoError.NoSessionExistsError
        }
    }
    
    static func sessionExists() -> Bool {
        print("called Session Exists")
        let sessionUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Session")
        if FileManager.default.fileExists(atPath: sessionUrl.path) {
            return validateSession()
        }
        return false
    }
    
    static func validateSession() -> Bool {
        do {
            let _ = try getSession()
            return true
        } catch {
            do {
                try deleteSession()
            } catch {
                print(error.localizedDescription)
            }
            return false
        }
    }
    
    static func deleteSession() throws {
        let sessionUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Session")
        do {
            try FileManager.default.removeItem(at: sessionUrl)
        }
    }
}
