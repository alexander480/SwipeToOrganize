//
//  ViewController.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 4/26/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//


// Make Sure To Add Asset ID To Proccessed Array After Performing setFavorite, addToAlbum, etc. Functions.

import Foundation
import UIKit
import Photos

import VerticalCardSwiper

let cellWidth: CGFloat = 280
var additionalLogging = true

class MainVC: UIViewController {
	
	var photos = [Photo]()
	var albums = [Album]()
	
	var selectedPhoto: Photo?
	
	let helper = PHHelper()
	
	@IBOutlet weak var deleteSideBar: View!
	@IBOutlet weak var keepSideBar: View!
	
	@IBOutlet weak var cardSwiper: VerticalCardSwiper!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
		// Setup cardSwiper
		
		self.cardSwiper.delegate = self
		self.cardSwiper.datasource = self
		
		self.cardSwiper.verticalCardSwiperView.isPagingEnabled = false
		self.cardSwiper.verticalCardSwiperView.decelerationRate = .normal
		
		self.cardSwiper.register(nib: UINib(nibName: "PhotoCardCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCardCell")
		
		// Display Loading Modal
		
		let loadingView = LoadingView()
			loadingView.show(self.view)
		
		self.view.displayToast("Fetching Photo Library")
		
		// Fetch Photos
		
		self.helper.fetchPhotos { (photos) in
			self.photos = photos
			
			DispatchQueue.main.async {
				self.cardSwiper.reloadData()
				self.cardSwiper.layoutSubviews()
				
				loadingView.hide()
			}
		}
		
		// Fetch Albums
		
		self.helper.fetchAlbums { (albums) in self.albums = albums }
	}
}

extension MainVC: VerticalCardSwiperDelegate, VerticalCardSwiperDatasource {
	func willSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
		switch swipeDirection {
			case .Left:
				self.photos[index].delete()
				self.photos.remove(at: index)
			case .Right:
				self.helper.addProccessedID(self.photos[index].id)
				self.photos.remove(at: index)
			case .None:
				if additionalLogging { print("[INFO] willSwipeCardAway Called. SwipeDirection == .None") }
		}
	}
	
	func didSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
		switch swipeDirection {
			case .Left:
				DispatchQueue.main.async {
					self.cardSwiper.deleteCards(at: [index])
					self.cardSwiper.reloadData()
					self.cardSwiper.layoutSubviews()
				}
			case .Right:
				DispatchQueue.main.async {
					self.cardSwiper.deleteCards(at: [index])
					self.cardSwiper.reloadData()
					self.cardSwiper.layoutSubviews()
				}
			case .None:
				if additionalLogging { print("[INFO] didSwipeCardAway Called. SwipeDirection == .None") }
		}
	}
	
	func didTapCard(verticalCardSwiperView: VerticalCardSwiperView, index: Int) {
		
		// MARK: Scroll To Card
		
		// self.cardSwiper.scrollToCard(at: index, animated: true)
		
		// MARK: Present ActionView
		
		let actionFrame = self.view.frame.inset(by: UIEdgeInsets(top: 55, left: 55, bottom: 55, right: 55))
		let actionView = ActionView(frame: actionFrame, photo: self.photos[index])
		
		
		self.view.addSubview(actionView)
		self.view.bringSubviewToFront(actionView)
		
		/*
		let addToView = AddToView(frame: self.view.frame, photo: self.photos[index])
		
		// Add UIView
		self.view.addSubview(addToView)
		self.view.bringSubviewToFront(addToView)
		*/
		/*
		self.photos[index].fetchImage(forWidth: self.cardSwiper.frame.width) { (image) in
			self.presentFullScreenViewer(image: image)
		}
		*/
	}
	
	private func presentFullScreenViewer(image: UIImage) {
		let image = image.resize(targetSize: CGSize(width: self.view.frame.size.width - 40, height: self.view.frame.size.height - 40))
		let centerPoint = CGPoint(x: (self.view.frame.size.width / 2) - (image.size.width / 2), y: (self.view.frame.size.height / 2) - (image.size.height / 2))
		
		let imageView = UIImageView()
			imageView.frame = CGRect(origin: centerPoint, size: image.size)
			imageView.image = image
			imageView.contentMode = .scaleToFill
		
		let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
			blurView.frame = view.bounds
			blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeViewer(sender:)))
		self.view.addGestureRecognizer(tapGesture)
		
		DispatchQueue.main.async {
			self.view.addSubview(blurView)
			self.view.addSubview(imageView)
		}
	}
	
	@objc func closeViewer(sender: UIGestureRecognizer) {
		print("closeViewer Called.")
		for subview in self.view.subviews {
			if subview is UIVisualEffectView {
				subview.removeFromSuperview()
				print("Blur View Removed")
			}
			else if subview is UIImageView {
				subview.removeFromSuperview()
				print("Image Viewer Removed")
			}
		}
		
		self.view.removeGestureRecognizer(sender)
	}
	
	// MARK: Animate Side Bars
	/*
	func didScroll(verticalCardSwiperView: VerticalCardSwiperView) {
		if let currentIndex = self.cardSwiper.focussedCardIndex {
			if let currentCard = self.cardForItemAt(verticalCardSwiperView: verticalCardSwiperView, cardForItemAt: currentIndex) as? PhotoCardCell {
				let imageFrame = currentCard.imageView.frame
				DispatchQueue.main.async {
					self.deleteSideBar.animateTo(frame: CGRect(x: 0, y: imageFrame.minY, width: 35, height: imageFrame.height), withDuration: 2, completion: nil)
					self.keepSideBar.animateTo(frame: CGRect(x: 379, y: imageFrame.minY, width: 35, height: imageFrame.height), withDuration: 2, completion: nil)
				}
				
			}
		}
		
	}
	*/
	
	func didHoldCard(verticalCardSwiperView: VerticalCardSwiperView, index: Int, state: UIGestureRecognizer.State) {
		let photo = self.photos[index]
		
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let favoriteAction = UIAlertAction(title: "Favorite", style: .default) { (action) in
			photo.setFavorite(true) { (didSet) in
				if (didSet) { print("[SUCCESS] Successfully Favorited Photo.") } else { print("[ERROR] Failed To Favorite Photo.") }
				DispatchQueue.main.async { actionSheet.dismiss(animated: true, completion: nil) }
			}
		}
		
		let unfavoriteAction = UIAlertAction(title: "Unfavorite", style: .default) { (action) in
			photo.setFavorite(false) { (didSet) in
				if (didSet) {
					print("[SUCCESS] Successfully Unfavorited Photo.")
					
				}
				else {
					print("[ERROR] Failed To Unfavorite Photo.")
					
				}
				
				DispatchQueue.main.async { actionSheet.dismiss(animated: true, completion: nil) }
			}
		}
		
		let hideAction = UIAlertAction(title: "Hide", style: .default) { (action) in
			photo.setHide(true) { (didSet) in
				if (didSet) {
					print("[SUCCESS] Successfully Hid Photo.")
					self.photos.remove(at: index)
				}
				else {
					print("[ERROR] Failed To Hid Photo.")
					
				}
				
				DispatchQueue.main.async { actionSheet.dismiss(animated: true, completion: nil) }
			}
		}
		
		let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
			photo.delete()
			
			DispatchQueue.main.async { actionSheet.dismiss(animated: true, completion: nil) }
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
			DispatchQueue.main.async { actionSheet.dismiss(animated: true, completion: nil) }
		}
		
		if photo.isFavorite { actionSheet.addAction(unfavoriteAction) } else { actionSheet.addAction(favoriteAction) }
		
		actionSheet.addAction(hideAction)
		actionSheet.addAction(deleteAction)
		actionSheet.addAction(cancelAction)
		
		DispatchQueue.main.async { self.present(actionSheet, animated: true, completion: nil) }
	}
	
	func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
		// if let assets = self.assets { return assets.count } else { return 0 }
		return self.photos.count
	}
	
	func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
		let cell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "PhotoCardCell", for: index) as! PhotoCardCell
		
		self.photos[index].fetchImage(forWidth: self.cardSwiper.frame.width) { (image) in
			print("[SUCCESS] Successfully Fetched/Set Image.")
			
			let roundedImage = image.cornerRadius(10.0)
			cell.imageView.image = roundedImage
		}
		
		// if photo.isFavorite { cell.favoriteButton.setImage(#imageLiteral(resourceName: "Favorite Button (Filled)"), for: .normal) } else { cell.favoriteButton.setImage(#imageLiteral(resourceName: "Favorite Button (Not Filled)"), for: .normal) }
		// if photo.isHidden { cell.hideButton.setImage(#imageLiteral(resourceName: "Show"), for: .normal) } else { cell.hideButton.setImage(#imageLiteral(resourceName: "Hide Button"), for: .normal) }
		
		return cell
	}
	
	func sizeForItem(verticalCardSwiperView: VerticalCardSwiperView, index: Int) -> CGSize {
		return self.photos[index].asset.scaledSize(forWidth: self.cardSwiper.frame.width)
	}
}
