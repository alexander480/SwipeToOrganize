//
//  LoadingTray.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 5/27/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import ALExt

import UIKit

class LoadingTray: UIView {
    
    // var progress: UIProgressView
    var container: UIView
    var activity: UIActivityIndicatorView
    var label: UILabel
    
    override init(frame: CGRect) {
        
        // MARK: Create
        
        // self.progress = UIProgressView()
        self.container = UIView()
        self.activity = UIActivityIndicatorView()
        self.label = UILabel()
        
        // MARK: Initialize
        
        super.init(frame: frame)
        
        // MARK: Setup
        
        // - LoadingTray
        self.clipsToBounds = false
        
        // - progress
        // let progressSize = CGSize(width: frame.size.width - (30 * 2), height: 3)
        // let progressPoint = CGPoint(x: 30, y: 30)
        // self.progress.frame = CGRect(origin: progressPoint, size: progressSize)
        
        // - container
        let containerSize = CGSize(width: (frame.size.width - (30 * 2)), height: (frame.size.height - (30 * 2)))
        // withprogress - let containerPoint = CGPoint(x: 30, y: (30 + progressSize.height + 30))
        let containerPoint = CGPoint(x: 30, y: 30)
        self.container.frame = CGRect(origin: containerPoint, size: containerSize)
        
        self.container.clipsToBounds = false
        
        // - activity
        let activityPoint = CGPoint(x: 30, y: ((containerSize.height - 30) / 2) )
        let activitySize = CGSize(width: 30, height: 30)
        self.activity.frame = CGRect(origin: activityPoint, size: activitySize)
        
        // - label
        let labelPoint = CGPoint(x: 0, y: 0)
        let labelSize = CGSize(width: containerSize.width, height: containerSize.height)
        self.label.frame = CGRect(origin: labelPoint, size: labelSize)
        
        // MARK: Design
        
        // - mainView
        self.backgroundColor = .white
        
        self.layer.cornerRadius = 10.0
        self.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 0, blur: 6, spread: 0)
        
        // - progress
        
        
        // - container
        self.container.backgroundColor = .white
        
        self.container.layer.cornerRadius = 10.0
        self.container.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 0, blur: 6, spread: 0)
        
        // - activity
        self.activity.style = .medium
        self.activity.color = .black
        
        // - label
        self.label.font = UIFont.systemFont(ofSize: 17.0, weight: .light)
        self.label.textColor = .black
        self.label.textAlignment = .center
        
        // MARK: Add To View
        
        self.container.addSubview(self.activity)
        self.container.addSubview(self.label)
        
        self.addSubview(self.container)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start(text: String = "Loading...") {
        self.label.text = text
        self.activity.startAnimating()
    }
    
    func stop() {
        self.activity.stopAnimating()
        self.removeFromSuperview()
    }
}
