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
    
    func testReadEmptyDatabase() throws {
        let objects = try database.fetchObjects(ofType: TestObject.self)
        XCTAssertTrue(objects.isEmpty, "Expected the array to be empty because there is nothing in the database")
    }
    
    func testInsertObject() throws {
        
        let object = TestObject(name: "foo")
        try database.insertObject(object)
        
        let objects = try database.fetchObjects(ofType: TestObject.self)
        XCTAssertEqual(objects.count, 1, "Expected there to be exactly one item in the database because that's the only thing we've written to it")
    }
    
    func testInsertingMultipleObjects() throws {
        
        let foo = TestObject(name: "foo")
        let bar = TestObject(name: "bar")
        
        try database.insertObject(foo)
        try database.insertObject(bar)
        
        let objects = try database.fetchObjects(ofType: TestObject.self)
        XCTAssertEqual(objects.count, 2, "Expected both objects to be present in the database")
    }
    
    func testInsertingDuplicateObjectThrows() throws {
        let object = TestObject(name: "foo")
        try database.insertObject(object)
        XCTAssertThrowsError(try database.insertObject(object)) { error in
            guard case UserDefaultDatabaseError.duplicateFoundWhileTryingToInsert(_) = error else {
                XCTFail("Wrong error type thrown for attempting to insert a duplicate object")
                return
            }
        }
    }
    
    func testUpdateObject() throws {
        
        let object = TestObject(name: "foo")
        try database.insertObject(object)
        
        let newObject = TestObject(name: "bar", primaryKey: object.primaryKey)
        try database.updateObject(newObject)
        
        let objects = try database.fetchObjects(ofType: TestObject.self)
        XCTAssertEqual(objects.count, 1, "Expected there to be only one object in the database because we inserted one, then updated it")
        
        let fetchedObject = try XCTUnwrap(objects.first)
        XCTAssertEqual(fetchedObject.name, "bar", "Expected the name to be updated to the new value we gave it")
    }
    
    func testUpdatingNonExistantObjectThrows() {
        let object = TestObject(name: "foo")
        XCTAssertThrowsError(try database.updateObject(object)) { error in
            guard case UserDefaultDatabaseError.objectNotFound(_) = error else {
                XCTFail("Wrong error type was thrown for attempting to update an object that does not exist")
                return
            }
        }
    }
    
    func testUpsertingNewObjectInsertsIt() throws {
        let object = TestObject(name: "foo")
        try database.upsertObject(object)
        let objects = try database.fetchObjects(ofType: TestObject.self)
        XCTAssertEqual(objects.count, 1, "Expected the object to have been inserted in the database")
    }
    
    func testUpsertingExistingObjectUpdatesIt() throws {
        
        let object = TestObject(name: "foo")
        try database.upsertObject(object)
        
        let updatedObject = TestObject(name: "bar", primaryKey: object.primaryKey)
        try database.upsertObject(updatedObject)
        
        let objects = try database.fetchObjects(ofType: TestObject.self)
        XCTAssertEqual(objects.count, 1, "Expected there to be only one object in the database because we should have inserted one, then updated it during the two upserts")
        
        let fetchedObject = try XCTUnwrap(objects.first)
        XCTAssertEqual(fetchedObject.name, "bar", "Expected the name to be updated to the new value we gave it")
    }
    
    func testDeleteObject() throws {
        
        let foo = TestObject(name: "foo")
        let bar = TestObject(name: "bar")
        
        try database.insertObject(foo)
        try database.insertObject(bar)
        
        try database.deleteObject(foo)
        let objects = try database.fetchObjects(ofType: TestObject.self)
        XCTAssertEqual(objects.count, 1, "Expected only one item to remain in the database because we deleted the other one")
        
        let object = try XCTUnwrap(objects.first)
        XCTAssertEqual(object.name, "bar", "Expected the database to have deleted the 'foo' object")
    }
    
    func testFetchObjectThatExistsInDatabase() throws {
        
        let foo = TestObject(name: "foo")
        let bar = TestObject(name: "bar")
        
        try database.insertObject(foo)
        try database.insertObject(bar)
        
        let fetchResult = try database.fetchObject(ofType: TestObject.self, withPrimaryKey: bar.primaryKey)
        let object = try XCTUnwrap(fetchResult)
        XCTAssertEqual(object.name, "bar", "Expected the correct object to have been fetched")
    }
    
    func testFetchObjectThatDoesNotExistInDatabase() throws {
        let randomPrimaryKey = UUID()
        let fetchResult = try database.fetchObject(ofType: TestObject.self, withPrimaryKey: randomPrimaryKey)
        XCTAssertNil(fetchResult)
    }
}
