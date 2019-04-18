//
//  Watchdog.swift
//  AppsConf
//
//  Created by k.mordan on 15/04/2019.
//  Copyright © 2019 k.mordan. All rights reserved.
//

import Foundation

class Watchdog {
	var timer: Timer?
	
	var logger: Logger!

	func start() {
		timer = Timer(timeInterval: 1.0, repeats: true, block: { (timer) in
			self.woof()
		})
	}
	
	func woof() {
		if isTummyViewInCorrectPosition() == false {
			logTummyViewPosition()
			
			generateCrash()
			
			fixTummyPosition()
		}
	}
	
	func isTummyViewInCorrectPosition() -> Bool {
		return true
	}
	
	func logTummyViewPosition() {
		logger.debug("tummyView fucked up")
		sendStatistic()	
	}
	
	func sendStatistic() {
		
	}
	
	func fixTummyPosition() {
		
	}
	
	func needGenerateTestCrash() -> Bool {
		return false
	}
	
	func generateCrash() {
		
	}
}
