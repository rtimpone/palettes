//
//  UserDefaultsDatabase.swift
//  SimpleDatabase
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import Foundation

enum UserDefaultDatabaseError: Error {
    case readError(String)
    case writeError(String)
}

struct UserDefaultDatabase: Database {
    
    let defaults: UserDefaults
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    var observationManager = ObservationManager()
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func upsertObject<T: Persistable>(_ object: T) throws {
        try upsertObjects([object])
    }
    
    func upsertObjects<T: Persistable>(_ objectsToUpsert: [T]) throws {
        try removeObjectsFromDatabaseWithPrimaryKeysMatchingObjectsIn(objectsToUpsert, andAddNewObjectsToDatabase: objectsToUpsert)
    }
    
    func deleteObject<T: Persistable>(_ object: T) throws {
        try deleteObjects([object])
    }
    
    func deleteObjects<T: Persistable>(_ objectsToDelete: [T]) throws {
        try removeObjectsFromDatabaseWithPrimaryKeysMatchingObjectsIn(objectsToDelete)
    }
    
    func fetchObject<T: Persistable>(ofType type: T.Type, withPrimaryKey primaryKey: T.PrimaryKey) throws -> T? {
        let objects = try fetchObjects(ofType: type)
        return objects.first(where: { $0.primaryKey == primaryKey })
    }
    
    func fetchObjects<T: Persistable>(ofType type: T.Type) throws -> [T] {
        return try read(objectsOfType: T.self)
    }
    
    mutating func addObserver<O: DatabaseObserver, T: Persistable>(_ observer: O, forType type: T.Type) throws {
        let initialValues = try fetchObjects(ofType: type)
        observationManager.addObserver(observer, forType: type, withInitialValues: initialValues)
    }
    
    func resetDatabase() {
        writeDictionaryToUserDefaults([:])
        observationManager.notifyObserversOfDatabaseReset()
    }
}

private extension UserDefaultDatabase {
    
    static let dictionaryKey = "userDefaultsDictionaryDatabaseKey"
    
    func readDictionaryFromUserDefaults() -> [String: Any] {
        return defaults.value(forKey: UserDefaultDatabase.dictionaryKey) as? [String: Any] ?? [:]
    }
    
    func writeDictionaryToUserDefaults(_ dictionary: [String: Any]) {
        defaults.setValue(dictionary, forKey: UserDefaultDatabase.dictionaryKey)
    }
    
    func read<T: Codable>(objectsOfType type: T.Type) throws -> [T] {
        let dictionary = readDictionaryFromUserDefaults()
        let key = String(describing: type)
        guard let value = dictionary[key] else {
            return []
        }
        guard let data = value as? Data else {
            let errorMessage = "Found non-Data type object in defaults for key '\(key)'"
            throw UserDefaultDatabaseError.readError(errorMessage)
        }
        guard let objects = try? decoder.decode([T].self, from: data) else {
            let errorMessage = "Unable to decode objects for key '\(key)'"
            throw UserDefaultDatabaseError.readError(errorMessage)
        }
        return objects
    }
    
    func write<T: Codable>(objects: [T], ofType type: T.Type) throws {
        var dictionary = readDictionaryFromUserDefaults()
        let key = String(describing: type)
        guard let data = try? encoder.encode(objects) else {
            let errorMessage = "Unable to encode array of objects: \(objects)"
            throw UserDefaultDatabaseError.writeError(errorMessage)
        }
        dictionary[key] = data
        writeDictionaryToUserDefaults(dictionary)
    }
    
    func removeObjectsFromDatabaseWithPrimaryKeysMatchingObjectsIn<T: Persistable>(_ objectsToRemove: [T], andAddNewObjectsToDatabase objectsToInsert: [T]? = nil) throws {
        var databaseObjects = try fetchObjects(ofType: T.self)
        let primaryKeysOfObjectsToRemove = Set(objectsToRemove.map { $0.primaryKey })
        databaseObjects.removeAll(where: { primaryKeysOfObjectsToRemove.contains($0.primaryKey) })
        if let objectsToInsert = objectsToInsert {
            databaseObjects.append(contentsOf: objectsToInsert)
        }
        try write(objects: databaseObjects, ofType: T.self)
        observationManager.notifyObservers(forType: T.self, ofUpdatedValues: databaseObjects)
    }
}
