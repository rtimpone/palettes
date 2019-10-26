//
//  Database.swift
//  SimpleDatabase
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import Foundation

protocol Database {
    func insertObject<T: Codable>(_ object: T)
    func updateObject<T: Codable>(_ object: T) where T: Persistable
    func upsertObject<T: Codable>(_ object: T) where T: Persistable
    func deleteObject<T: Codable>(_ object: T) where T: Persistable
    func fetchObjects<T: Codable>(ofType type: T.Type) -> [T]
}

protocol Persistable {
    associatedtype PrimaryKey
}
