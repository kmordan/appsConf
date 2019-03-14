//
//  KeyboardTracker.swift
//  AppsConf
//
//  Created by k.mordan on 10/03/2019.
//  Copyright © 2019 k.mordan. All rights reserved.
//

import UIKit

struct KeyboardTransitionAnimation {
	let duration: Double
	let curve: UIView.AnimationCurve
}

protocol KeyboardTrackerDelegare: class {
	func keyboardWillChange(_ height: CGFloat, with animation:KeyboardTransitionAnimation)
}

class KeyboardTracker {
	private weak var delegate: KeyboardTrackerDelegare?
	
	init(with delegate: KeyboardTrackerDelegare?) {
		self.delegate = delegate
	}
	
	func enable() {
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self,
									   selector: #selector(keyboardWillChangeFrame),
									   name:UIResponder.keyboardWillChangeFrameNotification,
									   object: nil)
		notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	func disable() {
		let notificationCenter = NotificationCenter.default
		let notificationNames = [UIResponder.keyboardWillChangeFrameNotification, UIResponder.keyboardWillShowNotification, UIResponder.keyboardWillHideNotification]
		
		for name in notificationNames {
			notificationCenter.removeObserver(self, name:name, object: nil)
		}
	}
}

extension KeyboardTracker {
	
	@objc func keyboardWillShow(notification: NSNotification) {
		print(notification)
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		print(notification)
	}
	
	@objc func keyboardWillChangeFrame(notification: NSNotification) {
		//		print(notification)
		
		guard let userInfo = notification.userInfo else {
			return
		}
		
		guard let window = UIApplication.shared.windows.first else {
			return
		}
		
		let screenCoordinatedKeyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
		
		let keyboardFrame = window.convert(screenCoordinatedKeyboardFrame, from: nil)
		
		var windowHeight = window.frame.height
		
		if #available(iOS 11.0, *) {
			windowHeight -= window.safeAreaInsets.bottom
		}
		
		let keyboardHeight = max(windowHeight - keyboardFrame.minY, 0.0)
		let aDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
		let aCurveInt = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue
		let aCurve = UIView.AnimationCurve(rawValue: aCurveInt)!
		
		let animation = KeyboardTransitionAnimation(duration: aDuration, curve: aCurve);
		
			delegate?.keyboardWillChange(keyboardHeight, with: animation)
	}
}
