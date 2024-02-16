import SwiftUI

/// A slider that expands on selection.
public struct JunoSlider: View {
    @Binding var sliderValue: CGFloat
    let maxSliderValue: CGFloat
    let baseHeight: CGFloat
    let expandedHeight: CGFloat
    let label: String
    let editingChanged: ((Bool) -> Void)?
    
    @State private var isGestureActive: Bool = false
    @State private var startingSliderValue: CGFloat?
    @State private var sliderWidth = 10.0 // Just an initial value to prevent division by 0
    @State private var isAtTrackExtremity = false
    
    /// Create a slider that expands on selection.
    /// - Parameters:
    ///   - sliderValue: Binding for the current value of the slider
    ///   - maxSliderValue: The highest value the slider can be
    ///   - baseHeight: The slider's height when not expanded
    ///   - expandedHeight: The slider's height when selected (thus expanded)
    ///   - label: A string to describe what the data the slider represents
    ///   - editingChanged: An optional block that is called when the slider updates to sliding and when it stops
    public init(sliderValue: Binding<CGFloat>, maxSliderValue: CGFloat, baseHeight: CGFloat = 9.0, expandedHeight: CGFloat = 20.0, label: String, editingChanged: ((Bool) -> Void)? = nil) {
        self._sliderValue = sliderValue
        self.maxSliderValue = maxSliderValue
        self.baseHeight = baseHeight
        self.expandedHeight = expandedHeight
        self.label = label
        self.editingChanged = editingChanged
    }
    
    public var body: some View {
        ZStack {
            // visionOS (on device) does not like when drag targets are smaller than 40pt tall, so add an almost-transparent (as it still needs to be interactive) that enforces an effective minimum height. If the slider is tall than this on its own it's essentially just ignored.
            Color.orange.opacity(0.0001)
                .frame(height: 40.0)
            
            Capsule()
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                sliderWidth = proxy.size.width
                            }
                    }
                }
                .frame(height: isGestureActive ? expandedHeight : baseHeight)
                .foregroundStyle(
                    Color(white: 0.1, opacity: 0.5)
                        .shadow(.inner(color: .black.opacity(0.3), radius: 3.0, y: 2.0))
                )
                .shadow(color: .white.opacity(0.2), radius: 1, y: 1)
                .overlay(alignment: .leading) {
                    Capsule()
                        .overlay(alignment: .trailing) {
                            Circle()
                                .foregroundStyle(Color.white)
                                .shadow(radius: 1.0)
                                .padding(innerCirclePadding)
                                .opacity(isGestureActive ? 1.0 : 0.0)
                        }
                        .foregroundStyle(Color(white: isGestureActive ? 0.85 : 1.0))
                        .frame(width: calculateProgressWidth(), height: isGestureActive ? expandedHeight : baseHeight)
                }
                .clipShape(.capsule) // Best attempt at fixing a bug https://twitter.com/ChristianSelig/status/1757139789457829902
                .contentShape(.hoverEffect, .capsule)
        }
        .gesture(DragGesture(minimumDistance: 0.0)
            .onChanged { value in
                if startingSliderValue == nil {
                    startingSliderValue = sliderValue
                    isGestureActive = true
                    editingChanged?(true)
                }
                
                let percentagePointsIncreased = value.translation.width / sliderWidth
                let initialPercentage = (startingSliderValue ?? sliderValue) / maxSliderValue
                let newPercentage = min(1.0, max(0.0, initialPercentage + percentagePointsIncreased))
                sliderValue = newPercentage * maxSliderValue
                
                if newPercentage == 0.0 && !isAtTrackExtremity {
                    isAtTrackExtremity = true
                } else if newPercentage == 1.0 && !isAtTrackExtremity {
                    isAtTrackExtremity = true
                } else if newPercentage > 0.0 && newPercentage < 1.0 {
                    isAtTrackExtremity = false
                }
            }
            .onEnded { value in
                // Check if they just tapped somewhere on the bar rather than actually dragging, in which case update the progress to the position they tapped
                if value.translation.width == 0.0 {
                    let newPercentage = value.location.x / sliderWidth
                    
                    withAnimation {
                        sliderValue = newPercentage * maxSliderValue
                    }
                }
                
                startingSliderValue = nil
                isGestureActive = false
                editingChanged?(false)
            }
        )
        .hoverEffect(.highlight)
        .animation(.default, value: isGestureActive)
        .accessibilityRepresentation {
            Slider(value: $sliderValue, in: 0.0 ... maxSliderValue, label: {
                Text(label)
            }, onEditingChanged: { editingChanged in
                self.editingChanged?(editingChanged)
            })
        }
    }
    
    private var innerCirclePadding: CGFloat { expandedHeight * 0.15 }
    
    private func calculateProgressWidth() -> CGFloat {
        let minimumWidth = isGestureActive ? expandedHeight : baseHeight
        let calculatedWidth = (sliderValue / maxSliderValue) * sliderWidth
        
        // Don't let the bar get so small that it disappears
        return max(minimumWidth, calculatedWidth)
    }
}

