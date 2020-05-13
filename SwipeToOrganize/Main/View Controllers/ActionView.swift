//
//  ActionView.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 5/11/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import UIKit

// Should Take Up Whole Screen

class ActionView: UIView {
	
	var photo: Photo
	let helper = PHHelper()
	
	init(frame: CGRect, photo: Photo) {

		// MARK: Set Class Variables
		
		self.photo = photo
		
		// MARK: Initialize ActionView

		super.init(frame: frame)
		
		// MARK: Create User Interface

		// - contentView
		let contentSize = CGSize(width: self.frame.size.width, height: (self.frame.size.width) * 0.35)
		let contentPoint = CGPoint(x: (self.frame.size.width - contentSize.width) / 2, y: (self.frame.size.height - contentSize.height) / 2)
		let contentView = UIView(frame: CGRect(origin: contentPoint, size: contentSize))
		
		// - addToButton
		
		let spacing = CGFloat(35)
		let buttonSize = self.calculateButtonSize(withSpacing: spacing)
		let y = (contentSize.height - buttonSize.height) / 2
		
		let x1 = spacing
		let addToButton = UIButton(type: .custom)
			addToButton.frame = CGRect(origin: CGPoint(x: x1, y: y), size: buttonSize)
		
		// let addToImageView = UIImageView(frame: CGRect(origin: CGPoint(x: x1, y: y), size: buttonSize))
		
		// - favoriteButton
		let x2 = (spacing * 2) + (buttonSize.width)
		let favoriteButton = UIButton(type: .custom)
			favoriteButton.frame = CGRect(origin: CGPoint(x: x2, y: y), size: buttonSize)
		
		// let favoriteImageView = UIImageView(frame: CGRect(origin: CGPoint(x: x2, y: y), size: buttonSize))
		
		// - hideButton
		let x3 = ((spacing * 3) + (buttonSize.width * 2))
		let hideButton = UIButton(type: .custom)
			hideButton.frame = CGRect(origin: CGPoint(x: x3, y: y), size: buttonSize)
		
		// let hideImageView = UIImageView(frame: CGRect(origin: CGPoint(x: x3, y: y), size: buttonSize))
		
		// MARK: Setup User Interface
		
		// - ActionView
		self.backgroundColor = .clear
		// self.toggleBlur(true, style: .prominent)
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(close(sender:)))
		self.addGestureRecognizer(tapGesture)
		
		// - ContentView

		contentView.clipsToBounds = true
		
		contentView.setCornerRadius(10.0)
		contentView.addBorder(color: .white, width: 2)
		contentView.toggleBlur(true, style: .prominent)
		
		// - addToButton
		addToButton.setBackgroundImage(#imageLiteral(resourceName: "AddTo"), for: .normal)
		// addToImageView.image = #imageLiteral(resourceName: "AddTo")
		
		addToButton.addTarget(self, action: #selector(addToAction(sender:)), for: .touchUpInside)
		
		// - favoriteButton
		if self.photo.isFavorite { favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "Unfavorite"), for: .normal) /* favoriteImageView.image = #imageLiteral(resourceName: "Unfavorite") */ }
		else { favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "Favorite"), for: .normal) /* favoriteImageView.image = #imageLiteral(resourceName: "Favorite") */ }
		
		favoriteButton.addTarget(self, action: #selector(favoriteAction(sender:)), for: .touchUpInside)
		
		// - hideButton
		if self.photo.isHidden { hideButton.setBackgroundImage(#imageLiteral(resourceName: "Show"), for: .normal) /* hideImageView.image = #imageLiteral(resourceName: "Show") */ }
		else { hideButton.setBackgroundImage(#imageLiteral(resourceName: "Hide"), for: .normal) /* hideImageView.image = #imageLiteral(resourceName: "Hide") */ }
		
		hideButton.addTarget(self, action: #selector(hideAction(sender:)), for: .touchUpInside)
		
		// MARK: Add Subviews
		
		// addToButton.addSubview(addToImageView)
		// favoriteButton.addSubview(favoriteImageView)
		// hideButton.addSubview(hideImageView)
		
		contentView.addSubview(addToButton)
		contentView.addSubview(favoriteButton)
		contentView.addSubview(hideButton)
		
		//contentView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
		
		self.addSubview(contentView)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func dismiss() {
		if let recognizers = self.gestureRecognizers {
			// Remove Gesture Recognizers
			for recognizer in recognizers { self.removeGestureRecognizer(recognizer) };
			
			// Dismiss
			self.removeFromSuperview()
		}
		else {
			// Dismiss
			self.removeFromSuperview()
		}
	}
	
	private func calculateButtonSize(withSpacing: CGFloat) -> CGSize {
		let width = ((self.frame.size.width - (withSpacing * 4)) / 3)
		return CGSize(width: width, height: width)
	}
}

// MARK: UIButton Selectors

extension ActionView {
	@objc func addToAction(sender: UIButton!) {
		let addToView = AddToView(frame: self.frame, photo: self.photo)
		
		// Add UIView
		self.addSubview(addToView)
		self.bringSubviewToFront(addToView)
	}
	
	@objc func favoriteAction(sender: UIButton!) {
		if self.photo.isFavorite { self.photo.setFavorite(false) { (didSet) in if didSet { sender.setImage(#imageLiteral(resourceName: "Favorite"), for: .normal) } } }
		else { self.photo.setFavorite(true) { (didSet) in if didSet { sender.setImage(#imageLiteral(resourceName: "Unfavorite"), for: .normal) } } }
	}
	
	@objc func hideAction(sender: UIButton!) {
		if self.photo.isHidden { self.photo.setHide(false) { (didSet) in if didSet { sender.setImage(#imageLiteral(resourceName: "Hide"), for: .normal) } } }
		else { self.photo.setHide(true) { (didSet) in if didSet { sender.setImage(#imageLiteral(resourceName: "Show"), for: .normal) } } }
	}
}

// MARK: UIGestureRecognizer Selectors

extension ActionView {
	@objc func close(sender: UIGestureRecognizer) {
		DispatchQueue.main.async {
			self.removeGestureRecognizers()
			self.removeFromSuperview()
		}
	}
}
