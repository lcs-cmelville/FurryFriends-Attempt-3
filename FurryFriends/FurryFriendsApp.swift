//
//  FurryFriendsApp.swift
//  FurryFriends
//
//  Created by Russell Gordon on 2022-02-26.
//

import SwiftUI

@main
struct FurryFriendsApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                TabView{
                    
                ContentView()
                        .tabItem {
                            Image(systemName: "d.circle")
                            Text("Dogs")
                        }
                    
                CatView()
                        .tabItem{
                            Image(systemName: "c.circle")
                            Text("Cats")
                        }
                }
            }
        }
    }
}
