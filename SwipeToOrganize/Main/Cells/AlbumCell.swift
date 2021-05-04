//
//  AlbumCell.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 5/24/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import ALExt

import UIKit

class AlbumCell: UICollectionViewCell {
    
    var shadowView: UIView
    var imageView: UIImageView
    var label: UILabel
    
    var album: Album!
    
    override init(frame: CGRect) {
        // MARK: Create
        // -----------------------------------------
        
        self.shadowView = UIView()
        self.imageView = UIImageView()
        self.label = UILabel()

        // MARK: Initialize
        // -----------------------------------------
        
        super.init(frame: frame)
        
        // MARK: Setup
        // -----------------------------------------
        
        self.shadowView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: frame.size.width, height: frame.size.height))
        self.imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: frame.size.width, height: frame.size.height))
        self.label.frame = CGRect(origin: CGPoint(x: 5, y: 5), size: CGSize(width: frame.size.width - 10, height: frame.size.height - 10))
 
        // MARK: Design
        // -----------------------------------------
        
        self.clipsToBounds = false
        self.layer.cornerRadius = 10
        
        // - shadowView
        self.shadowView.clipsToBounds = false
        self.shadowView.layer.cornerRadius = 10
        self.shadowView.layer.applySketchShadow(color: .black, alpha: 1, x: 0, y: 0, blur: 4, spread: 0)
        
        // - imageView
        self.imageView.clipsToBounds = true
        self.imageView.layer.cornerRadius = 10
        self.imageView.contentMode = .scaleToFill
        // self.imageView.toggleBlur(true)
        
        // - label
        self.label.clipsToBounds = true
        self.label.font = UIFont.systemFont(ofSize: 12.0, weight: .thin)
        self.label.textColor = .black // .white
        self.label.textAlignment = .center
        self.label.numberOfLines = 2
        
        // MARK: Add
        // -----------------------------------------

        self.shadowView.addSubview(self.imageView)
        self.shadowView.addSubview(self.label)
        
        self.addSubview(self.shadowView)
        
        self.bringSubviewToFront(self.label)
    }
    
    func setup(_ album: Album) {
        // Setup UIImageView
        
        // let image = album.thumbnail?.cornerRadius(10) ?? #imageLiteral(resourceName: "Collection Thumbnail").cornerRadius(10)
        // self.imageView.image = image
        
        self.imageView.backgroundColor = .white
        
        // Setup UILabel
        self.label.text = album.name
        
        // Save Album Reference
        self.album = album
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
