//
//  UIExtensions.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 4/28/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import Foundation
import UIKit

// MARK: Programmatic Extensions

extension UIView {
	func addBorder(color: UIColor = .black, width: CGFloat = 2.0) {
		self.layer.borderColor = color.cgColor
		self.layer.borderWidth = width
	}
	
	func addShadow(color: UIColor = .black, opacity: CGFloat = 2.0, offset: CGSize = CGSize(width: 2, height: 2), radius: CGFloat = 0, path: CGPath?) {
		self.layer.shadowColor = color.cgColor
		self.layer.shadowOpacity = Float(opacity)
		self.layer.shadowOffset = offset
		self.layer.shadowRadius = radius
		
		if let shadowPath = path { self.layer.shadowPath = shadowPath }
	}
	
	func addPadding(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
		self.layer.frame.inset(by: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
	}
	
	func setCornerRadius(_ radius: CGFloat) {
		self.layer.cornerRadius = radius
	}
	
	func makeCircular() {
		self.layer.cornerRadius = (self.frame.size.width / 2)
		self.clipsToBounds = true
	}
	
	// Animation Function
	
	func animateTo(frame: CGRect, withDuration duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
	  guard let _ = superview else {
		return
	  }
	  
	  let xScale = frame.size.width / self.frame.size.width
	  let yScale = frame.size.height / self.frame.size.height
	  let x = frame.origin.x + (self.frame.width * xScale) * self.layer.anchorPoint.x
	  let y = frame.origin.y + (self.frame.height * yScale) * self.layer.anchorPoint.y
	 
	  UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
		self.layer.position = CGPoint(x: x, y: y)
		self.transform = self.transform.scaledBy(x: xScale, y: yScale)
	  }, completion: completion)
	}
	
	// Turn Blur On/Off
	
	func toggleBlur(_ shouldBlur: Bool, style: UIBlurEffect.Style = .regular) {
		let blurViews = self.subviews.filter{ $0 is UIVisualEffectView }
		
		if shouldBlur {
			let effect = UIBlurEffect(style: .dark)
			let blurView = UIVisualEffectView(effect: effect)
				blurView.frame = self.bounds
				blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			
			self.addSubview(blurView)
			self.sendSubviewToBack(blurView)
		}
		else {
			for view in blurViews { view.removeFromSuperview() }
		}
	}
	
	// Calculate Center Point
	
	func centerPoint(ForSize: CGSize) -> CGPoint {
		let xPoint = ((self.frame.size.width / 2) - (ForSize.width / 2))
		let yPoint = ((self.frame.size.height / 2) - (ForSize.height / 2))
		return CGPoint(x: xPoint, y: yPoint)
	}
	
	// Display Toast Notification
	
	func displayToast(_ message: String, font: UIFont = UIFont().standard(), textColor: UIColor = UIColor.white, backgroundColor: UIColor = UIColor.black) {
		
        let toastLabel = UILabel()
			toastLabel.textColor = textColor
			toastLabel.font = font
			toastLabel.textAlignment = .center
			toastLabel.text = message
			toastLabel.alpha = 0.0
			toastLabel.layer.cornerRadius = 6
			toastLabel.backgroundColor = backgroundColor

			toastLabel.clipsToBounds  =  true

        let toastWidth: CGFloat = toastLabel.intrinsicContentSize.width + 16
        let toastHeight: CGFloat = 32
        
        toastLabel.frame = CGRect(x: self.frame.width / 2 - (toastWidth / 2),
                                  y: self.frame.height - (toastHeight * 3),
                                  width: toastWidth, height: toastHeight)
        
        self.addSubview(toastLabel)
        
        UIView.animate(withDuration: 1.5, delay: 0.25, options: .autoreverse, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            toastLabel.removeFromSuperview()
        }
    }
	
	func removeGestureRecognizers() { if let recognizers = self.gestureRecognizers { for recognizer in recognizers { self.removeGestureRecognizer(recognizer) } } }
}

// MARK: IBInspectable Extensions

extension UIView {
    
    // MARK: Border
	
    @IBInspectable var borderColor: UIColor? {
		get { if let color = layer.borderColor { return UIColor(cgColor: color) } else { return nil } }
        set { layer.borderColor = newValue?.cgColor }
    }

    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
	
	// MARK: Shadow
	
	@IBInspectable var shadowColor: UIColor? {
		get { if let color = layer.shadowColor { return UIColor(cgColor: color) } else { return nil } }
		set { layer.shadowColor = newValue?.cgColor ?? UIColor.black.cgColor }
    }
    
    @IBInspectable var shadowOpacity: Float {
        set { layer.shadowOpacity = newValue }
        get { return layer.shadowOpacity }
    }

    @IBInspectable var shadowOffset: CGPoint {
		set { layer.shadowOffset = CGSize(width: newValue.x, height: newValue.y) }
		get { return CGPoint(x: layer.shadowOffset.width, y:layer.shadowOffset.height) }
	}
    
    @IBInspectable var shadowRadius: CGFloat {
		set { layer.shadowRadius = newValue }
		get { return layer.shadowRadius }
	}
	
	// MARK: Frame
	
	@IBInspectable var padding: CGFloat {
		set { self.layer.frame.inset(by: UIEdgeInsets(top: newValue, left: newValue, bottom: newValue, right: newValue)) }
		get { return CGFloat(self.layer.frame.minX - self.layer.frame.maxX) }
	}
	
	@IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
		set { layer.cornerRadius = newValue; layer.masksToBounds = newValue > 0 }
    }
	
	@IBInspectable var circular: Bool {
		set { self.layer.cornerRadius = (self.frame.size.width / 2); self.clipsToBounds = true }
		get { if self.layer.cornerRadius == (self.frame.size.width / 2) { return true } else { return false } }
	}
}
