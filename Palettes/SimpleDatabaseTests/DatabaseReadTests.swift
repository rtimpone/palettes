//
//  DatabaseReadTests.swift
//  SimpleDatabaseTests
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import XCTest
@testable import SimpleDatabase

class DatabaseReadTests: DatabaseTestCase {
    
    func testReadEmptyDatabase() throws {
        let objects = try database.fetchObjects(ofType: TestObject.self)
        XCTAssertTrue(objects.isEmpty, "Expected the array to be empty because there is nothing in the database")
    }
    
    func testFetchObjectThatExistsInDatabase() throws {
        let foo = TestObject(name: "foo")
        let bar = TestObject(name: "bar")
        try database.upsertObjects([foo, bar])
        let fetchResult = try database.fetchObject(ofType: TestObject.self, withPrimaryKey: bar.primaryKey)
        XCTAssertEqual(fetchResult?.name, "bar", "Expected the correct object to have been fetched")
    }
    
    func testFetchObjectThatDoesNotExistInDatabase() throws {
        let randomPrimaryKey = UUID()
        let fetchResult = try database.fetchObject(ofType: TestObject.self, withPrimaryKey: randomPrimaryKey)
        XCTAssertNil(fetchResult)
    }
    
    func testFetchObjectOfType() throws {
        let foo = TestObject(name: "foo")
        let bar = OtherTestObject()
        try database.upsertObject(foo)
        try database.upsertObject(bar)
        let fetchedObjects = try database.fetchObjects(ofType: TestObject.self)
        XCTAssertEqual(fetchedObjects.count, 1, "Expected only one object to be returned because we only inserted one of type TestObject")
    }
}
