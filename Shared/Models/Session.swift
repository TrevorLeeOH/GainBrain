//
//  Session.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/8/22.
//

import Foundation

class Session: ObservableObject {
    
    @Published var workouts: [WorkoutDTO]
    
    init(workouts: [WorkoutDTO]) {
        self.workouts = workouts
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
    
    static func getSession() throws -> Session {
        print("called get session")
        
        let sessionUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Session")
        
        if FileManager.default.fileExists(atPath: sessionUrl.path) {
            do {
                let sessionData: Data = try String(contentsOfFile: sessionUrl.path).data(using: .utf8)!
                let decoder = JSONDecoder()
                let workoutsIds: [Int64] = try decoder.decode([Int64].self, from: sessionData)
                
                var workouts: [WorkoutDTO] = []
                
                for workoutId in workoutsIds {
                    try workouts.append(WorkoutDao.get(workoutId: workoutId))
                }
                
                return Session(workouts: workouts)
            }
            
        } else {
            throw NoSessionExistsError()
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


class NoSessionExistsError: Error {
    
}
