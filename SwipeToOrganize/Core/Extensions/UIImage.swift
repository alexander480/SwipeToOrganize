//
//  UIImage.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 5/2/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import UIKit

extension UIImage {
	func resize(targetSize: CGSize) -> UIImage {
		let size = self.size

		let widthRatio  = targetSize.width  / size.width
		let heightRatio = targetSize.height / size.height

		// Figure out what our orientation is, and use that to form the rectangle
		var newSize: CGSize
		
		if (widthRatio > heightRatio) { newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio) }
		else { newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio) }

		// This is the rect that we've calculated out and this is what is actually used below
		let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

		// Actually do the resizing to the rect using the ImageContext stuff
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		self.draw(in: rect)

		let newImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()

		return newImage
	}
	
	func scale(forWidth: CGFloat) -> UIImage {
		let oldWidth = CGFloat(self.size.width)
		let scaleFactor = (forWidth / oldWidth)

		let newHeight = CGFloat((self.size.height) * CGFloat(scaleFactor))
		let newWidth = oldWidth * scaleFactor

		UIGraphicsBeginImageContext(CGSize(width: CGFloat(newWidth), height: CGFloat(newHeight)))
		self.draw(in: CGRect(x: 0, y: 0, width: CGFloat(newWidth), height: CGFloat(newHeight)))
		
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage!
	}
	
	func addBorder(width: CGFloat, color: UIColor, contentMode: UIView.ContentMode?) -> UIImage? {
		let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.size))
		imageView.contentMode = contentMode ?? .scaleAspectFit
			imageView.image = self
			imageView.layer.borderWidth = width
			imageView.layer.borderColor = color.cgColor
			imageView.layer.cornerRadius = 10.0
		
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
		
			imageView.layer.render(in: context)
		
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
		
        return result
    }

	
	func addShadow(offset: CGSize?, blur: CGFloat?, color: UIColor?) -> UIImage? {
		let colourSpace = CGColorSpaceCreateDeviceRGB()
		if let shadowContext = CGContext( data: nil, width: Int(size.width + 10), height: Int(size.height + 10), bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0, space: colourSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
		{
			let shadowOffset = offset ?? CGSize(width: 5, height: -5)
			let shadowBlur = blur ?? 10
			let shadowColor = color?.cgColor ?? UIColor.black.cgColor
			
			shadowContext.setShadow(offset: shadowOffset, blur: shadowBlur, color: shadowColor)
			shadowContext.draw(cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

			let shadowedCGImage = shadowContext.makeImage()

			var shadowedImage: UIImage? = nil
			if let shadowedCGImage = shadowedCGImage {
				shadowedImage = UIImage(cgImage: shadowedCGImage)
			}

			return shadowedImage
		}
		
		return nil
	}
	
	func cornerRadius(_ radius: CGFloat? = nil) -> UIImage? {
		let maxRadius = min(size.width, size.height) / 2
		let cornerRadius: CGFloat
		
		if let radius = radius, radius > 0 && radius <= maxRadius { cornerRadius = radius } else { cornerRadius = maxRadius }
		UIGraphicsBeginImageContextWithOptions(size, false, scale)
		
		let rect = CGRect(origin: .zero, size: size)
		UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
		
		draw(in: rect)
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image
	}
}


