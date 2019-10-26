//
//  UserDefaultsDatabaseTests.swift
//  SimpleDatabaseTests
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import XCTest
@testable import SimpleDatabase

class UserDefaultsDatabaseTests: XCTestCase {

    var database: UserDefaultDatabase!
    
    override func setUp() {
        super.setUp()
        UserDefaults().removePersistentDomain(forName: name)
        let defaults = UserDefaults(suiteName: name)!
        database = UserDefaultDatabase(defaults: defaults)
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
    
    func testReadEmptyDatabase() {
        let objects = database.fetchObjects(ofType: TestObject.self)
        XCTAssertTrue(objects.isEmpty, "Expected the array to be empty because there is nothing in the database")
    }
    
    func testInsertObject() {
        
        let object = TestObject(name: "foo")
        database.insertObject(object)
        
        let objects = database.fetchObjects(ofType: TestObject.self)
        XCTAssertEqual(objects.count, 1, "Expected there to be exactly one item in the database because that's the only thing we've written to it")
    }
    
    func testInsertingDuplicateObjectThrows() {
        
    }
    
    func testUpdateObject() throws {
        
        let object = TestObject(name: "foo")
        database.insertObject(object)
        
        let newObject = TestObject(name: "bar", primaryKey: object.primaryKey)
        try database.updateObject(newObject)
        
        let objects = database.fetchObjects(ofType: TestObject.self)
        XCTAssertEqual(objects.count, 1, "Expected there to be only one object in the database because we inserted one, then updated it")
        
        let fetchedObject = try XCTUnwrap(objects.first)
        XCTAssertEqual(fetchedObject.name, "bar", "Expected the name to be updated to the new value we gave it")
    }
    
    func testUpdatingNonExistantObjectThrows() {
        let object = TestObject(name: "foo")
        XCTAssertThrowsError(try database.updateObject(object)) { error in
            guard case UserDefaultDatabaseError.objectForUpdateNotFound(_) = error else {
                XCTFail("Wrong error type was thrown for attempting to update an object that does not exist")
                return
            }
        }
    }
}
