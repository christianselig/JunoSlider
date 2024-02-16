# JunoSlider

![Two JunoSliders vertically stacked, the first narrower than the second, being slid and updating corresponding Text views](slider.gif)

JunoSlider is a custom slider for visionOS (probably works with iOS fine, though!) to mimic the style of Apple's expanding sliders in views like `AVPlayer` in instances where you're unable to use `AVPlayer`.

It's built in SwiftUI and customizable, with both the collapsed and expanded height being values you can change. 

Apple's built-in `Slider` control may be a better fit for a lot of cases especially those where you don't require the expansion effect. The built-in `Slider` *can* animate its `controlSize` property, but the animation is a little weird on visionOS. Also, the height is not super customizable, even `.mini` with `Slider` does not allow you to get as narrow as Apple's `AVPlayer` slider, for instance.

Big thanks to Matthew Skiles and Ed Sanchez for helping me with the inner and drop shadows on the control. Also thank you to kind Twitter and Mastodon folks for helping me [debug an animation issue with this control](https://mastodon.social/@christianselig/111920403265826138), it *seems* like a SwiftUI bug and the idea of just cropping out the animation jump seemed to be the best tradeoff. 

## Example Usage

```swift
import JunoUI

struct ContentView: View {
    @State var sliderValue: CGFloat = 0.5
    @State var isSliderActive = false
    
    var body: some View {
        JunoSlider(sliderValue: $sliderValue, maxSliderValue: 1.0, baseHeight: 10.0, expandedHeight: 22.0, label: "Video volume") { editingChanged in
            isSliderActive = editingChanged
        }
    }
}
```
