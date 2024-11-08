//
//  ContentView.swift
//  Thrive
//
//  Created by Sean Lin on 08/11/2024
//  Copyright © 2024 Haol. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
               .tabItem {
                    VStack {
                        Image(systemName: "house")
                        Text("Home")
                           .font(.caption)
                    }
                }

            AskView()
               .tabItem {
                    VStack {
                        Image(systemName: "message")
                        Text("Ask")
                           .font(.caption)
                    }
                }

            CommunityView()
               .tabItem {
                    VStack {
                        Image(systemName: "person.2.wave.2.fill")
                        Text("Community")
                           .font(.caption)
                    }
                }
            
            LeaderboardView()
               .tabItem {
                    VStack {
                        Image(systemName: "flag")
                        Text("Leaderboard")
                           .font(.caption)
                    }
                }
            
            SettingsView()
               .tabItem {
                    VStack {
                        Image(systemName: "gearshape")
                        Text("Settings")
                           .font(.caption)
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
