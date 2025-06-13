//
//  SwitchModels.swift
//  switches_FYP
//
//  Created by Bhavya Bhatia on 18/02/2025.
//

import Foundation
import SwiftUI

// MARK: - Switch Model Definitions

class ClosSwitchModel {
    var networkSize: Int           // Total network size (N)
    var stages: Int                // Number of stages (must be odd: 3, 5, 7, …)
    var inputPorts: Int            // Computed optimal value for n (input ports per switch)
    var outputPorts: Int           // Computed optimal value for m (output ports per switch)
    var middleStageSwitches: Int   // For simplicity, we use m as the number for the middle stage
    var crosspoints: Double        // Total number of crosspoints (computed)
    var nestedTopology: ClosSwitchModel?  // Inner recursive topology if stages > 3
    
    init(networkSize: Int, stages: Int, inputPorts: Int, outputPorts: Int, middleStageSwitches: Int, crosspoints: Double, nestedTopology: ClosSwitchModel? = nil) {
        self.networkSize = networkSize
        self.stages = stages
        self.inputPorts = inputPorts
        self.outputPorts = outputPorts
        self.middleStageSwitches = middleStageSwitches
        self.crosspoints = crosspoints
        self.nestedTopology = nestedTopology
    }
}

class SlepianSwitchModel {
    var networkSize: Int           // Total network size (N)
    var stages: Int                // Typically 3 (or more for recursive networks)
    var inputPorts: Int            // Computed optimal value for n
    var outputPorts: Int           // For Slepian, assume input = output (n)
    var middleStageSwitches: Int   // Computed optimal value for r (and used as switch dimension)
    var crosspoints: Double        // Total number of crosspoints (computed)
    var nestedTopology: SlepianSwitchModel?  // Inner network when recursive
    
    init(networkSize: Int, stages: Int, inputPorts: Int, outputPorts: Int, middleStageSwitches: Int, crosspoints: Double, nestedTopology: SlepianSwitchModel? = nil) {
        self.networkSize = networkSize
        self.stages = stages
        self.inputPorts = inputPorts
        self.outputPorts = outputPorts
        self.middleStageSwitches = middleStageSwitches
        self.crosspoints = crosspoints
        self.nestedTopology = nestedTopology
    }
}
