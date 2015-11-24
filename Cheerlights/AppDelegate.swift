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
		menu.addItem(CLMenuItem(title: "Change Color", keyEquivalent: "", action: { () -> () in
			let url = NSURL(string: "https://twitter.com/intent/tweet?text=@cheerlights%20")
			NSWorkspace.sharedWorkspace().openURL(url!)
			
			// Let's update early if the user has just submitted a color to make them happy :)
			NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: "update", userInfo: nil, repeats: false)
		}))
		menu.addItem(NSMenuItem(title: "Quit", action: "terminate:", keyEquivalent: ""))
		
		update()
		NSTimer.scheduledTimerWithTimeInterval(kUpdateTime, target: self, selector: "update", userInfo: nil, repeats: true)
	}
	
	func update() {
		NSLog("Updating Cheerlights Color")
		updateColor { [unowned self] (color) -> Void in
			self.statusItem.image = NSImage.swatchWithColor(color, size: NSSize(width: kIconSize, height: kIconSize))
		}
	}
	
	func updateColor(completion: (color: NSColor) -> Void) {
		let session = NSURLSession.sharedSession()
		
		let url = NSURL(string: "http://api.thingspeak.com/channels/1417/field/2/last.txt")
		let request = NSMutableURLRequest(URL: url!)
		request.HTTPMethod = "GET"
		
		let task = session.dataTaskWithURL(url!) { (data, res, err) -> Void in
			guard let data = data else { return }
			let hexString = NSString(data: data, encoding: NSUTF8StringEncoding)
			if let color = NSColor(hexString: hexString as! String) {
				completion(color: color)
			}
		}

		task.resume()
	}
}
