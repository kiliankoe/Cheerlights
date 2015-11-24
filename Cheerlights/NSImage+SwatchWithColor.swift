//
//  NSImage+SwatchWithColor.swift
//  Cheerlights
//
//  Created by Kilian Költzsch on 24/11/15.
//  Copyright © 2015 Kilian Költzsch. All rights reserved.
//

import Cocoa

extension NSImage {
	static func swatchWithColor(color: NSColor, size: NSSize) -> NSImage {
		let image = NSImage(size: size)
		image.lockFocus()
		color.drawSwatchInRect(NSMakeRect(0, 0, size.width, size.height))
		image.unlockFocus()
		return roundCorners(image, width: CGFloat(kIconSize), height: CGFloat(kIconSize))
	}
}

// from http://stackoverflow.com/questions/1849636/how-to-draw-a-rounded-nsimage, thank you very much!
func roundCorners(image: NSImage, width: CGFloat = 192, height: CGFloat = 192) -> NSImage {
	let xRad = width / 2
	let yRad = height / 2
	let existing = image
	let esize = existing.size
	let newSize = NSMakeSize(esize.height, esize.width)
	let composedImage = NSImage(size: newSize)
	
	composedImage.lockFocus()
	let ctx = NSGraphicsContext.currentContext()
	ctx?.imageInterpolation = NSImageInterpolation.High
	
	let imageFrame = NSRect(x: 0, y: 0, width: width, height: height)
	let clipPath = NSBezierPath(roundedRect: imageFrame, xRadius: xRad, yRadius: yRad)
	clipPath.windingRule = NSWindingRule.EvenOddWindingRule
	clipPath.addClip()
	
	let rect = NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
	image.drawAtPoint(NSZeroPoint, fromRect: rect, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1)
	composedImage.unlockFocus()
	
	return composedImage
}
