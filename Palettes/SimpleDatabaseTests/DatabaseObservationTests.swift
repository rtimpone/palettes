//
//  DatabaseObservationTests.swift
//  SimpleDatabaseTests
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import XCTest
@testable import SimpleDatabase

class DatabaseObservationTests: DatabaseTestCase {

    class TestObserver: DatabaseObserver {
        
        var initialValuesObserved: [Any]?
        var updatedValuesObserved: [Any]?
        
        func databaseDidAddObserver<T>(initialValues: [T]) {
            initialValuesObserved = initialValues
        }
        
        func databaseDidChange<T>(updatedValues: [T]) {
            updatedValuesObserved = updatedValues
        }
    }
    
    func testAddingObserverToEmptyDatabase() throws {
        let observer = TestObserver()
        try database.addObserver(observer, forType: TestObject.self)
        XCTAssertEqual(observer.initialValuesObserved?.count, 0, "Expected observer to be called with database initially empty")
    }
    
    func testAddingObserverToPopulatedDatabase() throws {
        let foo = TestObject(name: "foo")
        let bar = TestObject(name: "bar")
        try database.upsertObjects([foo, bar])
        let observer = TestObserver()
        try database.addObserver(observer, forType: TestObject.self)
        XCTAssertEqual(observer.initialValuesObserved?.count, 2, "Expected observer to be called with database initially populated with two objects")
    }
    
    func testInsertObservation() throws {
        let observer = TestObserver()
        try database.addObserver(observer, forType: TestObject.self)
        let object = TestObject(name: "foo")
        try database.upsertObject(object)
        XCTAssertEqual(observer.updatedValuesObserved?.count, 1, "Expected observer to be called when an object is inserted")
    }
    
    func testObserverGetsAllValuesWhenObervingInsert() throws {
        let foo = TestObject(name: "foo")
        try database.upsertObject(foo)
        let observer = TestObserver()
        try database.addObserver(observer, forType: TestObject.self)
        let bar = TestObject(name: "bar")
        try database.upsertObject(bar)
        XCTAssertEqual(observer.updatedValuesObserved?.count, 2, "Expected observer to be notified of all database values after insert takes place, not just the value that was added")
    }
    
    func testUpdateObservation() throws {
        let object = TestObject(name: "foo")
        try database.upsertObject(object)
        let observer = TestObserver()
        try database.addObserver(observer, forType: TestObject.self)
        let updatedObject = TestObject(name: "FOO", primaryKey: object.primaryKey)
        try database.upsertObject(updatedObject)
        XCTAssertEqual(observer.updatedValuesObserved?.count, 1, "Expected observer to be called when an object is updated via upsert")
        let observedObject = try XCTUnwrap(observer.updatedValuesObserved?.first as? TestObject)
        XCTAssertEqual(observedObject.name, "FOO", "Expected the updated object to be returned to the observer")
    }
    
    func testDeleteObservation() throws {
        let object = TestObject(name: "foo")
        try database.upsertObject(object)
        let observer = TestObserver()
        try database.addObserver(observer, forType: TestObject.self)
        try database.deleteObject(object)
        XCTAssertEqual(observer.updatedValuesObserved?.count, 0, "Expected observer to be called when an object is deleted")
    }
    
    func testObserverGetsRemainingValuesInDatabaseWhenDeletingObject() throws {
        let foo = TestObject(name: "foo")
        let bar = TestObject(name: "bar")
        try database.upsertObjects([foo, bar])
        let observer = TestObserver()
        try database.addObserver(observer, forType: TestObject.self)
        try database.deleteObject(foo)
        XCTAssertEqual(observer.updatedValuesObserved?.count, 1, "Expected values sent to observer to indicate there is one value left in the database")
    }
    
    func testDeallocatingObserver() throws {
        var observer: TestObserver? = TestObserver()
        try database.addObserver(observer!, forType: TestObject.self)
        var observersCount = database.observationManager.numberOfObservers()
        XCTAssertEqual(observersCount, 1, "Expected the database to have an observer because we just added one")
        observer = nil
        let object = TestObject(name: "foo")
        try database.upsertObject(object)
        observersCount = database.observationManager.numberOfObservers()
        XCTAssertEqual(observersCount, 0, "Expected the database to no longer have any observers since the observer was deallocated")
    }
    
    func testMultipleObserversAreNotified() throws {
        let observer1 = TestObserver()
        let observer2 = TestObserver()
        try database.addObserver(observer1, forType: TestObject.self)
        try database.addObserver(observer2, forType: TestObject.self)
        let object = TestObject(name: "foo")
        try database.upsertObject(object)
        XCTAssertEqual(observer1.updatedValuesObserved?.count, 1, "Expected first observer to have been notified of the insert")
        XCTAssertEqual(observer2.updatedValuesObserved?.count, 1, "Expected second observer to have been notified of the insert")
    }
    
    func testOperationsForNonObservedObjectsAreIgnored() throws {
        let observer = TestObserver()
        try database.addObserver(observer, forType: TestObject.self)
        let nonObservedObject = OtherTestObject()
        try database.upsertObject(nonObservedObject)
        XCTAssertNil(observer.updatedValuesObserved, "Expected observer not to have been notified about an object type it is not observing")
        let observedObject = TestObject(name: "foo")
        try database.upsertObject(observedObject)
        XCTAssertEqual(observer.updatedValuesObserved?.count, 1, "Expected observer to have been notified about the object type it is observing")
    }
    
    func testResettingDatabaseNotifiesObserver() throws {
        let foo = TestObject(name: "foo")
        let bar = OtherTestObject()
        try database.upsertObject(foo)
        try database.upsertObject(bar)
        let observer1 = TestObserver()
        let observer2 = TestObserver()
        try database.addObserver(observer1, forType: TestObject.self)
        try database.addObserver(observer2, forType: OtherTestObject.self)
        database.resetDatabase()
        XCTAssertNotNil(observer1.updatedValuesObserved, "Expected observer to have been notified all values were removed")
        XCTAssertNotNil(observer2.updatedValuesObserved, "Expected observer to have been notified all values were removed")
    }
}
