//
//  ActionTray.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 6/2/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

// MARK: TODO: Connect This To Card Cell

import ALExt

import UIKit

protocol ActionTrayDelegate {
    func didPressFavorite()
    func didPressHide()
    func didPressDelete()
}

class ActionTray: UIView {
    
    var topView: UIView
    var topLabel: UILabel
    
    var bottomView: UIView
    var deleteButton: UIButton
    var favoriteButton: UIButton
    var hideButton: UIButton
    // var addToButton: UIButton
    
    var tapRecognizer: UITapGestureRecognizer!
	
	var delegate: ActionTrayDelegate?
    
    let symbols = Symbols()
    var asset: Asset? {
        didSet {
            // check to see if the asset is in favorites and if its hidden
            if let asset = asset {
                let favoriteSymbol = symbols.configureSymbol(symbol: asset.isFavorite ? symbols.filledHeartSymbol : symbols.emptyHeartSymbol, size: 26, weight: .medium, color: .red)
                self.favoriteButton.setImage(favoriteSymbol, for: .normal)
            }
        }
    }
    
    
    override init(frame: CGRect) {
        
        // MARK: Create
        
        self.topView = UIView()
        self.topLabel = UILabel()
        
        self.bottomView = UIView()
        self.deleteButton = UIButton()
        self.favoriteButton = UIButton()
        self.hideButton = UIButton()
        
        // self.addToButton = UIButton()
        
        super.init(frame: frame)
        
        // MARK: Setup
        
        // - topView
        let topViewPoint = CGPoint(x: 20, y: 0)
        let topViewSize = CGSize(width: self.frame.size.width - 40, height: 125)
        self.topView.frame = CGRect(origin: topViewPoint, size: topViewSize)
        
        // - topLabel
        let topLabelPoint = CGPoint(x: 0, y: 20)
        self.topLabel.frame = CGRect(origin: topLabelPoint, size: topViewSize)
        
        // - bottomView
        let bottomViewPoint = CGPoint(x: 20, y: (self.frame.size.height - 160))
        let bottomViewSize = CGSize(width: self.frame.size.width - 40, height: 160)
        self.bottomView.frame = CGRect(origin: bottomViewPoint, size: bottomViewSize)
        
        let spacingWidth: CGFloat = 35
        
        let buttonWidth = (bottomViewSize.width - (spacingWidth * 4)) / 3
        
        // - deleteButton
        let deleteButtonPoint = CGPoint(x: 35, y: 35)
        let deleteButtonSize = CGSize(width: buttonWidth, height: buttonWidth)
        self.deleteButton.frame = CGRect(origin: deleteButtonPoint, size: deleteButtonSize)
        
        // - favoriteButton
        let favoriteButtonPoint = CGPoint(x: (spacingWidth * 2) + buttonWidth, y: 35)
        let favoriteButtonSize = CGSize(width: buttonWidth, height: buttonWidth)
        self.favoriteButton.frame = CGRect(origin: favoriteButtonPoint, size: favoriteButtonSize)
        
        // - hideButton
        let hideButtonPoint = CGPoint(x: (spacingWidth * 3) + (buttonWidth * 2), y: 35)
        let hideButtonSize = CGSize(width: buttonWidth, height: buttonWidth)
        self.hideButton.frame = CGRect(origin: hideButtonPoint, size: hideButtonSize)
        
        // - addToButton
        
        // - UITapGestureRecognizer
        
        self.tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        
        // MARK: Design
        
        // - topView
        
        self.topView.backgroundColor = .white
        
        self.topView.layer.cornerRadius = 10
        self.topView.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 0, blur: 6, spread: 0)
        
        // - topLabel
        
        self.topLabel.font = UIFont(name: "Avenir Next Ultra Thin", size: 64)
        self.topLabel.textColor = .black
        self.topLabel.textAlignment = .center
        
        self.topLabel.text = "134 / 20234"
        
        // - bottomView

        self.bottomView.backgroundColor = .white
        
        self.bottomView.layer.cornerRadius = 10
        self.bottomView.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 0, blur: 6, spread: 0)
        
        // - deleteButton
        
        self.deleteButton.backgroundColor = .white
        self.deleteButton.tintColor = .black
        
        self.deleteButton.layer.cornerRadius = 10
        self.deleteButton.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 0, blur: 6, spread: 0)
        
        let deleteSymbol = symbols.configureSymbol(symbol: symbols.trashSymbol, size: 26, weight: .medium, color: .black)
        self.deleteButton.setImage(deleteSymbol, for: .normal)
        
        self.deleteButton.addTarget(self, action: #selector(self.didTapDeleteButton), for: .touchDragInside)
        
        // - favoriteButton
        
        self.favoriteButton.backgroundColor = .white
        self.favoriteButton.tintColor = .black
        
        self.favoriteButton.layer.cornerRadius = 10
        self.favoriteButton.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 0, blur: 6, spread: 0)
        
        let favoriteSymbol = symbols.configureSymbol(symbol: symbols.emptyHeartSymbol, size: 26, weight: .medium, color: .red)
        self.favoriteButton.setImage(favoriteSymbol, for: .normal)
        
        self.favoriteButton.addTarget(self, action: #selector(self.didTapFavoriteButton), for: .touchDragInside)
        
        // - hideButton

        self.hideButton.backgroundColor = .white
        self.hideButton.tintColor = .black
        
        self.hideButton.layer.cornerRadius = 10
        self.hideButton.layer.applySketchShadow(color: .black, alpha: 0.5, x: 0, y: 0, blur: 6, spread: 0)
        
        let hideSymbol = symbols.configureSymbol(symbol: symbols.hideSymbol, size: 26, weight: .medium, color: .black)
        self.hideButton.setImage(hideSymbol, for: .normal)
        
        self.hideButton.addTarget(self, action: #selector(self.didTapHideButton), for: .touchDragInside)
        
        // - addToButton
        
        // MARK: Add To View
        
        self.topView.addSubview(self.topLabel)
        
        self.bottomView.addSubview(self.deleteButton)
        self.bottomView.addSubview(self.favoriteButton)
        self.bottomView.addSubview(self.hideButton)
        
        self.addSubview(self.topView)
        self.addSubview(self.bottomView)
        
        self.addGestureRecognizer(self.tapRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil
        }
        return hitView
    }
    
    @objc func didTapDeleteButton(sender: UIButton!) {
		self.delegate?.didPressDelete()
    }
    
    @objc func didTapFavoriteButton(sender: UIButton!) {
		self.delegate?.didPressFavorite()
    }
    
    @objc func didTapHideButton(sender: UIButton!) {
		self.delegate?.didPressHide()
    }
    
    @objc func didTap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.removeFromSuperview()
    }
}
