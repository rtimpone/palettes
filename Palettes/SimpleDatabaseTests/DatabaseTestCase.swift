//
//  DatabaseTestCase.swift
//  SimpleDatabaseTests
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import XCTest
@testable import SimpleDatabase

class DatabaseTestCase: XCTestCase {
    
    var database: UserDefaultDatabase!
    
    override func setUp() {
        super.setUp()
        UserDefaults().removePersistentDomain(forName: name)
        let defaults = UserDefaults(suiteName: name)!
        database = UserDefaultDatabase(defaults: defaults)
    }
}

struct TestObject: Codable, UniquelyIdentifiable {
    
    typealias PrimaryKey = UUID
    let primaryKey: UUID
    let name: String
    
    init(name: String, primaryKey: UUID = UUID()) {
        self.name = name
        self.primaryKey = primaryKey
    }
}
