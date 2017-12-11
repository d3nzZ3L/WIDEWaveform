# waveform
Audio waveform for files
# Pod
 pod 'WIDEWaveform', :git => "https://github.com/d3nzZ3L/WIDEWaveform.git"
# Usage
# Creating
```swift
let wave = AudioWaveformView(frame: CGRect(x: 60, y: 147, width: 191, height: 28))
wave.waveform = AudioWaveform(bitstream: bits, bitsPerSample: 128)
view.addSubview(wave)
```
Where bits - Data of audio file

# Changing colors
```swift
wave.foregroundClipingView.backgroundColor = UIColor(red: 0.0, green: 60.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
wave.set(foregroundColor: .white, backgroundColor: UIColor.blue.withAlphaComponent(0.5))
```
foregroundColor - color of waveform
