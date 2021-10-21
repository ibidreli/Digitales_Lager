//
//  Digitales_LagerApp.swift
//  Digitales_Lager
//
//  Created by Elias Pulver on 23.09.21.
//

import GoogleSignIn
import SwiftUI
import Firebase

@main
struct Digitales_LagerApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    
    var body: some Scene {
        WindowGroup {
            let viewModel = AppViewModel()
            ContentView()
                .environmentObject(viewModel)
            
        }
    }
}



class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        
        return true
    }
    
    
    
    
}
