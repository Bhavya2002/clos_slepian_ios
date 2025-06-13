//
//  InputView.swift
//  switches_FYP
//
//  Created by Bhavya Bhatia on 03/02/2025.
//

import SwiftUI

struct InputView: View {
    @State private var networkSize: String = ""
    @State private var inputsPerSwitch: String = ""
    @State private var inputSwitchCount: String = ""
    @State private var stageCount: Double = 3
    @State private var switchType: String = "Clos"

    let switchTypes = ["Clos", "Slepian"]

    var body: some View {
        VStack(spacing: 16) {
            Text("Configure Your Network")
                .font(.headline)

            Group {
                TextField("Total Inputs/Outputs (N)", text: $networkSize)
                TextField("Inputs per Switch (n)", text: $inputsPerSwitch)
                TextField("Number of Input Switches (m or r)", text: $inputSwitchCount)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.numberPad)
            .onChange(of: networkSize) { _ in deriveMissing() }
            .onChange(of: inputsPerSwitch) { _ in deriveMissing() }
            .onChange(of: inputSwitchCount) { _ in deriveMissing() }

            Picker("Switch Type", selection: $switchType) {
                ForEach(switchTypes, id: \.self) { Text($0) }
            }
            .pickerStyle(SegmentedPickerStyle())

            VStack {
                Text("Stage Count: \(Int(stageCount))")
                Slider(value: $stageCount, in: 3...9, step: 2)
            }

            NavigationLink {
                VisualizationView(
                    networkSize: networkSize,
                    inputsPerSwitch: inputsPerSwitch,
                    inputSwitchCount: inputSwitchCount,
                    switchType: switchType,
                    stages: Int(stageCount)
                )
            } label: {
                Text("Generate Topology")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }

    // Derive the third of N, n, m/r when any two are set
    private func deriveMissing() {
        let N = Int(networkSize)
        let n = Int(inputsPerSwitch)
        let m = Int(inputSwitchCount)

        if let Nval = N, let nval = n, m == nil {
            let mCalc = Int(ceil(Double(Nval) / Double(nval)))
            let newN = nval * mCalc
            networkSize = "\(newN)"
            inputSwitchCount = "\(mCalc)"
        }
        else if let Nval = N, let mval = m, n == nil {
            let nCalc = Int(ceil(Double(Nval) / Double(mval)))
            let newN = nCalc * mval
            networkSize = "\(newN)"
            inputsPerSwitch = "\(nCalc)"
        }
        else if let nval = n, let mval = m, N == nil {
            networkSize = "\(nval * mval)"
        }
    }
}
