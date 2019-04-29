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
	
	var tummyView: UIView!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var topConstraint: NSLayoutConstraint!
	@IBOutlet weak var bottomInputToolbarConstraint: NSLayoutConstraint!
	
	var wasTextFieldFirstResponderBeforeAppDidEnterBackground = false
	
	var imageView: UIImageView?

	override func viewDidLoad() {
		super.viewDidLoad()
	
//		tummyView = Bundle.main.loadNibNamed("TummyView", owner: self, options: nil)?.first as! UIView
//		self.view.addSubview(tummyView)
//		tummyView.frame = CGRect(x: 0, y: self.view.frame.height - tummyView!.frame.height, width: tummyView!.frame.width, height: tummyView!.frame.height)

		self.tracker = KeyboardTracker(with: self)
		self.tracker.enable()
		
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
		view.addGestureRecognizer(tapRecognizer)
		
		subscribeForApplicationNotification()
		
		let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handle(_:)))
		view.addGestureRecognizer(panRecognizer)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if #available(iOS 11.0, *) {
			topConstraint.constant += view.safeAreaInsets.bottom
		}
		
		if UI_USER_INTERFACE_IDIOM() == .pad {
			topConstraint.constant *= 0.2
		}
	}
	
	@objc func tapHandler() {
		textField.resignFirstResponder()
	}
	
//	override var inputAccessoryView: UIView? {
//		return tummyView
//	}
//	
//	override var canBecomeFirstResponder: Bool {
//		return true
//	}
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
		let relativeInputLocation = pan.location(in: tummyView).y
		
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
		
		var y = keyboardStartY
		y += translation;
		
		
		let keyboardManager = YYKeyboardManager.default()
		if let kView = keyboardManager.keyboardView {
			var systemKeyboardFrame = kView.frame;
			systemKeyboardFrame.origin.y = y;
			
			if #available(iOS 11.0, *) {
				if systemKeyboardFrame.origin.y < view.frame.height {
					systemKeyboardFrame.origin.y -= view.safeAreaInsets.bottom

				}
			}
			
			keyboardManager.keyboardView?.frame = systemKeyboardFrame;
			
			bottomInputToolbarConstraint.constant = (view.bounds.height - y)
		}
	}
	
	func endKeyboardInteractionFor(_ pan: UIPanGestureRecognizer) {
		UIView.performWithoutAnimation {
			tapHandler()
		}
	}
}

extension ViewController {
	private func subscribeForApplicationNotification() {
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector:#selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
		
		notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
		
		notificationCenter.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
		
		notificationCenter.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	@objc func willResignActive(notification: NSNotification) {
		wasTextFieldFirstResponderBeforeAppDidEnterBackground = textField.isFirstResponder
		print("is first responder \(textField.isFirstResponder)")
		print(notification)
		
		guard let keyWindow = UIApplication.shared.keyWindow else {
			return
		}
		
		imageView = UIImageView(frame: keyWindow.bounds)
		imageView!.contentMode = .center
		imageView!.image = fullScreenShot()
		
		guard let subview = keyWindow.subviews.last else {
			return
		}
		
		subview.addSubview(imageView!)
	}
	
	@objc func didEnterBackground(notification: NSNotification) {
		print("is first responder \(textField.isFirstResponder)")
		print(notification)
	}
	
	@objc func willEnterForeground(notification: NSNotification) {
		
		if wasTextFieldFirstResponderBeforeAppDidEnterBackground {
			UIView.performWithoutAnimation {
				textField.becomeFirstResponder()
			}
		}
		
		print("is first responder \(textField.isFirstResponder)")
		print(notification)
		
		if let imageView = self.imageView {
			imageView.removeFromSuperview()
		}
	}
	
	@objc func didBecomeActive(notification: NSNotification) {
		if let imageView = self.imageView {
			imageView.removeFromSuperview()
		}
	}
	
	func fullScreenShot() -> UIImage? {
		let imgSize = UIScreen.main.bounds.size
		UIGraphicsBeginImageContextWithOptions(imgSize, false, 0)
		for window in UIApplication.shared.windows {
			window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
		}
		
		let img = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return img
	}
}

extension ViewController: KeyboardTrackerDelegare {
	func keyboardWillChange(_ height: CGFloat, with animation: KeyboardTransitionAnimation) {
		
		if (height - self.bottomInputToolbarConstraint.constant) < 20 && (height - self.bottomInputToolbarConstraint.constant) > 0  {
			return
		}
		
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
