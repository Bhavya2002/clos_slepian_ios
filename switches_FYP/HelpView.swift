//
//  HelpView.swift
//  switches_FYP
//
//  Created by Bhavya Bhatia on 03/02/2025.
//


import SwiftUI
import AVKit // Import AVKit for video playback

struct HelpView: View {
    // State variable to control the presentation of the video tutorial sheet
    @State private var showingVideoTutorialSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Help & Guide")
                .font(.title2)
                .bold()

            // Added explanation about switches and their role
            Text("""
Network switches are fundamental devices in modern communication networks, directing data traffic between devices. In large data centers, efficient switching is crucial for high-speed data transfer, low latency, and scalability to handle massive amounts of information flow.

Clos and Slepian networks are advanced types of multi-stage switching networks designed to achieve non-blocking or rearrangeable non-blocking connectivity, minimizing the number of crosspoints needed for a given number of inputs and outputs. They are widely used in telecommunications and data centers for their efficiency and scalability.
""")
            .font(.body)
            .padding(.bottom, 8) // Add some space before the parameter explanation

            Text("""
To design a Clos or Slepian network using this app, you need to provide network parameters. These networks require only two of these three values:

 • N = total inputs/outputs
 • n = inputs per switch
 • m (or r) = number of input switch blocks

Leave one blank and it will be auto‑calculated (N ← n·m).
For a 3‑stage Clos: middle stage count = 2·n – 1, and output blocks = m.
For Slepian: N = n·r, middle stage count = r.
You can then choose 3, 5, 7… stages and visualize the result.
""")
                .font(.body)

            // Button to show the video tutorial
            Button {
                showingVideoTutorialSheet = true
            } label: {
                Label("Watch Video Tutorial", systemImage: "play.circle")
            }
            .padding(.top) // Add some spacing above the button


            Spacer()
        }
        .padding()
        // Present the video player in a sheet when showingVideoTutorialSheet is true
        .sheet(isPresented: $showingVideoTutorialSheet) {
            if let videoURL = Bundle.main.url(forResource: "FYP", withExtension: "mov") {
                 VideoPlayer(player: AVPlayer(url: videoURL))
                    .edgesIgnoringSafeArea(.all) // Make the video player take up the full screen in the sheet
            } else {
                // Handle case where URL is invalid or nil
                Text("Could not load video tutorial.")
                    .presentationDetents([.medium]) // Keep the sheet smaller if video fails
            }
        }
    }
}
