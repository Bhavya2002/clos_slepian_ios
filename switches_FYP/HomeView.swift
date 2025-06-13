//
//  HomeView.swift
//  switches_FYP
//
//  Created by Bhavya Bhatia on 03/02/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Network Topology Designer")
                    .font(.title)
                    .bold()
                
                NavigationLink(destination: InputView()) {
                    Text("New Topology")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: HelpView()) {
                    Text("Help / Guide")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

