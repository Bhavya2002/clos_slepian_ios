//
//  VisualizationView.swift
//  switches_FYP
//
//  Created by Bhavya Bhatia on 03/02/2025.
//


import SwiftUI

struct VisualizationView: View {
    var networkSize: String
    var inputsPerSwitch: String
    var inputSwitchCount: String
    var switchType: String
    var stages: Int

    var body: some View {
        VStack {
            // Parse any or all inputs as Int
            let N = Int(networkSize)
            let n = Int(inputsPerSwitch)
            let m = Int(inputSwitchCount)

            if switchType == "Clos" {
                if let model = computeClosTopology(NInput: N, nInput: n, mInput: m, stageCount: stages) {
                    NavigationStack {
                        ClosSwitchView(model: model)
                            .navigationTitle("Clos \(stages)‑Stage")
                    }
                } else {
                    Text("Invalid parameters for Clos network.")
                }

            } else { // Slepian
                if let model = computeSlepianTopology(NInput: N, nInput: n, rInput: m, stageCount: stages) {
                    NavigationStack {
                        SlepianSwitchView(model: model)
                            .navigationTitle("Slepian \(stages)‑Stage")
                    }
                } else {
                    Text("Invalid parameters for Slepian network.")
                }
            }
        }
        .padding()
    }
}
