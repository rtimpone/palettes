//
//  UserDefaultsDatabase.swift
//  SimpleDatabase
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import Foundation

struct UserDefaultDatabase: Database {
 
    let defaults: UserDefaults
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func insertObject<T: Codable>(_ object: T) {
        var objects = fetchObjects(ofType: T.self)
        objects.append(object)
        write(objects: objects, ofType: T.self)
    }
    
    func updateObject<T: Codable>(_ object: T) where T: Persistable {
            
    }
    
    func upsertObject<T: Codable>(_ object: T) where T: Persistable {
                
    }
    
    func deleteObject<T: Codable>(_ object: T) where T: Persistable {
                    
    }
    
    func fetchObjects<T: Codable>(ofType type: T.Type) -> [T] {
        return read(objectsOfType: T.self)
    }
}

private extension UserDefaultDatabase {
    
    func read<T: Codable>(objectsOfType type: T.Type) -> [T] {
        let key = String(describing: type)
        guard let value = defaults.value(forKey: key) else {
            return []
        }
        guard let data = value as? Data else {
            fatalError("Found non-data type in defaults for key '\(key)'")
        }
        guard let objects = try? decoder.decode([T].self, from: data) else {
            fatalError("Unable to decode objects for key '\(key)'")
        }
        return objects
    }
    
    func write<T: Codable>(objects: [T], ofType type: T.Type) {
        let key = String(describing: type)
        guard let data = try? encoder.encode(objects) else {
            fatalError("Unable to encode array: \(objects)")
        }
        defaults.setValue(data, forKey: key)
    }
}
