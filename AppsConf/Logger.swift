//
//  Logger.swift
//  AppsConf
//
//  Created by k.mordan on 09/04/2019.
//  Copyright © 2019 k.mordan. All rights reserved.
//

import Foundation

class Logger {
	let tag: String
	
	init(withTag tag: String) {
		self.tag = tag
	}
	
	func dequeue(withTag tag: String) -> Logger {
		return self
	}
	
	func debug(_ format: String) {
		
	}
}
