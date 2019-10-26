//
//  UserDefaultsDatabase.swift
//  SimpleDatabase
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import Foundation

enum UserDefaultDatabaseError: Error {
    case duplicateFoundWhileTryingToInsert(String)
    case objectNotFound(String)
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
    
    func insertObject<T: Persistable>(_ object: T) throws {
        var objects = try fetchObjects(ofType: T.self)
        guard objects.first(where: { $0.primaryKey == object.primaryKey }) == nil else {
            let errorMessage = "Cannot insert object '\(object)' because an object with its primary key already exists"
            throw UserDefaultDatabaseError.duplicateFoundWhileTryingToInsert(errorMessage)
        }
        objects.append(object)
        try write(objects: objects, ofType: T.self)
        notifyObservers(forType: T.self, ofUpdatedValues: objects)
    }
    
    func updateObject<T: Persistable>(_ object: T) throws {
        var objects = try fetchObjects(ofType: T.self)
        guard let oldObjectIndex = objects.firstIndex(where: { $0.primaryKey == object.primaryKey }) else {
            let errorMessage = "Unable to find object with primary key '\(object.primaryKey)' for update"
            throw UserDefaultDatabaseError.objectNotFound(errorMessage)
        }
        objects.remove(at: oldObjectIndex)
        objects.append(object)
        try write(objects: objects, ofType: T.self)
        notifyObservers(forType: T.self, ofUpdatedValues: objects)
    }
    
    func upsertObject<T: Persistable>(_ object: T) throws {
        var objects = try fetchObjects(ofType: T.self)
        if let oldObjectIndex = objects.firstIndex(where: { $0.primaryKey == object.primaryKey }) {
            objects.remove(at: oldObjectIndex)
        }
        objects.append(object)
        try write(objects: objects, ofType: T.self)
        notifyObservers(forType: T.self, ofUpdatedValues: objects)
    }
    
    func deleteObject<T: Persistable>(_ object: T) throws {
        var objects = try fetchObjects(ofType: T.self)
        guard let objectIndex = objects.firstIndex(where: { $0.primaryKey == object.primaryKey }) else {
            let errorMessage = "Unable to find object with primary key '\(object.primaryKey)' for deletion"
            throw UserDefaultDatabaseError.objectNotFound(errorMessage)
        }
        objects.remove(at: objectIndex)
        try write(objects: objects, ofType: T.self)
        notifyObservers(forType: T.self, ofUpdatedValues: objects)
    }
    
    func fetchObject<T: Persistable>(ofType type: T.Type, withPrimaryKey primaryKey: T.PrimaryKey) throws -> T? {
        let objects = try fetchObjects(ofType: type)
        return objects.first(where: { $0.primaryKey == primaryKey })
    }
    
    func fetchObjects<T: Persistable>(ofType type: T.Type) throws -> [T] {
        return try read(objectsOfType: T.self)
    }
    
    mutating func addObserver<O: DatabaseObserver, T: Persistable>(_ observer: O, forType type: T.Type) throws {
        observationManager.addObserver(observer, forType: type)
        let objects = try fetchObjects(ofType: type)
        observer.databaseDidAddObserver(initialValues: objects)
    }
}

private extension UserDefaultDatabase {
    
    func read<T: Codable>(objectsOfType type: T.Type) throws -> [T] {
        let key = String(describing: type)
        guard let value = defaults.value(forKey: key) else {
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
        let key = String(describing: type)
        guard let data = try? encoder.encode(objects) else {
            let errorMessage = "Unable to encode array of objects: \(objects)"
            throw UserDefaultDatabaseError.writeError(errorMessage)
        }
        defaults.setValue(data, forKey: key)
    }
    
    func notifyObservers<T>(forType type: T.Type, ofUpdatedValues updatedValues: [T]) {
        let typeObservers = observationManager.observers(forType: type)
        for observer in typeObservers {
            observer.databaseDidChange(updatedValues: updatedValues)
        }
    }
}
