//
//  Database.swift
//  SimpleDatabase
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import Foundation

typealias Persistable = Codable & UniquelyIdentifiable

protocol Database {
    
    func upsertObject<T: Persistable>(_ object: T) throws
    func upsertObjects<T: Persistable>(_ objects: [T]) throws
    
    func deleteObject<T: Persistable>(_ object: T) throws
    func deleteObjects<T: Persistable>(_ objects: [T]) throws
    
    func fetchObject<T: Persistable>(ofType type: T.Type, withPrimaryKey primaryKey: T.PrimaryKey) throws -> T?
    func fetchObjects<T: Persistable>(ofType type: T.Type) throws -> [T]
    
    mutating func addObserver<O: DatabaseObserver, T: Persistable>(_ observer: O, forType type: T.Type) throws
    
    func resetDatabase()
}

protocol UniquelyIdentifiable {
    associatedtype PrimaryKey: Hashable
    var primaryKey: PrimaryKey { get }
}

protocol DatabaseObserver: class {
    func databaseDidAddObserver<T>(initialValues: [T])
    func databaseDidChange<T>(updatedValues: [T])
}
