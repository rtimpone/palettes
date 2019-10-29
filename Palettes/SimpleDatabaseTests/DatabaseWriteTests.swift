//
//  DatabaseWriteTests.swift
//  SimpleDatabaseTests
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import XCTest
@testable import SimpleDatabase

class DatabaseWriteTests: DatabaseTestCase {

    func testInsertObject() throws {
        let object = TestObject(name: "foo")
        try database.upsertObject(object)
        let objects = try database.fetchObjects(ofType: TestObject.self)
        XCTAssertEqual(objects.count, 1, "Expected there to be exactly one item in the database because that's the only thing we've written to it")
    }
    
    func testInsertingMultipleObjects() throws {
        let foo = TestObject(name: "foo")
        let bar = TestObject(name: "bar")
        try database.upsertObject(foo)
        try database.upsertObject(bar)
        let objects = try database.fetchObjects(ofType: TestObject.self)
        XCTAssertEqual(objects.count, 2, "Expected both objects to be present in the database")
    }
    
    func testBatchInsertObjects() throws {
        let foo = TestObject(name: "foo")
        let bar = TestObject(name: "bar")
        try database.upsertObjects([foo, bar])
        let objects = try database.fetchObjects(ofType: TestObject.self)
        XCTAssertEqual(objects.count, 2, "Expected both objects to be present in the database")
    }
    
    func testUpdateObject() throws {
        let object = TestObject(name: "foo")
        try database.upsertObject(object)
        let newObject = TestObject(name: "bar", primaryKey: object.primaryKey)
        try database.upsertObject(newObject)
        let objects = try database.fetchObjects(ofType: TestObject.self)
        XCTAssertEqual(objects.count, 1, "Expected there to be only one object in the database because we inserted one, then updated it")
        XCTAssertEqual(objects.first?.name, "bar", "Expected the name to be updated to the new value we gave it")
    }
    
    func testBatchUpdate() throws {
        
        let foo = TestObject(name: "foo")
        let bar = TestObject(name: "bar")
        try database.upsertObjects([foo, bar])
        
        let modifiedFoo = TestObject(name: "FOO", primaryKey: foo.primaryKey)
        let modifiedBar = TestObject(name: "BAR", primaryKey: bar.primaryKey)
        try database.upsertObjects([modifiedFoo, modifiedBar])
        
        let fetchedFoo = try database.fetchObject(ofType: TestObject.self, withPrimaryKey: foo.primaryKey)
        let fetchedBar = try database.fetchObject(ofType: TestObject.self, withPrimaryKey: bar.primaryKey)
        XCTAssertEqual(fetchedFoo?.name, "FOO", "Expected the foo database object's name to have been updated")
        XCTAssertEqual(fetchedBar?.name, "BAR", "Expected the bar database object's name to have been updated")
    }
    
    func testBatchInsertAndUpdate() throws {
        
        let foo = TestObject(name: "foo")
        let bar = TestObject(name: "bar")
        try database.upsertObject(foo)
        
        let updatedFoo = TestObject(name: "FOO", primaryKey: foo.primaryKey)
        try database.upsertObjects([updatedFoo, bar])
        
        let fetchedFoo = try database.fetchObject(ofType: TestObject.self, withPrimaryKey: foo.primaryKey)
        XCTAssertEqual(fetchedFoo?.name, "FOO")
        
        let fetchedObjects = try database.fetchObjects(ofType: TestObject.self)
        XCTAssertEqual(fetchedObjects.count, 2, "Expected two objects to be in the database because we wrote two of them")
    }
    
    func testDeleteObject() throws {
        let foo = TestObject(name: "foo")
        let bar = TestObject(name: "bar")
        try database.upsertObject(foo)
        try database.upsertObject(bar)
        try database.deleteObject(foo)
        let objects = try database.fetchObjects(ofType: TestObject.self)
        XCTAssertEqual(objects.count, 1, "Expected only one item to remain in the database because we deleted the other one")
        XCTAssertEqual(objects.first?.name, "bar", "Expected the database to have deleted the 'foo' object")
    }
    
    func testBatchDelete() throws {
        let foo = TestObject(name: "foo")
        let bar = TestObject(name: "bar")
        try database.upsertObjects([foo, bar])
        try database.deleteObjects([foo, bar])
        let objects = try database.fetchObjects(ofType: TestObject.self)
        XCTAssertTrue(objects.isEmpty, "Expected both objects to have been deleted from the database")
    }
    
    func testResetDatabaseRemovesAllObjects() throws {
        let foo = TestObject(name: "foo")
        let bar = TestObject(name: "bar")
        let baz = OtherTestObject()
        try database.upsertObjects([foo, bar])
        try database.upsertObject(baz)
        database.resetDatabase()
        let testObjects = try database.fetchObjects(ofType: TestObject.self)
        let otherTestObjects = try database.fetchObjects(ofType: OtherTestObject.self)
        XCTAssertTrue(testObjects.isEmpty, "Expected all test objects to have been removed from the database")
        XCTAssertTrue(otherTestObjects.isEmpty, "Expected all other test objects to have been removed from the database")
    }
}
