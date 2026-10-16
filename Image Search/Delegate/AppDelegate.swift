//
//  AppDelegate.swift
//  Image Search
//
//  Created by Daniel Husiuk on 05.10.2026.
//

import UIKit

#if DEBUG
import netfox
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        #if DEBUG
        NFX.sharedInstance().start()
        #endif
        
        return true
    }
}
