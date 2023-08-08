//
//  ContentView.swift
//  tiptest
//
//  Created by Nikolai Trukhin on 04.08.2023.
//

import SwiftUI
import TipKit

struct ContentView: View {
    private let myTip = FavoriteBackyardTip()

    private let edge: Edge = .top

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            TipView(
                myTip,
                arrowEdge: edge,
                action: actionHandler
            )
            Text("Hello, world!")
                .popoverTip(
                    myTip,
                    arrowEdge: edge,
                    action: actionHandler
                )
        }
        .onAppear {
            simpleEvent.donate()
            complexEvent.donate(
                .init(id: 123, name: "name")
            )
        }
        .padding()
    }

    func actionHandler(action: Tip.Action) {
        debugPrint("button tapped (\(action.id)")
    }
}

#Preview {
    ContentView()
        .task {
            /// Tips.configure(options:) must be called before your tip will be eligible for display.
            try? await Tips.configure {
                /// The frequency your tips display.
                /// .immediate, .hourly, .daily, .weekly, .monthly or custom TimeInterval
                DisplayFrequency(.immediate)

                /// A location for persisting your application's tips and associated data.
                DatastoreLocation(.applicationDefault)
            }

            Tips.showAllTips()
//            Tips.hideAllTips()
//            Tips.showTips([FavoriteBackyardTip.self])
//            Tips.hideTips([FavoriteBackyardTip.self])
        }
}

struct User {
    // Define the user interaction you want to use for a display rule.
    @Parameter
    static var isLoggedIn: Bool = false
}

struct FavoriteBackyardTip: Tip {

    var title: Text {
        Text("Save as a Favorite")
    }

    var message: Text? {
        Text("Your favorite backyards always appear at the top of the list.")
    }

    var options: [TipOption] {
        [
            // Controls whether a tip obeys the preconfigured frequency control interval.
            IgnoresDisplayFrequency(true),

            // Specifies the maximum number of times a tip displays before the system automatically invalidates it.
            MaxDisplayCount(1)
        ]
    }

    var actions: [Action] {
        [
            Tip.Action(
                id: "learn-more",
                title: "Learn More"
            ),
            Tip.Action(
                id: "other",
                title: "Other"
            )
        ]
    }

    var rules: [Rule] {
        // User is logged in
        #Rule(User.$isLoggedIn) { $0 == true }

        // Tip will only display when the simpleEvent event has been donated 3 or more times in the last week.
        #Rule(simpleEvent) {
            $0.donations.donatedWithin(.week).count >= 3
        }

        // Tip will only display when the complexEvent has been donated 3 or more times for names not equal "Timmy".
        #Rule(complexEvent) {
            $0.donations.filter({ $0.name != "Timmy" }).count > 3
        }
    }
}

let simpleEvent = Tips.Event(id: "simpleEvent")

struct EventData: Codable, Sendable {
    let id: Int
    let name: String
}

let complexEvent = Tips.Event<EventData>(id: "complexEvent")
