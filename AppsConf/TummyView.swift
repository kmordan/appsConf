//
//  TummyView.swift
//  AppsConf
//
//  Created by k.mordan on 05/04/2019.
//  Copyright © 2019 k.mordan. All rights reserved.
//

import UIKit

class TummyView: UIView {
	
	@IBOutlet weak var textField: UITextField!
	
	override func resignFirstResponder() -> Bool {
		super.resignFirstResponder()
		return textField.resignFirstResponder()
	}
}
