//
//  ClosSwitchView.swift
//  switches_FYP
//
//  Created by Bhavya Bhatia on 18/02/2025.
//


import SwiftUI

struct ClosSwitchView: View {
    var model: ClosSwitchModel
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
    private var m: Int { model.inputPorts }
    private var n: Int { (model.middleStageSwitches + 1) / 2 }
    private var mid: Int { model.middleStageSwitches }

    // --- Calculated content size ---
    private var contentWidth: CGFloat { CGFloat(mid) * 60 + 300 }
    private var contentHeight: CGFloat { CGFloat(max(m, mid)) * 50 + 150 }

    var body: some View {
        VStack {
            // Header Text
            Text("Clos \(model.stages)-Stage Switch")
                .font(.headline)
            Text("N = \(model.networkSize), m = \(m), n = \(n)")
            Text("Crosspoints: \(model.crosspoints, specifier: "%.2f")")

            // Scrollable Content Area
            ScrollView([.horizontal, .vertical]) {
                ZStack {
                    // Layout Constants
                    let inputX: CGFloat = 60
                    let middleX: CGFloat = contentWidth / 2
                    let outputX: CGFloat = contentWidth - 60
                    let inputSpacing = contentHeight / CGFloat(m + 1)
                    let outputSpacing = contentHeight / CGFloat(m + 1)
                    let middleSpacing = contentHeight / CGFloat(mid + 1)

                    // Connections Canvas
                    Canvas { ctx, _ in
                         // Input to Middle connections
                        for i in 0..<m {
                            let startPoint = CGPoint(x: inputX + 15, y: inputSpacing * CGFloat(i + 1))
                            for j in 0..<mid {
                                let endPoint = CGPoint(x: middleX - 12, y: middleSpacing * CGFloat(j + 1))
                                var path = Path()
                                path.move(to: startPoint)
                                path.addLine(to: endPoint)
                                let isHighlighted = (highlightedElement?.type == "input" && highlightedElement?.index == i)
                                    || (highlightedElement?.type == "middle" && highlightedElement?.index == j)
                                ctx.stroke(path, with: .color(isHighlighted ? .red : .gray), lineWidth: isHighlighted ? 2 : 0.5)
                            }
                        }
                        // Middle to Output connections
                        for j in 0..<mid {
                            let startPoint = CGPoint(x: middleX + 12, y: middleSpacing * CGFloat(j + 1))
                            for i in 0..<m {
                                let endPoint = CGPoint(x: outputX - 15, y: outputSpacing * CGFloat(i + 1))
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

                    // Input switches
                    ForEach(0..<m, id: \.self) { i in
                        let y = inputSpacing * CGFloat(i + 1)
                        SwitchNodeView(
                            label: "I\(i+1)",
                            color: .blue,
                            position: CGPoint(x: inputX, y: y),
                            portCount: n, // Pass 'n' for input/output switches
                            portSide: .left, // Indicate ports are on the left
                            detailsAction: {
                                selectedAction = "Input \(i+1) (n=\(n))"
                                showAlert = true
                            },
                            highlightAction: { highlightedElement = ("input", i) }
                        )
                        .zIndex(1)
                    }

                    // Middle switches
                    ForEach(0..<mid, id: \.self) { j in
                        let y = middleSpacing * CGFloat(j + 1)
                        let nestedAction: (() -> Void)? = (model.stages > 3 && model.nestedTopology != nil) ? { showNestedTopology = true } : nil
                        SwitchNodeView(
                            label: "M\(j+1)",
                            color: .green,
                            position: CGPoint(x: middleX, y: y),
                            portCount: nil, // Middle switches don't need port dashes shown this way
                            portSide: nil,
                            detailsAction: {
                                selectedAction = "Middle \(j+1) (\(m)x\(m))"
                                showAlert = true
                            },
                            highlightAction: { highlightedElement = ("middle", j) },
                            nestedAction: nestedAction
                        )
                        .zIndex(1)
                    }

                    // Output switches
                    ForEach(0..<m, id: \.self) { i in
                        let y = outputSpacing * CGFloat(i + 1)
                        SwitchNodeView(
                            label: "O\(i+1)",
                            color: .purple,
                            position: CGPoint(x: outputX, y: y),
                            portCount: n, // Pass 'n' for input/output switches
                            portSide: .right, // Indicate ports are on the right
                            detailsAction: {
                                selectedAction = "Output \(i+1) (n=\(n))"
                                showAlert = true
                            },
                            highlightAction: { highlightedElement = ("output", i) }
                        )
                        .zIndex(1)
                    }

                    // Navigation Link
                    if let nested = model.nestedTopology {
                        NavigationLink("", destination: ClosSwitchView(model: nested), isActive: $showNestedTopology)
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
        .navigationTitle("Clos \(model.stages)‑Stage")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Switch Details"), message: Text(selectedAction), dismissButton: .default(Text("OK")))
        }
        .onDisappear {
             highlightedElement = nil
             // Optional: Reset zoom/pan when view disappears
             // steadyStateScale = 1.0
             // steadyStateOffset = .zero
        }
    }
}


// --- Helper View for Switch Nodes (Includes Dash Drawing) ---
struct SwitchNodeView: View {
    let label: String
    let color: Color
    let position: CGPoint
    let portCount: Int? // Number of ports (n) for dashes
    let portSide: PortSide? // Which side to draw dashes (.left, .right, .top, .bottom)
    let detailsAction: () -> Void
    let highlightAction: () -> Void
    var nestedAction: (() -> Void)? = nil

    enum PortSide { case left, right, top, bottom }

    private let switchWidth: CGFloat = 24
    private let switchHeight: CGFloat = 24
    private let dashLength: CGFloat = 10
    private let dashSpacing: CGFloat = 5 // Spacing between dashes (vertical or horizontal)

    // --- DEBUG FLAG ---
    // Set to true to see canvas bounds (yellow) and debug shapes (magenta/cyan)
    private let debugDashes = false

    var body: some View {
        ZStack {
            // Switch Body
            VStack(spacing: 0) {
                Text(label).font(.caption2).lineLimit(1)
                Rectangle()
                    .fill(color)
                    .frame(width: switchWidth, height: switchHeight)
                    .overlay(Rectangle().stroke(Color.black, lineWidth: 0.5))
            }
            .frame(width: 30) // Give VStack some width for the label

            // Port Dashes Canvas
            if let count = portCount, let side = portSide, count > 0 {
                // Calculate total dimension needed for dashes based on spacing
                let totalDashDimension: CGFloat = CGFloat(max(0, count - 1)) * dashSpacing

                Canvas { context, size in

                    // --- DASH DRAWING LOGIC ---
                    // Calculate starting offset (startY or startX) to center dashes within the canvas size
                    let startOffset: CGFloat
                    if side == .left || side == .right { // Vertical centering
                         startOffset = (size.height - totalDashDimension) / 2
                    } else { // Horizontal centering
                        startOffset = (size.width - totalDashDimension) / 2
                    }

                    // Determine the edge of the switch rectangle in the canvas's local coordinates
                    let edgeOffset: CGFloat
                    switch side {
                        case .left: edgeOffset = (size.width - switchWidth) / 2
                        case .right: edgeOffset = (size.width + switchWidth) / 2
                        case .top: edgeOffset = (size.height - switchHeight) / 2
                        case .bottom: edgeOffset = (size.height + switchHeight) / 2
                    }

                    for i in 0..<count {
                         var p = Path()
                         if side == .left || side == .right {
                             // Draw horizontal dashes vertically spaced
                             let yPos = startOffset + CGFloat(i) * dashSpacing
                             let startX = edgeOffset
                             let endX = (side == .left) ? startX - dashLength : startX + dashLength
                             p.move(to: CGPoint(x: startX, y: yPos))
                             p.addLine(to: CGPoint(x: endX, y: yPos))
                         } else { // top or bottom
                            // Draw vertical dashes horizontally spaced
                             let xPos = startOffset + CGFloat(i) * dashSpacing
                             let startY = edgeOffset
                             let endY = (side == .top) ? startY - dashLength : startY + dashLength
                             p.move(to: CGPoint(x: xPos, y: startY))
                             p.addLine(to: CGPoint(x: xPos, y: endY))
                         }
                         context.stroke(p, with: .color(.black), lineWidth: 1)
                    }
                    // --- END DASH DRAWING LOGIC ---
                }
                // Background for debugging canvas area
                .background(debugDashes ? Color.yellow.opacity(0.3) : Color.clear)
                // Set frame size for the canvas to contain dashes
                 .frame(
                     width: (side == .top || side == .bottom) ? switchWidth + totalDashDimension + dashSpacing : switchWidth + dashLength * 2,
                     height: (side == .left || side == .right) ? switchHeight + totalDashDimension + dashSpacing : switchHeight + dashLength * 2
                 )
                 // Canvas is centered within the ZStack by default, no offset needed here usually
                 .offset(x: 0, y: 0)
            } // End if let count...
        } // End ZStack
        // Position the entire node (Switch + Dashes ZStack)
        .position(position)
        // Context Menu
        .contextMenu {
            Button("View Details", action: detailsAction)
            Button("Highlight Connections", action: highlightAction)
            if let nestedAction = nestedAction {
                Button("View Nested Topology", action: nestedAction)
            }
        }
    }
}
// --- End Helper View ---
