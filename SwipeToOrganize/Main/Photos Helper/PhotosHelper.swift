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

class PhotosHelper: NSObject {
    
    let cacheManager = PHCachingImageManager()
	
    let queue = DispatchQueue.global(qos: .userInitiated)
    let backgroundQueue = DispatchQueue.init(label: "CacheQueue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    
    var assetFetchResult: PHFetchResult<PHAsset>?
    var collectionFetchResult: PHFetchResult<PHAssetCollection>?
    
    var organizedAlbum: Album!
    
    override init() {
        super.init()
        
        self.cacheManager.allowsCachingHighQualityImages = true
        
        self.createSwipeToOrganizeAlbum()
    }
    
    func fetchAssets(completion: @escaping ([Asset]) -> ()) {
        queue.async {
            self.checkAuthorization { (isAuthorized) in
                if isAuthorized {
                    var assetBuf = [Asset]()
                    
                    let predicate = NSPredicate(format: "mediaType == %d || mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
                    let fetchOptions = PHFetchOptions()
                        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                        fetchOptions.includeHiddenAssets = false
                        fetchOptions.predicate = predicate
                        fetchOptions.includeAssetSourceTypes = .typeUserLibrary
                    
                    // MARK: Settings.shouldLimitPhotos
                    if settings.shouldLimitPhotos { fetchOptions.fetchLimit = 25 }
                    
                    let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
                    self.assetFetchResult = fetchResult
                    
                    fetchResult.enumerateObjects { (asset, index, stop) in
                        
                        assetBuf.append(Asset(asset: asset, cacheManager: self.cacheManager))
                        if settings.shouldDisplayProgress { print("[PROGRESS] \(index) / \(fetchResult.count - 1)") }
                        
                        if (fetchResult.count - 1 == index) {
                            stop.pointee = true
                            
                            // Remove Already Proccessed Photos From Array
                            let proccessedIDs = self.fetchProccessedIDs()
                            let assets = assetBuf.filter { proccessedIDs.contains($0.id) == false }
                            
                            print("[INFO] Successfully Created [Asset] Containing \(assets.count) Images/Videos.")
                            
                            // self.startCaching(assets: assets)
                            
                            completion(assets)
                        }
                    }
                }
            }
        }
    }
    
    func fetchAlbums(completion: @escaping ([Album]) -> ()) {
        queue.async {
            self.checkAuthorization { (isAuthorized) in
                if isAuthorized {
                    var albums = [Album]()
                    let fetchOptions = PHFetchOptions()
                    
                    let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)
                    self.collectionFetchResult = fetchResult
                    
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
    }
    
    func createSwipeToOrganizeAlbum() {
        self.fetchAlbums { (albums) in
            let organizedAlbums = albums.filter { (album) -> Bool in album.name == "SwipeToOrganize" }
            
            if !organizedAlbums.isEmpty {
                if let album = organizedAlbums.first {
                    self.organizedAlbum = album
                    print("[INFO] SwipeToOrganize Album Already Created.")
                }
            }
            else {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "SwipeToOrganize")
                }, completionHandler: { success, error in
                    if success {
                        let filteredAlbums = albums.filter { (album) -> Bool in album.name == "SwipeToOrganize" }
                        if let newAlbum = filteredAlbums.first {
                            self.organizedAlbum = newAlbum
                            print("[SUCCESS] Successfully Created SwipeToOrganize Album.")
                        }
                    }
                    else { print("[ERROR] Unable To Create SwipeToOrganize Album. [MESSAGE] \(String(describing: error)).") }
                })
            }
        }
    }
	
	// Check Photo Library Authorization
	private func checkAuthorization(completion: @escaping (Bool) -> ()) {
		queue.async {
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
	}
    
    func startCaching(assets: [Asset]) {
        backgroundQueue.async {
            self.cacheManager.allowsCachingHighQualityImages = true
            
            let cacheReqOptions = PHImageRequestOptions()
                cacheReqOptions.deliveryMode = .highQualityFormat
                cacheReqOptions.isNetworkAccessAllowed = true
                cacheReqOptions.isSynchronous = false
                cacheReqOptions.resizeMode = .none
            
            // PHAsset Properties From Asset
            let phAssets = assets.map { return $0.asset }
            
            self.cacheManager.startCachingImages(for: phAssets, targetSize: .zero, contentMode: .default, options: cacheReqOptions)
        }
    }
    
    func stopCaching(assets: [Asset]) {
        
        // PHAsset Properties From Asset
        let phAssets = assets.map { return $0.asset }
        
        self.cacheManager.stopCachingImages(for: phAssets, targetSize: .zero, contentMode: .default, options: nil)
    }
	
	func fetchProccessedIDs() -> [String] {
		return UserDefaults.standard.stringArray(forKey: "proccessedAssetIdentifiers") ?? [String]()
	}
	
	func addProccessedID(_ ID: String) {
		queue.async {
			var arr = UserDefaults.standard.stringArray(forKey: "proccessedAssetIdentifiers") ?? [String]()
				arr.append(ID)
			
			UserDefaults.standard.set(arr, forKey: "proccessedAssetIdentifiers")
		}
	}
}
