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
    
    struct TestObject: Codable {
        let name: String
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
}
