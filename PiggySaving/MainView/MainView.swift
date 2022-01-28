//
//  MainView.swift
//  PiggySaving
//
//  Created by Tianyu Liu on 27/01/2022.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var configs: ConfigStore = ConfigStore()
    
    var body: some View {
        TabView {
            SavingsView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Savings")
                }
            
            SavingsListView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Savings List")
                }
            
            OverviewView()
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("Overview")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}