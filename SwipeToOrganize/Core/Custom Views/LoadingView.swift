//
//  LoadingView.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 5/6/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import UIKit

public class LoadingView {
    var overlayView : UIView!
    var activityIndicator : UIActivityIndicatorView!

    class var shared: LoadingView {
        struct Static { static let instance: LoadingView = LoadingView() }
        return Static.instance
    }

    init() {
        self.overlayView = UIView()
        self.activityIndicator = UIActivityIndicatorView()

		overlayView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        overlayView.layer.zPosition = 1

		activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
		activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
		activityIndicator.style = .large
        overlayView.addSubview(activityIndicator)
    }

    public func show(_ view: UIView) {
		overlayView.center = view.center
		view.addSubview(overlayView)
        activityIndicator.startAnimating()
    }

    public func hide() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
