//
//  ViewController.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 4/26/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import Foundation
import UIKit
import Photos

import VerticalCardSwiper

var additionalLogging = false

class MainVC: UIViewController {
	
	var assets: [PHAsset]?
	var proccessedAssets = [PHAsset]()
	
	var lastIndex: Int?
	
	@IBOutlet weak var cardSwiper: VerticalCardSwiper!
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
		self.cardSwiper.delegate = self
		self.cardSwiper.datasource = self
		
		// self.cardSwiper.isSideSwipingEnabled = true
		
		self.cardSwiper.register(nib: UINib(nibName: "PhotoCardCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCardCell")
		
		self.fetchPhotos()
	}

	// MARK: Photos Functions
	
	// Fetch Photos After Checking Authorization
	func fetchPhotos() {
		self.checkAuthorization { (isAuthorized) in
			if isAuthorized {
				let options = PHFetchOptions()
					options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
				
				let fetchResult = PHAsset.fetchAssets(with: .image, options: options)
				let fetchedAssets = fetchResult.objects(at: IndexSet(integersIn: 0...fetchResult.count - 1))
				self.assets = fetchedAssets.filter({ (asset) -> Bool in
					self.proccessedAssets.contains(asset) == false
				})
				
				DispatchQueue.main.async { self.cardSwiper.reloadData() }
			}
			else {
				// Present "Please Authorize" Alert Here
			}
		}
	}
	
	func updateFetchedPhotos(removeIndex: Int) {
		self.checkAuthorization { (isAuthorized) in
			if isAuthorized {
				let options = PHFetchOptions()
					options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
				
				let fetchResult = PHAsset.fetchAssets(with: .image, options: options)
				let fetchedAssets = fetchResult.objects(at: IndexSet(integersIn: 0...fetchResult.count - 1))
				self.assets = fetchedAssets.filter({ (asset) -> Bool in
					self.proccessedAssets.contains(asset) == false
				})
				
				DispatchQueue.main.async { self.cardSwiper.deleteCards(at: [removeIndex]) }
			}
			else {
				// Present "Please Authorize" Alert Here
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
	
	private func setFavorite(_ to: Bool, _ asset: PHAsset) {
		PHPhotoLibrary.shared().performChanges({ let req = PHAssetChangeRequest(for: asset); req.isFavorite = to }) { (didToggle, error) in
			if let err = error {
				print("[ERROR] Unable To Set 'Favorite' Attribute To \(to). [MESSAGE] \(err.localizedDescription)");
				// Present "Unable To Favorite/Remove From Favorites" Alert Here
			}
			else if didToggle {
				print("[SUCCESS] Successfully Set 'Favorite' Attribute To \(to).")
				// Maybe Present A Small 'Toast' Notification
			}
		}
	}
	
	private func hide(_ asset: PHAsset) {
		PHPhotoLibrary.shared().performChanges({ let req = PHAssetChangeRequest(for: asset); req.isHidden = true }) { (didHide, error) in
			if let err = error {
				print("[ERROR] Unable To Hide Photo From Library. [MESSAGE] \(err.localizedDescription)");
				// Present "Unable To Hide" Alert Here
			}
			else if didHide {
				print("[SUCCESS] Successfully Hid Photo From Library.")
				// Maybe Present A Small 'Toast' Notification
			}
		}
	}
	
	private func delete(asset: PHAsset, index: Int) {
		let assetArr = [asset] as NSArray
		PHPhotoLibrary.shared().performChanges({ PHAssetChangeRequest.deleteAssets(assetArr) }) { (didDelete, error) in
			if let err = error {
				print("[ERROR] Unable To Delete Photo From Library. [MESSAGE] \(err.localizedDescription)")
				
				// Present "Unable To Delete" Alert Here
			}
			else if didDelete {
				print("[SUCCESS] Successfully Deleted Photo From Library.")
				
				// Below Line MUST Be Ran On The Main Thread
				// self.lastIndex = self.cardSwiper.focussedCardIndex
				
				self.updateFetchedPhotos(removeIndex: index)

				// self.cardSwiper.reloadData()
	
				// self.cardSwiper.scrollToCard(at: self.lastIndex ?? 0, animated: false)
				
				// Maybe Present A Small 'Toast' Notification
				// Inform User That They Need To Go Into Recently Deleted
			}
		}
	}
	
	private func skip(index: Int) {
		self.proccessedAssets.append(self.assets![index])
		self.updateFetchedPhotos(removeIndex: index)
		
		/*
		DispatchQueue.main.async {
			// let lastIndex = self.cardSwiper.focussedCardIndex ?? 0
			// self.assets?.remove(at: index)
			self.cardSwiper.deleteCards(at: [index])
			// self.cardSwiper.reloadData()
			
		}
		*/
	}
}

extension MainVC: VerticalCardSwiperDelegate, VerticalCardSwiperDatasource {
	func willSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
		switch swipeDirection {
			case .Left:
				if additionalLogging { print("[INFO] Card Swiped Left") }
				if let assetToDelete = self.assets?[index] { self.delete(asset: assetToDelete, index: index) }
			case .Right:
				if additionalLogging { print("[INFO] Card Swiped Right") }
				// self.assets = Array(newAssets!)
				self.skip(index: index)
			case .None:
				if additionalLogging { print("[INFO] didSwipeCardAway Called. SwipeDirection == .None") }
		}
	}
	
	func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
		if let assets = self.assets { return assets.count } else { return 0 }
	}
	
	func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
		let cell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "PhotoCardCell", for: index) as! PhotoCardCell
		
		if let asset = self.assets?[index] {
			print("[INFO] Successfully Validated Image Asset.")
			
			if asset.isFavorite { /* Change Favorite Button Image */ }
			
			cell.imageView.fetchImage(asset: asset, contentMode: .default, targetSize: cell.frame.size)
			
			return cell
		}
		else {
			print("[ERROR] Unable To Validate PHAsset Array.");
			cell.imageView.image = #imageLiteral(resourceName: "Error Image")
			
			return cell
		}
	}
	
	/* func sizeForItem(verticalCardSwiperView: VerticalCardSwiperView, index: Int) -> CGSize {
        return CGSize(width: verticalCardSwiperView.frame.width * 0.75, height: verticalCardSwiperView.frame.height * 0.75)
    } */
	
	
}
