//
//  tiptestApp.swift
//  tiptest
//
//  Created by Nikolai Trukhin on 04.08.2023.
//

import SwiftUI
import TipKit

@main
struct tiptestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    init() {
        Task {
            try? await Tips.configure {
                /// The frequency your tips display.
                /// .immediate, .hourly, .daily, .weekly, .monthly or custom TimeInterval
                DisplayFrequency(.immediate)
                
                /// A location for persisting your application's tips and associated data.
                DatastoreLocation(.applicationDefault)
            }
            
            Tips.showAllTips()
        }
    }
}
