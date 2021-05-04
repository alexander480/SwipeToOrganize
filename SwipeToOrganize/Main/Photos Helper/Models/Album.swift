//
//  Collection.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 5/6/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import ALExt

import UIKit
import Photos

class Album: NSObject {
	var collection: PHAssetCollection
	var name: String
	
	var imageCount: Int

	var thumbnail: UIImage?
	
	init(collection: PHAssetCollection) {
		self.collection = collection
		self.name = collection.localizedTitle ?? "Unknown Name"
		self.imageCount = collection.estimatedAssetCount
		
		// Set Default Thumbnail
		let defaultThumbnail = #imageLiteral(resourceName: "Collection Thumbnail").resize(targetSize: CGSize(width: 100, height: 100))
		self.thumbnail = defaultThumbnail
		
		// Initialize
		super.init()
		
		// Fetch Actual Thumbnail After Init
		self.fetchThumbnail(size: nil) { (thumbnail) in if let image = thumbnail { self.thumbnail = image } }
	}
	
	func add(_ photo: Asset, completion: @escaping (Bool) -> ()) {
		PHPhotoLibrary.shared().performChanges({
			let changeReq = PHAssetCollectionChangeRequest.init(for: self.collection)
				changeReq?.addAssets([photo.asset] as NSArray)
		})
		{ (didSave, error) in
			if didSave {
				print("[SUCCESS] Successfully Saved PHAsset To PHAssetCollection Named: \(self.name)")
				completion(true)
			}
			else if let err = error {
				print("[ERROR] Error Saving PHAsset To PHAssetCollection Named: \(self.name). [MESSAGE] \(err.localizedDescription)")
				completion(false)
			}
			else {
				print("[ERROR] An Unknown Error Occured While Saving PHAsset To PHAssetCollection Named: \(self.name).")
				completion(false)
			}
		}
	}
	
	func fetchThumbnail(size: CGSize?, completion: @escaping (UIImage?) -> ()) {
		let fetchOptions = PHFetchOptions()
			fetchOptions.fetchLimit = 1
			fetchOptions.includeHiddenAssets = false
		
		let fetchResult = PHAsset.fetchKeyAssets(in: self.collection, options: fetchOptions)
		if let firstAsset = fetchResult?.firstObject {
			let manager = PHImageManager.default()
			
			let targetSize = size ?? CGSize(width: 100, height: 100)
			
			let reqOptions = PHImageRequestOptions()
				reqOptions.isSynchronous = true
				reqOptions.isNetworkAccessAllowed = true
				reqOptions.deliveryMode = .fastFormat
				reqOptions.resizeMode = .exact
				reqOptions.normalizedCropRect = CGRect(origin: CGPoint(x: 0, y: 0), size: targetSize)
			
            manager.requestImage(for: firstAsset, targetSize: targetSize, contentMode: .default, options: reqOptions) { (image, info) in
				if let thumbnail = image {
					print("[INFO] Successfully Fetched Thumbnail Image For Collection: \(self.name).")
                    let cropped = thumbnail.resize(targetSize: CGSize(width: 100, height: 100))
					completion(cropped)
				}
				else {
					print("[ERROR] An Error Occured While Fetching Thumbnail Image For Collection: \(self.name)")
					completion(nil)
				}
			}
		}
		else {
			completion(nil)
		}
	}
}
