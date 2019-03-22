//
//  ViewController.swift
//  AppsConf
//
//  Created by k.mordan on 08/03/2019.
//  Copyright © 2019 k.mordan. All rights reserved.
//

import UIKit
import YYKeyboardManager

class ViewController: UIViewController {
	private var tracker: KeyboardTracker!
	
	var _panningKeybard: Bool = false
	var _startPanDelta: CGFloat = 0.0
	var _panStartFromInput: Bool = false
	var keyboardStartY: CGFloat = 0.0
	
	@IBOutlet weak var inputTolbar: UIView!
	
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var bottomInputToolbarConstraint: NSLayoutConstraint!
	
	var wasTextFieldFirstResponderBeforeAppDidEnterBackground = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tracker = KeyboardTracker(with: self)
		self.tracker.enable()
		
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
		view.addGestureRecognizer(tapRecognizer)
		
		subscribeForApplicationNotification()
	}
	
	@objc func tapHandler() {
		view.endEditing(true)
	}
}

// MARK - Interactive keyboard

extension ViewController {
	@objc func handle(_ pan: UIPanGestureRecognizer) {
		switch pan.state {
		case .began:
			adjustKeyboardFor(pan)
		case .changed:
			adjustKeyboardFor(pan)
		case .ended, .cancelled:
			endKeyboardInteractionFor(pan)
		default:
			break
		}
	}
	
	func adjustKeyboardFor(_ pan: UIPanGestureRecognizer) {
		let relativeInputLocation = pan.location(in: inputTolbar).y
		
		if relativeInputLocation > 0.0 {
			if _panningKeybard == false {
				_panningKeybard = true
				
				keyboardStartY = view.frame.maxY - bottomInputToolbarConstraint.constant
				
				let translation = pan.translation(in: view).y
				_startPanDelta = translation
				
				if (translation - relativeInputLocation) > 0.0
				{
					_panStartFromInput = false
				}
				else
				{
					_panStartFromInput = true
				}
			}
		}
		
		if _panningKeybard == false
		{
			return
		}
		
		var translation = pan.translation(in: view).y
		translation -= _startPanDelta
		
		if translation < 0.0
		{
			translation = 0.0
		}
		
		if translation > view.frame.height - keyboardStartY
		{
			translation = view.frame.height - keyboardStartY;
		}
		
		let finalKeyboardHeight = view.frame.height - keyboardStartY - translation - inputTolbar.bounds.height;

		let needUpdateCustomKeyboardHeight = (finalKeyboardHeight >= 258.0);
		
		if needUpdateCustomKeyboardHeight {
			let keyboardHeight = view.frame.height - keyboardStartY;
			
			let diff = finalKeyboardHeight - keyboardHeight;
			
//			[self.inputToolbar updateCustomKeyboardHeightWithDiff:diff animated:NO];
		} else {
			var y = keyboardStartY
			y += translation;
			
			let keyboardManager = YYKeyboardManager.default()
			if let kView = keyboardManager.keyboardView {
				var systemKeyboardFrame = kView.frame;
				systemKeyboardFrame.origin.y = y;
				
				keyboardManager.keyboardView?.frame = systemKeyboardFrame;
			}
		}
	}
	
	func endKeyboardInteractionFor(_ pan: UIPanGestureRecognizer) {
	}
}

extension ViewController {
	private func subscribeForApplicationNotification() {
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector:#selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
		
		notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
	}
	
	@objc func willEnterForeground(notification: NSNotification) {
		if wasTextFieldFirstResponderBeforeAppDidEnterBackground {
			UIView.performWithoutAnimation {
				textField.becomeFirstResponder()
			}
		}
		
		print("is first responder \(textField.isFirstResponder)")
		print(notification)
	}
	
	@objc func willResignActive(notification: NSNotification) {
		wasTextFieldFirstResponderBeforeAppDidEnterBackground = textField.isFirstResponder
		print("is first responder \(textField.isFirstResponder)")
		print(notification)
	}
	
	@objc func didEnterBackground(notification: NSNotification) {
		print("is first responder \(textField.isFirstResponder)")
		print(notification)
	}
}

extension ViewController: KeyboardTrackerDelegare {
	func keyboardWillChange(_ height: CGFloat, with animation: KeyboardTransitionAnimation) {
		
		self.bottomInputToolbarConstraint.constant = height
		
		let options = UIView.AnimationOptions.beginFromCurrentState.union(UIView.AnimationOptions(rawValue:UInt(animation.curve.rawValue << 16)))
		
		UIView.animate(withDuration: animation.duration,
					   delay: 0,
					   options: options,
					   animations: {
						self.view.layoutSubviews()
		}, completion: nil)
	}
}
