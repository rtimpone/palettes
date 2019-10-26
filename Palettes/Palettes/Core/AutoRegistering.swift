//
//  AutoRegistering.swift
//  Palettes
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import UIKit

protocol XibBased: class {
    
    static var xibName: String { get }
}

extension XibBased {
    
    static var xibName: String {
        return String(describing: self)
    }
}

enum RegistrationType {
    case cell
    case header
}

protocol XibRegistering {
    func hasRegisteredType<T: XibBased>(_ type: T.Type, as registrationType: RegistrationType) -> Bool
    func registerType<T: XibBased>(_ type: T.Type, as registrationType: RegistrationType)
}

extension UITableView: XibRegistering {
    
    func hasRegisteredType<T: XibBased>(_ type: T.Type, as registrationType: RegistrationType) -> Bool {
        guard let registeredCells = registeredCells else {
            return false
        }
        return registeredCells.contains(type.xibName)
    }
    
    func registerType<T: XibBased>(_ type: T.Type, as registrationType: RegistrationType) {
        
        let xibName = type.xibName
        let bundle = Bundle(for: type)
        let nib = UINib(nibName: xibName, bundle: bundle)
        
        switch registrationType {
        case .cell:
            register(nib, forCellReuseIdentifier: xibName)
            registerCell(withIdentifier: xibName)
        case .header:
            register(nib, forHeaderFooterViewReuseIdentifier: xibName)
            registerHeader(withIdentifier: xibName)
        }
    }
    
    func registerCell(withIdentifier identifier: String) {
        if registeredCells == nil {
            registeredCells = Set<String>()
        }
        registeredCells?.insert(identifier)
    }
    
    func registerHeader(withIdentifier identifier: String) {
        if registeredHeaders == nil {
            registeredHeaders = Set<String>()
        }
        registeredHeaders?.insert(identifier)
    }
}

extension UIView: XibBased {
    
    // make all views xib based by default
}

private extension UITableView {
    
    struct AssociatedKeys {
        static var registeredCells = "kRegisteredCells"
        static var registeredHeaders = "kRegisteredHeaders"
    }
    
    //this allows us to add a stored property of type Set<String> to all UITableViews via an extension
    var registeredCells: Set<String>? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.registeredCells) as? Set<String>
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.registeredCells, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    var registeredHeaders: Set<String>? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.registeredHeaders) as? Set<String>
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.registeredHeaders, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

public extension UITableView {
    
    func dequeueReusableHeader<T: UIView>(ofType type: T.Type) -> T {
        
        if !hasRegisteredType(type, as: .header) {
            registerType(type, as: .header)
        }
        
        let identifier = type.xibName
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: identifier) else {
            fatalError("Unable to dequeue reusable header with identifier '\(identifier)'")
        }
        
        guard let typedView = view as? T else {
            fatalError("Header view that was dequeued for identifier '\(identifier)' could not be casted to type '\(String(describing: type))'")
        }
        
        return typedView
    }
    
    func dequeueReusableCell<T: UITableViewCell>(ofType type: T.Type) -> T {
        
        if !hasRegisteredType(type, as: .cell) {
            registerType(type, as: .cell)
        }
        
        let identifier = type.xibName
        guard let cell = dequeueReusableCell(withIdentifier: identifier) else {
            fatalError("Unable to dequeue reusable cell with identifier '\(identifier)'")
        }
        
        guard let typedCell = cell as? T else {
            fatalError("Cell that was dequeued for identifier '\(identifier)' could not be casted to type '\(String(describing: type))'")
        }
        
        return typedCell
    }
}
