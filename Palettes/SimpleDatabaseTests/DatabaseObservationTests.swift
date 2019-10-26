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
        
        try database.insertObject(foo)
        try database.insertObject(bar)
        
        let observer = TestObserver()
        try database.addObserver(observer, forType: TestObject.self)
        XCTAssertEqual(observer.initialValuesObserved?.count, 2, "Expected observer to be called with database initially populated with two objects")
    }
    
    func testInsertObservation() throws {
        let observer = TestObserver()
        try database.addObserver(observer, forType: TestObject.self)
        let object = TestObject(name: "foo")
        try database.insertObject(object)
        XCTAssertEqual(observer.updatedValuesObserved?.count, 1, "Expected observer to be called when an object is inserted")
    }
    
    func testUpdateObservation() throws {
        let object = TestObject(name: "foo")
        try database.insertObject(object)
        let observer = TestObserver()
        try database.addObserver(observer, forType: TestObject.self)
        try database.updateObject(object)
        XCTAssertEqual(observer.updatedValuesObserved?.count, 1, "Expected observer to be called when an object is updated")
    }
    
    func testUpsertInsertObservation() throws {
        let observer = TestObserver()
        try database.addObserver(observer, forType: TestObject.self)
        let object = TestObject(name: "foo")
        try database.upsertObject(object)
        XCTAssertEqual(observer.updatedValuesObserved?.count, 1, "Expected observer to be called when an object is inserted via upsert")
    }
    
    func testUpsertUpdateObservation() throws {
        let object = TestObject(name: "foo")
        try database.insertObject(object)
        let observer = TestObserver()
        try database.addObserver(observer, forType: TestObject.self)
        try database.upsertObject(object)
        XCTAssertEqual(observer.updatedValuesObserved?.count, 1, "Expected observer to be called when an object is updated via upsert")
    }
    
    func testDeleteObservation() throws {
        let object = TestObject(name: "foo")
        try database.insertObject(object)
        let observer = TestObserver()
        try database.addObserver(observer, forType: TestObject.self)
        try database.deleteObject(object)
        XCTAssertEqual(observer.updatedValuesObserved?.count, 0, "Expected observer to be called when an object is deleted")
    }
    
    func testDeallocatingObserver() throws {
        
        var observer: TestObserver? = TestObserver()
        try database.addObserver(observer!, forType: TestObject.self)
        
        var observersCount = database.observationManager.numberOfObservers()
        XCTAssertEqual(observersCount, 1, "Expected the database to have an observer because we just added one")
        
        observer = nil
        
        let object = TestObject(name: "foo")
        try database.insertObject(object)
        
        observersCount = database.observationManager.numberOfObservers()
        XCTAssertEqual(observersCount, 0, "Expected the database to no longer have any observers since the observer was deallocated")
    }
    
    func testMultipleObserversAreNotified() throws {
        
        let observer1 = TestObserver()
        let observer2 = TestObserver()
        
        try database.addObserver(observer1, forType: TestObject.self)
        try database.addObserver(observer2, forType: TestObject.self)
        
        let object = TestObject(name: "foo")
        try database.insertObject(object)
        
        XCTAssertEqual(observer1.updatedValuesObserved?.count, 1, "Expected first observer to have been notified of the insert")
        XCTAssertEqual(observer2.updatedValuesObserved?.count, 1, "Expected second observer to have been notified of the insert")
    }
}
