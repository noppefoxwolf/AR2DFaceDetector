# AR2DFaceDetector

## Usage

```swift
func session(_ session: ARSession, didUpdate frame: ARFrame) {
  let detector = AR2DFaceDetector(frame: frame, orientation: .right)
  let size = detector.capturedImage.extent.size
  detector.faces.first?.landmarks.faceContour?.normalizedPoints
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

AR2DFaceDetector is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AR2DFaceDetector'
```

## Author

noppefoxwolf, noppelabs@gmail.com

## License

AR2DFaceDetector is available under the MIT license. See the LICENSE file for more info.
