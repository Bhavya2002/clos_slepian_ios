//
//  SlepianSwitchView.swift
//  switches_FYP
//
//  Created by Bhavya Bhatia on 18/02/2025.
//


import SwiftUI

struct SlepianSwitchView: View {
    var model: SlepianSwitchModel
    @State private var highlightedElement: (type: String, index: Int)? = nil
    @State private var showAlert = false
    @State private var selectedAction = ""
    @State private var showNestedTopology = false

    // --- State for zoom and pan ---
    @State private var steadyStateScale: CGFloat = 1.0
    @State private var steadyStateOffset: CGSize = .zero

    // --- Gesture state ---
    @GestureState private var gestureMagnificationScale: CGFloat = 1.0
    @GestureState private var gestureDragOffset: CGSize = .zero

    // --- Minimum Scale Factor ---
    private let minScale: CGFloat = 0.2

    // --- Model parameters ---
    private var r: Int { model.inputPorts } // Input/output switches
    private var n: Int { model.middleStageSwitches } // Middle switches

    // --- Calculated content size ---
    private var contentWidth: CGFloat { CGFloat(max(r, n)) * 60 + 200 }
    private var contentHeight: CGFloat { 3 * 100 + 100 }

    var body: some View {
        VStack {
            // Header Text
            Text("Slepian \(model.stages)-Stage Switch")
                .font(.headline)
            Text("N = \(model.networkSize), n = \(n), r = \(r)")
            Text("Crosspoints: \(model.crosspoints, specifier: "%.2f")")

            // Scrollable Content Area
            ScrollView([.horizontal, .vertical]) {
                ZStack {
                    // Layout Constants
                    let topY: CGFloat = 80
                    let middleY: CGFloat = contentHeight / 2
                    let bottomY: CGFloat = contentHeight - 80
                    let inputSpacing = contentWidth / CGFloat(r + 1)
                    let outputSpacing = contentWidth / CGFloat(r + 1)
                    let middleSpacing = contentWidth / CGFloat(n + 1)

                    // Connections Canvas
                    Canvas { ctx, _ in
                        // Input (Top) to Middle connections
                        for i in 0..<r {
                            let startPoint = CGPoint(x: inputSpacing * CGFloat(i + 1), y: topY + 15) // Adjusted
                            for j in 0..<n {
                                let endPoint = CGPoint(x: middleSpacing * CGFloat(j + 1), y: middleY - 15) // Adjusted
                                var path = Path()
                                path.move(to: startPoint)
                                path.addLine(to: endPoint)
                                let isHighlighted = (highlightedElement?.type == "input" && highlightedElement?.index == i)
                                    || (highlightedElement?.type == "middle" && highlightedElement?.index == j)
                                ctx.stroke(path, with: .color(isHighlighted ? .red : .gray), lineWidth: isHighlighted ? 2 : 0.5)
                            }
                        }
                        // Middle to Output (Bottom) connections
                        for j in 0..<n {
                            let startPoint = CGPoint(x: middleSpacing * CGFloat(j + 1), y: middleY + 15) // Adjusted
                            for i in 0..<r {
                                let endPoint = CGPoint(x: outputSpacing * CGFloat(i + 1), y: bottomY - 15) // Adjusted
                                var path = Path()
                                path.move(to: startPoint)
                                path.addLine(to: endPoint)
                                let isHighlighted = (highlightedElement?.type == "middle" && highlightedElement?.index == j)
                                    || (highlightedElement?.type == "output" && highlightedElement?.index == i)
                                ctx.stroke(path, with: .color(isHighlighted ? .red : .gray), lineWidth: isHighlighted ? 2 : 0.5)
                            }
                        }
                    }
                    .zIndex(0)

                    // Input switches (Top Row)
                    ForEach(0..<r, id: \.self) { i in
                        let x = inputSpacing * CGFloat(i + 1)
                        SwitchNodeView( // Use the common helper view
                            label: "I\(i+1)",
                            color: .blue,
                            position: CGPoint(x: x, y: topY),
                            portCount: n, // Connects to 'n' middle switches
                            portSide: .top, // Dashes point down
                            detailsAction: {
                                selectedAction = "Input \(i+1) (Size=\(n)x\(n))"
                                showAlert = true
                            },
                            highlightAction: { highlightedElement = ("input", i) }
                        )
                        .zIndex(1)
                    }

                    // Middle switches (Middle Row)
                    ForEach(0..<n, id: \.self) { j in
                        let x = middleSpacing * CGFloat(j + 1)
                        let nestedAction: (() -> Void)? = (model.stages > 3 && model.nestedTopology != nil) ? { showNestedTopology = true } : nil

                        SwitchNodeView( // Use the common helper view
                            label: "M\(j+1)",
                            color: .green,
                            position: CGPoint(x: x, y: middleY),
                            portCount: nil, // No dashes needed for middle Slepian for now
                            portSide: nil,
                            detailsAction: {
                                selectedAction = "Middle \(j+1) (Size=\(r)x\(r))"
                                showAlert = true
                            },
                            highlightAction: { highlightedElement = ("middle", j) },
                            nestedAction: nestedAction
                        )
                        .zIndex(1)
                    }

                    // Output switches (Bottom Row)
                    ForEach(0..<r, id: \.self) { i in
                        let x = outputSpacing * CGFloat(i + 1)
                         SwitchNodeView( // Use the common helper view
                            label: "O\(i+1)",
                            color: .purple,
                            position: CGPoint(x: x, y: bottomY),
                            portCount: n, // Connects to 'n' middle switches
                            portSide: .bottom, // Dashes point up
                            detailsAction: {
                                selectedAction = "Output \(i+1) (Size=\(n)x\(n))"
                                showAlert = true
                            },
                            highlightAction: { highlightedElement = ("output", i) }
                        )
                        .zIndex(1)
                    }

                    // Navigation to nested topology
                    if let nested = model.nestedTopology {
                        NavigationLink("", destination: SlepianSwitchView(model: nested), isActive: $showNestedTopology)
                            .hidden()
                    }
                } // End ZStack
                .frame(width: contentWidth, height: contentHeight)
                // Apply combined scale and offset using state + gesture state
                .scaleEffect(steadyStateScale * gestureMagnificationScale)
                .offset(
                    x: steadyStateOffset.width + gestureDragOffset.width,
                    y: steadyStateOffset.height + gestureDragOffset.height
                )
                 // Apply Gestures
                .gesture(
                    SimultaneousGesture(
                        // Magnification Gesture
                        MagnificationGesture()
                            .updating($gestureMagnificationScale) { latestGestureScale, gestureState, _ in
                                gestureState = latestGestureScale
                            }
                            .onEnded { finalGestureScale in
                                // Clamp the final scale
                                steadyStateScale = max(minScale, steadyStateScale * finalGestureScale)
                            },

                        // Drag Gesture
                        DragGesture()
                            .updating($gestureDragOffset) { latestDragGestureValue, gestureState, _ in
                                gestureState = latestDragGestureValue.translation
                            }
                            .onEnded { finalDragGestureValue in
                                steadyStateOffset.width += finalDragGestureValue.translation.width
                                steadyStateOffset.height += finalDragGestureValue.translation.height
                            }
                    )
                )
            } // End ScrollView
            Spacer()
        }
        .padding()
        .navigationTitle("Slepian \(model.stages)‑Stage")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Switch Details"), message: Text(selectedAction), dismissButton: .default(Text("OK")))
        }
        .onDisappear {
             highlightedElement = nil
        }
    }
}
