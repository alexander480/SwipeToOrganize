//
//  SwipeVC.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 5/12/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

// Listen To didScroll
// Then Call Scroll To Item
// To Scroll w/ Each Cell Snaping To Center

import UIKit

class SwipeVC: UIViewController {
	
	// MARK: Class Variables
	
	var photos = [Photo]()
	var albums = [Album]()
	
	let helper = PHHelper()
	var cardWidth: CGFloat!
	
	// MARK: Outlets
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	// MARK: viewDidLoad
	
	override func viewDidLoad() {

		// Define Card Width
		self.cardWidth = CGFloat((self.collectionView.frame.size.width) - (50 * 2)) // (50 * 2) Represents The Side Section Insets
		
		// viewDidLoad
		super.viewDidLoad()
		
		// Setup UICollectionView
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
		
		self.collectionView.isPagingEnabled = true
		
		// Display LoadingView
		let loadingView = LoadingView()
			loadingView.show(self.view)
		
		self.view.displayToast("Fetching Photos")
		
		// Fetch Photos
		self.helper.fetchPhotos { (photos) in
			self.photos = photos
			
			DispatchQueue.main.async {
				self.collectionView.reloadData()
				loadingView.hide()
			}
		}
	}
}

// MARK: UICollectionView - Delegate

extension SwipeVC: UICollectionViewDelegate {
	
}

// MARK: UICollectionView - FlowLayout

extension SwipeVC: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		// return self.photos[indexPath.row].asset.scaledSize(forWidth: self.cardWidth)
		
		let w = CGFloat((self.collectionView.frame.size.width) - (50 * 2))
		let h = CGFloat(self.collectionView.frame.size.height)
		return CGSize(width: w, height: h)
	}
}

// MARK: UICollectionView - DataSource

extension SwipeVC: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let photo = self.photos[indexPath.row]
		
		let card = collectionView.dequeueReusableCell(withReuseIdentifier: "Card", for: indexPath) as! Card
		
		photo.fetchImage(forWidth: self.cardWidth) { (image) in card.imageView.image = image }
		card.imageView?.contentMode = .center
		card.layer.cornerRadius = 10.0
		
		// card.view.setCornerRadius(10.0)
		// card.imageView.setCornerRadius(10.0)
		
		return card
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.photos.count
	}
}

