//
//  AppDelegate.swift
//  Beeline
//
//  Created by zip520123 on 28/08/2020.
//  Copyright © 2020 zip520123. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    let defaultVC = ViewController()
    
    window?.rootViewController = defaultVC
    return true
  }

}

