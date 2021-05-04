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

import ALExt

import UIKit
import Photos

let settings = Settings(limitPhotos: false, displayProgress: false, displayBounds: false, allowDarkMode: false, extraVerbose: false)

class SwipeVC: UIViewController {
	
	// MARK: Class Variables
    
    let cardWidth = CGFloat(UIScreen.main.bounds.size.width - (50)) // (50) Represents The Side Section Insets
    let helper = PhotosHelper()
    
    var assets = [Asset]()

	// MARK: Outlets
	
	@IBOutlet weak var collectionView: UICollectionView!
    var loadingTray: LoadingTray!
    var actionTray: ActionTray!
	
	// MARK: viewDidLoad
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        // Setup Accessory Views
        self.setupLoadingView()
        self.actionTray = ActionTray(frame: self.view.frame)
        
        // Fetch Assets
        self.helper.fetchAssets { (assets) in
            self.assets = assets
            
            DispatchQueue.main.async {
                self.loadingTray.stop()
                self.setupCollectionView()
            }
        }
        
        // Register For Photo Library Changes
        // PHPhotoLibrary.shared().register(self)
	}
    
    private func setupLoadingView() {
        let loadingSize = CGSize(width: (self.view.frame.size.width - (20 * 2)), height: 140)
        let loadingPoint = CGPoint(x: 20, y: self.view.frame.size.height - loadingSize.height)
        self.loadingTray = LoadingTray(frame: CGRect(origin: loadingPoint, size: loadingSize))
        
        DispatchQueue.main.async {
            self.view.addSubview(self.loadingTray)
            self.loadingTray.start(text: "Loading Assets...")
        }
    }
    
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.prefetchDataSource = self
        
        self.collectionView.isPrefetchingEnabled = true
        self.collectionView.isDirectionalLockEnabled = true
        self.collectionView.isPagingEnabled = true
        
        self.collectionView.decelerationRate = .fast
        
        // Register Custom UICollectionViewCell
        self.collectionView.register(CardCell.self, forCellWithReuseIdentifier: "CardCell")
    }
    
    private func openPhotosApp() {
        UIApplication.shared.open(URL(string:"photos-redirect://")!)
    }
}

extension SwipeVC: CardCellDelegate {
    
    // CardCellDelegate Protocol Functions
    // -----------------------------------------
    
    func didTap(indexPath: IndexPath) { self.toggleActionTray() }
    
    func didSwipeAway(indexPath: IndexPath, direction: SwipeDirection) {
        if direction == .left { self.deleteAsset(indexPath: indexPath) }
        else if direction == .right { self.organizeAsset(indexPath: indexPath) }
    }
    
    func didAddToAlbum(Photo: Asset, Album: Album) { self.presentAddedToAlbumAlert(albumName: Album.name) }
    
    // CardCellDelegate Helper Functions
    // -----------------------------------------
    
    private func toggleActionTray() {
        if self.view.subviews.contains(self.actionTray) {
            self.actionTray.removeFromSuperview()
        }
        else {
            self.view.addSubview(self.actionTray)
        }
    }
    
    private func deleteAsset(indexPath: IndexPath) {
        let assetToDelete = self.assets[indexPath.row]
        
        assetToDelete.delete { (didDelete) in
            if (didDelete) {
                DispatchQueue.main.async {
                    self.view.displayToast("Deleted")
                    
                    self.assets.remove(at: indexPath.row)
                    self.collectionView.deleteItems(at: [indexPath])
                    
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func organizeAsset(indexPath: IndexPath) {
        let assetToOrganize = self.assets[indexPath.row]
        
        self.helper.organizedAlbum.add(assetToOrganize) { (didAdd) in
            if (didAdd) {
                DispatchQueue.main.async {
                    self.view.displayToast("Saved To Organized Album")
                    
                    self.assets.remove(at: indexPath.row)
                    self.collectionView.deleteItems(at: [indexPath])
                    
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func presentAddedToAlbumAlert(albumName: String) {
        DispatchQueue.main.async {
            self.presentAlert(Title: "Successfully Added Photo To Album", Message: "This photo has been added to a photo album named \(albumName)", Actions: nil)
        }
    }
}

// MARK: UICollectionView Protocols

extension SwipeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionView.frame.size
    }
}

extension SwipeVC: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let card = self.collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
        let cellAsset = self.assets[indexPath.row]
        
        card.asset = cellAsset
        card.indexPath = indexPath
        
        switch cellAsset.assetType {
            case .image:
                cellAsset.fetchImage(forWidth: self.cardWidth) { (image) in
                    DispatchQueue.main.async {
                        card.setup(image)
                    }
                }
            case .video:
                cellAsset.fetchVideo { (playerItem) in
                    if let item = playerItem {
                        DispatchQueue.main.async {
                            card.setup(item)
                        }
                    }
                }
            default:
                print("[ERROR] Unknown Asset Type. Cannot Setup Cell.")
        }
        
        card.delegate = self
        
        return card
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.helper.stopCaching(assets: [self.assets[indexPath.row]])
        cell.removeGestureRecognizers()
    }
}

extension SwipeVC: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        print("[PREFETCH] prefetchItemsAt Called. indexPaths: \(indexPaths.description).")
        
        DispatchQueue.global(qos: .utility).async {
            let rows = indexPaths.map { $0.row }
            
            if let maxIndex = rows.max() {
                
                if maxIndex == 1 {
                    let minRange = 0
                    let maxRange = 10
                    
                    if self.assets.count >= 10 {
                        print("[PREFETCH] Now Prefetching Assets \(minRange) Through \(maxRange).")
                        
                        let assetsToPrefetch = Array(self.assets[minRange...maxRange])
                        self.helper.startCaching(assets: assetsToPrefetch)
                    }
                }
                else if (maxIndex >= 10) && (maxIndex % 10 == 0) {
                    
                    let assetsToStopCaching = Array(self.assets[(maxIndex - 10)...(maxIndex)])
                    self.helper.stopCaching(assets: assetsToStopCaching)
                    
                    let minRange = maxIndex
                    let maxRange = maxIndex + 10
                    
                    if self.assets.count >= maxRange {
                        print("[PREFETCH] Now Prefetching Assets \(minRange) Through \(maxRange).")
                        
                        let assetsToPrefetch = Array(self.assets[minRange...maxRange])
                        self.helper.startCaching(assets: assetsToPrefetch)
                    }
                }
            }
        }
    }
}

// MARK: PHPhotoLibraryChangeObserver
/*
extension SwipeVC: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let assetFetchResult = self.helper.assetFetchResult {
            if let changeDetails = changeInstance.changeDetails(for: assetFetchResult) {
                print("[INFO] Changes Observed. [DETAILS] \(String(describing: changeDetails))")
                self.fetchAssets()
            }
        }
        else { if settings.extraVerbose { print("[ERROR] Unable to Validate PhotosHelper.assetFetchResult.") } }
    }
}
*/
