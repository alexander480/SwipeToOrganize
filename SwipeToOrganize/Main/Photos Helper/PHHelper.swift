//
//  PHHelper.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 4/28/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import Foundation
import UIKit

import Photos

class PHHelper: NSObject {
	
	func fetchAlbums(completion: @escaping ([Album]) -> ()) {
		self.checkAuthorization { (isAuthorized) in
			if isAuthorized {
				var albums = [Album]()
				
				let fetchOptions = PHFetchOptions()
				
				let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)
				fetchResult.enumerateObjects { ( collection, index, stop) in
					albums.append(Album(collection: collection))
					
					if (fetchResult.count - 1 == index) {
						stop.pointee = true
						
						print("[INFO] Successfully Fetched \(albums.count) Albums.")
						completion(albums)
					}
				}
			}
		}
	}
	
	func fetchPhotos(completion: @escaping ([Photo]) -> ()) {
		self.checkAuthorization { (isAuthorized) in
			if isAuthorized {
				var photosBuf = [Photo]()
				
				let fetchOptions = PHFetchOptions()
					fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
					fetchOptions.includeHiddenAssets = false
				
				let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
				fetchResult.enumerateObjects { (asset, index, stop) in
					photosBuf.append(Photo(asset: asset))
					print("[PROGRESS] \(index) / \(fetchResult.count - 1)")
					
					if (fetchResult.count - 1 == index) {
						stop.pointee = true
						
						// Remove Already Proccessed Photos From Array
						let proccessedIDs = self.fetchProccessedIDs()
						let photos = photosBuf.filter { proccessedIDs.contains($0.id) == false }
						
						print("[INFO] Successfully Created [Photo] Containing \(photos.count) Photos.")
						completion(photos)
					}
				}
			}
		}
	}
	
	// Check Photo Library Authorization
	private func checkAuthorization(completion: @escaping (Bool) -> ()) {
		PHPhotoLibrary.requestAuthorization { (status) in
			switch status {
				case .authorized:
					print("[INFO] Photo Library Access Authorized")
					completion(true)
				case .denied, .restricted:
					print("[WARNING] Photo Library Authorization Denied.")
					completion(false)
				case .notDetermined:
					print("[WARNING] Photo Library Authorization Not Yet Determined.")
					completion(false)
				@unknown default:
					print("[ERROR] Unknown Error Occured While Requesting Authorization.")
					completion(false)
			}
		}
	}
	
	func fetchProccessedIDs() -> [String] { return UserDefaults.standard.stringArray(forKey: "proccessedAssetIdentifiers") ?? [String]() }
	
	func addProccessedID(_ ID: String) {
		var arr = UserDefaults.standard.stringArray(forKey: "proccessedAssetIdentifiers") ?? [String]()
			arr.append(ID)
		
		UserDefaults.standard.set(arr, forKey: "proccessedAssetIdentifiers")
	}
}
