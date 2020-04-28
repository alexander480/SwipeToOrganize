//
//  Extensions.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 4/26/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import Foundation
import UIKit

import Photos

extension UIImageView {
	func fetchImage(asset: PHAsset, contentMode: PHImageContentMode, targetSize: CGSize) {
		let options = PHImageRequestOptions()
			options.version = .original
			options.deliveryMode = .highQualityFormat
		
		PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
			guard let image = image else { return }
			
			switch contentMode {
				case .aspectFill:
					self.contentMode = .scaleAspectFill
				case .aspectFit:
					self.contentMode = .scaleAspectFit
			}
			
			self.image = image
		}
   }
}
