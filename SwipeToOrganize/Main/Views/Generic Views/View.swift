//
//  View.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 4/30/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import UIKit

@IBDesignable
class View: UIView {
	
	// MARK: Padding
	
	@IBInspectable var insets = UIEdgeInsets.zero
	
	@IBInspectable var top: CGFloat { get { return insets.top } set { insets.top = newValue } }
	@IBInspectable var bottom: CGFloat { get { return insets.bottom } set { insets.bottom = newValue } }
	@IBInspectable var left: CGFloat { get { return insets.left } set { insets.left = newValue } }
	@IBInspectable var right: CGFloat { get { return insets.right } set { insets.right = newValue } }
	
	// MARK: Gradient
	
	@IBInspectable var enableGradient: Bool = false { didSet { setNeedsLayout() } }

	@IBInspectable var gradientLayer: CAGradientLayer!
	override class var layerClass: AnyClass { return CAGradientLayer.self }

	@IBInspectable var topColor: UIColor = .red { didSet { setNeedsLayout() } }
	@IBInspectable var bottomColor: UIColor = .yellow { didSet { setNeedsLayout() } }
	
	@IBInspectable var startPoint: CGPoint = CGPoint(x: 0.0, y: 0.5) { didSet { setNeedsLayout() } }
	@IBInspectable var endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5) { didSet { setNeedsLayout() } }
	
	func animate(duration: TimeInterval, newTopColor: UIColor, newBottomColor: UIColor) {
        let fromColors = self.gradientLayer?.colors
        let toColors: [AnyObject] = [ newTopColor.cgColor, newBottomColor.cgColor]
		
        self.gradientLayer?.colors = toColors
		
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
			animation.fromValue = fromColors
			animation.toValue = toColors
			animation.duration = duration
			animation.isRemovedOnCompletion = true
			animation.fillMode = .forwards
			animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
		
        self.gradientLayer?.add(animation, forKey:"animateGradient")
    }
	
	// MARK: Blur
	
	@IBInspectable var enableBlur: Bool = false { didSet { self.toggleBlur() } }
	
	private func toggleBlur() {
		let blurViews = self.subviews.filter{ $0 is UIVisualEffectView }
		
		if self.enableBlur {
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
	
	// MARK: Overrides
	
	override func layoutSubviews() {
		if self.enableGradient {
			self.gradientLayer = self.layer as? CAGradientLayer
			
			self.gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
			
			self.gradientLayer.startPoint = self.startPoint
			self.gradientLayer.endPoint = self.endPoint
		}
    }
	
	open override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		self.layer.frame.inset(by:  UIEdgeInsets(top: self.top, left: self.left, bottom: self.bottom, right: self.right))
	}
}
