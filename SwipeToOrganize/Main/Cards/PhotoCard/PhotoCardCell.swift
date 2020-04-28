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

	@IBOutlet weak var imageView: UIImageView!
	
    public func setRandomBackgroundColor() {
        let randomRed: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomGreen: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomBlue: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        self.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func layoutSubviews() {
        self.layer.cornerRadius = 12
        super.layoutSubviews()
    }
}
