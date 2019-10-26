//
//  ObservationManager.swift
//  SimpleDatabase
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import Foundation

struct ObservationManager {
    
    private var observersDictionary: [String: NSHashTable<AnyObject>] = [:]
    
    func numberOfObservers() -> Int {
        var observersCount = 0
        autoreleasepool {
            for (_, observers) in observersDictionary {
                observersCount += observers.allObjects.count
            }
        }
        return observersCount
    }
    
    func observers<T>(forType type: T.Type) -> [DatabaseObserver] {
        let key = String(describing: type)
        guard let typeObservers = observersDictionary[key] else {
            return []
        }
        return typeObservers.allObjects.compactMap { $0 as? DatabaseObserver }
    }
    
    mutating func addObserver<T>(_ observer: DatabaseObserver, forType type: T.Type) {
        let key = String(describing: type)
        let typeObservers = observersDictionary[key] ?? NSHashTable.weakObjects()
        typeObservers.add(observer)
        observersDictionary[key] = typeObservers
    }
}
