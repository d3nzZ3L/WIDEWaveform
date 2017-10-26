//
//  AudioWaveformView.swift
//  WIDE
//
//  Created by Denis Borodavchenko on 25/10/2017.
//  Copyright © 2016 Telegram. All rights reserved.
//

import UIKit

fileprivate class AudioWaveformContainerView : UIView {
	var color: UIColor! = UIColor.blue {
		didSet {
			self.setNeedsLayout()
		}
	}
	var _waveform: AudioWaveform? {
		didSet {
			self.setNeedsLayout()
		}
	}
	var peakHeight:CGFloat = 12
	
	required override init(frame frameRect: CGRect) {
		super.init(frame: frameRect)
		self.contentMode = UIViewContentMode.redraw
		self.isOpaque = false
		self.backgroundColor = UIColor.clear
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func draw(_ rect: CGRect) {
		let sampleWidth:CGFloat = 2
		let halfSampleWidth:CGFloat = 1
		let distance:CGFloat = 1
		let size = bounds.size
		
		let context = UIGraphicsGetCurrentContext()
		context?.setFillColor(color.cgColor)
		
		if let waveform = _waveform {
			waveform.samples.withUnsafeBytes({ (samples: UnsafePointer<UInt16>) -> Void in
				let maxReadSamples = waveform.samples.count/2
				var maxSample: UInt16 = 0
				for i in 0..<maxReadSamples {
					let sample = samples[i]
					if maxSample < sample {
						maxSample = sample
					}
				}
				
				var scale = 1.0 / max(1.0, CGFloat(maxSample))
				let numSamples = Int(floor(size.width/(sampleWidth + distance)))
				
				let adjustedSamplesMemory = malloc(numSamples*2)!
				let adjustedSamples = adjustedSamplesMemory.assumingMemoryBound(to: UInt16.self)
				defer {
					free(adjustedSamplesMemory)
				}
				memset(adjustedSamplesMemory, 0, numSamples*2)
				
				for i in 0..<maxReadSamples {
					let index = i * numSamples / maxReadSamples
					let sample = samples[i]
					if adjustedSamples[index] < sample {
						adjustedSamples[index] = sample
					}
				}
				
				for i in 0..<numSamples {
					let offset = CGFloat(i) * (sampleWidth + distance)
					let peakSample = adjustedSamples[i]
					
					var sampleHeight = CGFloat(peakSample) * peakHeight * scale
					
					if abs(sampleHeight) > peakHeight {
						sampleHeight = peakHeight
					}
					
					let adjustedSampleHeight = sampleHeight - sampleWidth
					if (adjustedSampleHeight.isLessThanOrEqualTo(sampleWidth)) {
						context?.fillEllipse(in: CGRect(x: offset, y: size.height/2 + sampleWidth, width: sampleWidth, height: sampleWidth))
						context?.fill(CGRect(x: offset, y: size.height/2 + halfSampleWidth, width: sampleWidth, height: halfSampleWidth))
					} else {
						let adjustedRect = CGRect(x: offset, y: size.height/2 - adjustedSampleHeight + sampleWidth, width: sampleWidth, height: adjustedSampleHeight)
						let adjustedRectTwo = CGRect(x: offset, y: size.height/2 - sampleHeight + halfSampleWidth, width: sampleWidth, height: adjustedSampleHeight)
						context?.fill(adjustedRect)
						context?.fill(adjustedRectTwo)
						context?.fillEllipse(in: CGRect(x: adjustedRect.minX, y: adjustedRect.minY - halfSampleWidth, width: sampleWidth, height: sampleWidth))
						context?.fillEllipse(in: CGRect(x: adjustedRect.minX, y: adjustedRect.maxY - halfSampleWidth, width: sampleWidth, height: sampleHeight))
						context?.fillEllipse(in: CGRect(x: adjustedRectTwo.minX, y: adjustedRectTwo.minY - halfSampleWidth, width: sampleWidth, height: sampleWidth))
						context?.fillEllipse(in: CGRect(x: adjustedRectTwo.minX, y: adjustedRectTwo.maxY - halfSampleWidth, width: sampleWidth, height: sampleHeight))
						
					}
					
				}
			})
			
		}
		
	}
}

public class AudioWaveformView: UIView {
    private var foregroundView = AudioWaveformContainerView()
    private var backgroundView = AudioWaveformContainerView()
    var foregroundClipingView: UIView!
	var peakHeight:CGFloat = 12 {
		didSet {
			foregroundView.peakHeight = peakHeight
			backgroundView.peakHeight = peakHeight
		}
	}
	
	public var waveform:AudioWaveform? {
		didSet {
			foregroundView._waveform = waveform
			backgroundView._waveform = waveform
		}
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		foregroundView = AudioWaveformContainerView(frame: self.bounds)
		backgroundView = AudioWaveformContainerView(frame: self.bounds)
		foregroundClipingView = UIView(frame: self.bounds)
		foregroundClipingView.backgroundColor = .clear
		addSubview(backgroundView)
		foregroundClipingView.clipsToBounds = true;
		foregroundClipingView.addSubview(foregroundView)
		addSubview(foregroundClipingView)
		peakHeight = 12.0
		foregroundView.peakHeight = peakHeight
		backgroundView.peakHeight = peakHeight
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	public func setPeakHeight(peakHeight: CGFloat) {
		self.peakHeight = peakHeight
		self.foregroundView.peakHeight = peakHeight
		self.backgroundView.peakHeight = peakHeight
	}
	
   public func set(foregroundColor: UIColor, backgroundColor: UIColor) {
        self.foregroundView.color = foregroundColor
        self.backgroundView.color = backgroundColor
    }
	
	override public func layoutSubviews() {
		super.layoutSubviews()
	}
}

