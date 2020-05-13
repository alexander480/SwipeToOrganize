//
//  CGSize.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 5/2/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import CoreGraphics

extension CGSize {
	func scale(forWidth: CGFloat) -> CGSize {
		let oldWidth = self.width
		let scaleFactor = forWidth / oldWidth

		let h = CGFloat((self.height) * CGFloat(scaleFactor))
		let w = oldWidth * scaleFactor
		
		return CGSize(width: w, height: h)
	}
}
