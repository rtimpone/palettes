//
//  AppDelegate.swift
//  Palettes
//
//  Created by Rob Timpone on 10/26/19.
//  Copyright © 2019 Rob Timpone. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let vc = ListViewController.instantiateFromStoryboard()
        let nvc = UINavigationController(rootViewController: vc)
        window.rootViewController = nvc
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
