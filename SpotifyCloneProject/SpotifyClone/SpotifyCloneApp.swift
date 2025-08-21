//
//  SpotifyCloneApp.swift
//  SpotifyClone
//
//  Created by Gabriel on 8/30/21.
//

import SwiftUI

@main
struct SpotifyCloneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        let mainViewModel = MainViewModel()

        WindowGroup {
            MainView(mainViewModel: mainViewModel)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Check for return after onboarding
        AnalyticsManager.shared.checkForReturnAfterOnboarding()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Check for return after onboarding
        AnalyticsManager.shared.checkForReturnAfterOnboarding()
    }
}
