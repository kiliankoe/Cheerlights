//
//  AppDelegate.swift
//  Cheerlights
//
//  Created by Kilian Költzsch on 24/11/15.
//  Copyright © 2015 Kilian Költzsch. All rights reserved.
//

import Cocoa

// Size of the circle in the menubar
let kIconSize = 9

// How often to update in seconds
let kUpdateTime = 300.0

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var menu: NSMenu!
	let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		statusItem.menu = menu
		
		menu.addItem(NSMenuItem(title: "Change Color", action: "openTwitter", keyEquivalent: ""))
		menu.addItem(NSMenuItem(title: "Update Now", action: "update", keyEquivalent: ""))
		menu.addItem(NSMenuItem(title: "Quit", action: "terminate:", keyEquivalent: ""))
		
		update()
		NSTimer.scheduledTimerWithTimeInterval(kUpdateTime, target: self, selector: "update", userInfo: nil, repeats: true)
	}
	
	/**
	Open a new tweet to @cheerlights for the user to submit so that the global color can be changed.
	*/
	func openTwitter() {
		let url = NSURL(string: "https://twitter.com/intent/tweet?text=@cheerlights%20")
		NSWorkspace.sharedWorkspace().openURL(url!)
		
		// Let's update early if the user has just submitted a color to make them happy :)
		NSTimer.scheduledTimerWithTimeInterval(20.0, target: self, selector: "update", userInfo: nil, repeats: false)
	}
	
	/**
	Update by sending an update request and change the statusItem image.
	*/
	func update() {
		NSLog("Updating Cheerlights color...")
		sendUpdateRequest { [unowned self] (color) -> Void in
			self.statusItem.image = NSImage.swatchWithColor(color, size: NSSize(width: kIconSize, height: kIconSize))
		}
	}
	
	/**
	Send a request to Cheerlights and hand the color over as an NSColor to the completion block
	
	- parameter completion: handler
	*/
	func sendUpdateRequest(completion: (color: NSColor) -> Void) {
		let session = NSURLSession.sharedSession()
		
		let url = NSURL(string: "http://api.thingspeak.com/channels/1417/field/2/last.txt")
		
		let task = session.dataTaskWithURL(url!) { (data, res, err) -> Void in
			guard err == nil else {	NSLog("Got an error fetching data from Cheerlights. \(err!.localizedDescription)"); return }
			guard let data = data else { NSLog("No valid data received from Cheerlights."); return }
			
			let hexString = NSString(data: data, encoding: NSUTF8StringEncoding)
			if let color = NSColor(hexString: hexString as! String) {
				completion(color: color)
			} else {
				NSLog("Failed to convert hexString '\(hexString)' into valid color.")
			}
		}

		task.resume()
	}
}
