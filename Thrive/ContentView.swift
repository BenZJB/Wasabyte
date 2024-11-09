//
//  ContentView.swift
//  Thrive
//
//  Created by Sean Lin on 08/11/2024
//  Copyright © 2024 Haol. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var model = StoreViewModel()
    
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

            StoreView(viewModel: model)
               .tabItem {
                    VStack {
                        Image(systemName: "storefront.fill")
                        Text("Store")
                           .font(.caption)
                    }
                }
            
            CatView(viewModel: model, catMessage: "", size: 320)
               .tabItem {
                    VStack {
                        Image(systemName: "cat.fill")
                        Text("Cat")
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
