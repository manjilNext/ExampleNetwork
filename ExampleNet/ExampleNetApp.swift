//
//  ExampleNetApp.swift
//  ExampleNet
//
//  Created by Manjil Rajbhandari on 18/07/2024.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Your code here")
        let tokenManager = TokenManager()
        let config = NetworkingConfiguration(baseURL: "http://10.13.164.211:11184", tokenManageable: tokenManager, printLogger: true)
        NetworkingDefault.initialize(with: config)
        return true
    }
}

@main
struct ExampleNetApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
