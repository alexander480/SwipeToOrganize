//
//  Asset.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 5/2/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import ALExt

import UIKit
import Photos

class Asset: NSObject {
    
    var cacheManager: PHCachingImageManager
    
	var asset: PHAsset
    var assetType: PHAssetMediaType
    
	var id: String
	
	var isFavorite: Bool
	var isHidden: Bool
	
    init(asset: PHAsset, cacheManager: PHCachingImageManager) {
        
        self.cacheManager = cacheManager
        
		self.asset = asset
        self.assetType = asset.mediaType
        
		self.id = asset.localIdentifier
        
		self.isFavorite = asset.isFavorite
		self.isHidden = asset.isHidden
	}
    
    func fetchImage(forWidth: CGFloat?, completion: @escaping (UIImage) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            let reqOptions = PHImageRequestOptions()
                reqOptions.isSynchronous = false
                reqOptions.isNetworkAccessAllowed = true
                reqOptions.deliveryMode = .highQualityFormat
                reqOptions.resizeMode = .none
            
            // let assetSize = self.asset.size()
            // let scaledSize = assetSize.scale(forWidth: cell)
            
            self.cacheManager.requestImage(for: self.asset, targetSize: CGSize(width: self.asset.pixelWidth, height: self.asset.pixelHeight), contentMode: .default, options: reqOptions) { (image, info) in
                if let img = image {
                    print("[SUCCESS] Successfully Got UIImage From PHAsset.")
                    
                    if let width = forWidth {
                        let scaledImage = img.scale(forWidth: width)
                        completion(scaledImage)
                    }
                    else {
                        completion(img)
                    }
                }
                else {
                    print("[ERROR] An Error Occured While Requesting UIImage For PHAsset.")
                    print("[ERROR-INFO] \(String(describing: info))")
                    
                    if let width = forWidth {
                        let scaledImage = #imageLiteral(resourceName: "Error Image").scale(forWidth: width)
                        completion(scaledImage)
                    }
                    else {
                        print("[WARNING] Unable To Validate Prefered Image Width.")
                        completion(#imageLiteral(resourceName: "Error Image"))
                    }
                }
            }
        }
    }
    
    func fetchVideo(completion: @escaping (AVPlayerItem?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            let reqOptions = PHVideoRequestOptions()
                reqOptions.isNetworkAccessAllowed = true
                reqOptions.deliveryMode = .highQualityFormat
            
            self.cacheManager.requestPlayerItem(forVideo: self.asset, options: reqOptions) { (playerItem, info) in
                if let item = playerItem {
                    print("[SUCCESS] Successfully Got AVPlayerItem From PHAsset")
                    
                    completion(item)
                }
                else {
                    print("[ERROR] Unable To Retrieve AVPlayerItem For PHAsset.")
                    print("[ERROR-INFO] \(String(describing: info))")
                    
                    completion(nil)
                }
            }
        }
    }
    
    func estimatedSize(forWidth: CGFloat) -> CGSize {
        return self.asset.scaledSize(toWidth: forWidth)
    }
	
	func skip(_ completion: @escaping () -> ()) {
		var arr = UserDefaults.standard.stringArray(forKey: "proccessedAssetIdentifiers") ?? [String]()
			arr.append(self.id)
		
		UserDefaults.standard.set(arr, forKey: "proccessedAssetIdentifiers")
		
		completion()
	}
	
	func delete(completion: @escaping (Bool) -> ()) {
		PHPhotoLibrary.shared().performChanges({ PHAssetChangeRequest.deleteAssets(([self.asset] as NSArray)) }) { (didDelete, error) in
			if didDelete {
				print("[SUCCESS] Successfully Deleted Photo From Library.")
				completion(true)
			}
			else if let err = error {
				print("[ERROR] Unable To Delete PHAsset. [MESSAGE] \(err.localizedDescription)")
				completion(false)
			}
		}
	}
	
	func setFavorite(_ shouldFavorite: Bool, completion: @escaping (Bool) -> ()) {
		PHPhotoLibrary.shared().performChanges({ let req = PHAssetChangeRequest(for: self.asset); req.isFavorite = shouldFavorite }) { (didToggle, error) in
			if didToggle {
				print("[SUCCESS] Successfully Set 'Favorite' Attribute To \(shouldFavorite).")
				completion(true)
			}
			else if let err = error {
				print("[ERROR] Unable To Set 'Favorite' Attribute To \(shouldFavorite). [MESSAGE] \(err.localizedDescription)")
				completion(false)
			}
		}
	}
	
	func setHide(_ shouldHide: Bool, completion: @escaping (Bool) -> ()) {
		PHPhotoLibrary.shared().performChanges({ let req = PHAssetChangeRequest(for: self.asset); req.isHidden = shouldHide }) { (didHide, error) in
			if didHide {
				if shouldHide { print("[SUCCESS] Asset Hidden.") } else { print("[SUCCESS] Asset Revealed.") }
				completion(true)
			}
			else if let err = error {
				print("[ERROR] Unable To Hide Photo From Library. [MESSAGE] \(err.localizedDescription)")
				completion(false)
			}
		}
	}
	
	func inAlbums(completion: @escaping ([Album]) -> ()) {
		var albums = [Album]()
		
		let fetchOptions = PHFetchOptions()
		
		let fetchResult = PHAssetCollection.fetchAssetCollectionsContaining(self.asset, with: .album, options: fetchOptions)
		fetchResult.enumerateObjects { (collection, index, stop) in
			albums.append(Album(collection: collection))
			
			if (fetchResult.count - 1 == index) {
				stop.pointee = true
				
				print("[INFO] Successfully Fetched \(albums.count) Albums.")
				completion(albums)
			}
		}
	}
}
