//
//  HomePageView.swift
//  GreenThumbTracker
//
//  Created by Toby Buckmaster on 3/20/25.
//

import SwiftUI

struct HomePageView: View {
    var body: some View {
        NavigationStack{
            VStack{
                Text("Welcome to the Green Thumb Tracker!")
                
                NavigationLink("Enter a Water Record",destination: DashboardView())
            }
        }
    }
}

#Preview {
    HomePageView()
}
