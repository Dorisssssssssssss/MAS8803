//
//  _803NourishFitApp.swift
//  8803NourishFit
//
//  Created by XIN on 10/14/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@main
struct _803NourishFitApp: App {
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Disable App Check for development
        #if DEBUG
        // Skip App Check in debug mode
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
