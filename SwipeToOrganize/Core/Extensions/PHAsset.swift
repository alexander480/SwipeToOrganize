//
//  PHAsset.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 5/4/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import Photos

extension PHAsset {
	func size() -> CGSize { return CGSize(width: self.pixelWidth, height: self.pixelHeight) }
	func scaledSize(forWidth: CGFloat) -> CGSize { let oldSize = self.size(); return oldSize.scale(forWidth: forWidth) }
}
