//
//  AlbumTray.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 5/24/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import ALExt

import UIKit

class AlbumTray: UIView {
    
    // MARK: Class Variables
    
    let helper = PhotosHelper()
    var albums = [Album]()
    
    // MARK: User Interface
    
    var shadowView: UIView
    var collectionView: UICollectionView
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        
        // MARK: Create
        // -----------------------------------------
        
        let shadowFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: frame.size.width, height: frame.size.height))
        self.shadowView = UIView(frame: shadowFrame)
        
        let widthSize = ((frame.size.width - (4 * 20)) / 3)
        // let heightSize = ((frame.size.height - (4 * 20)) / 3)
        
        let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            layout.estimatedItemSize = CGSize(width: widthSize, height: widthSize /* heightSize */)
            layout.minimumLineSpacing = 20
        
        let collectionFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: frame.size.width, height: frame.size.height))
        self.collectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: layout)
        // self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // MARK: Initialize
        // -----------------------------------------
        super.init(frame: frame)
        
        // MARK: Setup
        // -----------------------------------------
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.helper.fetchAlbums { (albums) in
            self.albums = albums
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        self.collectionView.register(AlbumCell.self, forCellWithReuseIdentifier: "AlbumCell")
        
        // MARK: Design
        // -----------------------------------------
        self.shadowView.setCornerRadius(10)
        self.shadowView.layer.applySketchShadow(color: .black, alpha: 1.0, x: 0, y: 0, blur: 5, spread: 0)
        
        self.collectionView.setCornerRadius(10)
        self.collectionView.backgroundColor = .white
        
        // MARK: Add
        // -----------------------------------------
        
        self.shadowView.addSubview(self.collectionView)
        self.addSubview(self.shadowView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UICollectionView Delegate & DataSource

extension AlbumTray: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCell
            cell.setup(self.albums[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.albums.count
    }
}
