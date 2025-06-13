//
//  Calculator.swift
//  switches_FYP
//
//  Created by Bhavya Bhatia on 18/02/2025.
//

import Foundation

// MARK: — baseClosCalculation
/// Optimal 3‑stage Clos parameters for a given N:
///   • m = round(√(N/2)), then adjust so m·n ≥ N
///   • n = ceil(N/m)
///   • crosspoints = 2·m·n·(2n−1) + (2n−1)·m²
func baseClosCalculation(for N: Int) -> (m: Int, n: Int, crosspoints: Double) {
    let mEstimate = sqrt(Double(N) / 2.0)
    var m = max(1, Int(round(mEstimate)))
    var n = Int(ceil(Double(N) / Double(m)))
    while m * n < N {
        n += 1
    }
    let mid = 2 * n - 1
    let cp = 2.0 * Double(m) * Double(n) * Double(mid)
           + Double(mid) * Double(m * m)
    return (m, n, cp)
}

// MARK: –– Clos

func computeClosTopology(
    NInput: Int?,
    nInput: Int?,
    mInput: Int?,
    stageCount k: Int
) -> ClosSwitchModel? {
    // Must have N, odd k ≥ 3
    guard let rawN = NInput, k >= 3, k % 2 == 1 else { return nil }

    // If both n,m missing => use baseClosCalculation
    let (m0, n0, cp0): (Int, Int, Double)
    if nInput == nil && mInput == nil {
        (m0, n0, cp0) = baseClosCalculation(for: rawN)
    } else {
        // Otherwise derive missing of n/m if needed
        var N = rawN, n = nInput, m = mInput
        let provided = [n, m].compactMap{ $0 }.count
        if provided == 1 {
            if let nval = n {
                let mCalc = Int(ceil(Double(N) / Double(nval)))
                m = max(1, mCalc)
                N = nval * m!
            } else if let mval = m {
                let nCalc = Int(ceil(Double(N) / Double(mval)))
                n = max(1, nCalc)
                N = n! * mval
            }
        }
        guard let nn = n, let mm = m, N == nn * mm else { return nil }
        let mid = 2 * nn - 1
        let cp = 2.0 * Double(mm) * Double(nn) * Double(mid)
               + Double(mid) * Double(mm * mm)
        (m0, n0, cp0) = (mm, nn, cp)
    }

    // Now build the model
    let midCount = 2 * n0 - 1
    var totalCP = cp0
    var nested: ClosSwitchModel? = nil

    if k > 3 {
        // recurse on the “middle” size = m0
        nested = computeClosTopology(
            NInput: m0,
            nInput: nil,
            mInput: nil,
            stageCount: k - 2
        )
        totalCP = 2.0 * Double(m0) * Double(n0) * Double(midCount)
                + Double(midCount) * (nested?.crosspoints ?? 0)
    }

    return ClosSwitchModel(
        networkSize: rawN,
        stages: k,
        inputPorts: m0,
        outputPorts: m0,
        middleStageSwitches: midCount,
        crosspoints: totalCP,
        nestedTopology: nested
    )
}

// MARK: –– Slepian

func computeSlepianTopology(
    NInput: Int?,
    nInput: Int?,
    rInput: Int?,
    stageCount k: Int
) -> SlepianSwitchModel? {
    guard let rawN = NInput, k >= 3 else { return nil }

    let (r0, n0, cp0): (Int, Int, Double)
    if nInput == nil && rInput == nil {
        // base Slepian: n≈√(N/2), r=ceil(N/n)
        let nEst = Int(round(sqrt(Double(rawN)/2.0)))
        var nCalc = max(1, nEst)
        var rCalc = Int(ceil(Double(rawN) / Double(nCalc)))
        while nCalc * rCalc < rawN { rCalc += 1 }
        let cpBase = 2 * sqrt(2) * pow(Double(rawN), 1.5)
        (r0, n0, cp0) = (rCalc, nCalc, cpBase)
    } else {
        // derive missing n/r if only one provided
        var N = rawN, n = nInput, r = rInput
        let provided = [n, r].compactMap{ $0 }.count
        if provided == 1 {
            if let nval = n {
                let rCalc = Int(ceil(Double(N)/Double(nval)))
                r = max(1, rCalc)
                N = nval * r!
            } else if let rval = r {
                let nCalc = Int(ceil(Double(N)/Double(rval)))
                n = max(1, nCalc)
                N = n! * rval
            }
        }
        guard let nn = n, let rr = r, N == nn * rr else { return nil }
        let cp = Double(rawN)*(2.0*Double(nn)+Double(rr))
        (r0, n0, cp0) = (rr, nn, cp)
    }

    var totalCP = cp0
    var nested: SlepianSwitchModel? = nil

    if k > 3 {
        nested = computeSlepianTopology(
            NInput: rawN,
            nInput: nil,
            rInput: nil,
            stageCount: k - 2
        )
        totalCP = pow(Double(r0), 2) * pow(Double(n0), Double(k))
    }

    return SlepianSwitchModel(
        networkSize: rawN,
        stages: k,
        inputPorts: r0,
        outputPorts: r0,
        middleStageSwitches: n0,
        crosspoints: totalCP,
        nestedTopology: nested
    )
}
