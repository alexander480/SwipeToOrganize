//
//  PhotoCardCell.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 4/26/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import Foundation
import UIKit

import VerticalCardSwiper

class PhotoCardCell: CardCell {
	
	var photo: Photo!
	
	/*
	var image: UIImage! {
		didSet {
			self.imageView.image = self.image
			self.imageView.frame.size = self.image.size
			self.contentView.frame.size = self.image.size
			// self.superview?.frame.size = self.image.size
			self.setNeedsLayout()
		}
	}
	*/

	@IBOutlet weak var imageView: UIImageView!
	
	override func layoutSubviews() {
        super.layoutSubviews()
		
		// self.imageView.image = self.image
		// self.imageView.frame.size = self.image.size
		// self.contentView.frame.size = self.image.size
		
		self.layer.cornerRadius = 10
    }

	/*
	@IBOutlet weak var actionsView: View!
	@IBOutlet weak var hideButton: UIButton!
	@IBAction func hideAction(_ sender: Any) {
		if self.photo.isHidden {
			self.photo.setHide(false) { (didReveal) in if didReveal {
				if didReveal { DispatchQueue.main.async { self.hideButton.setImage(#imageLiteral(resourceName: "Hide Button"), for: .normal) } } }
			}
		}
		else {
			self.photo.setHide(true) { (didHide) in
				if didHide { DispatchQueue.main.async { self.hideButton.setImage(#imageLiteral(resourceName: "Show"), for: .normal) } }
			}
		}
	}
	
	@IBOutlet weak var favoriteButton: UIButton!
	@IBAction func favoriteAction(_ sender: Any) {
		if self.photo.isFavorite {
			self.photo.setFavorite(false) { (didSet) in
				if didSet { DispatchQueue.main.async { self.favoriteButton.setImage(#imageLiteral(resourceName: "Favorite Button (Not Filled)"), for: .normal) } }
			}
			
		}
		else {
			self.photo.setFavorite(true) { (didSet) in
				if didSet { DispatchQueue.main.async { self.favoriteButton.setImage(#imageLiteral(resourceName: "Favorite Button (Filled)"), for: .normal) } }
			}
		}
	}
	
	@IBOutlet weak var addToButton: UIButton!
	@IBAction func addToAction(_ sender: Any) {
		
	}
*/
	
    public func setRandomBackgroundColor() {
        let randomRed: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomGreen: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomBlue: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
		DispatchQueue.main.async { self.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0) }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
