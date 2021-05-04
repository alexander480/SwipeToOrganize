//
//  CardCell.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 5/12/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

// TODO: Setup UILongPressGestureRecognizer For Album Tray
// TODO: Move AlbumTray To SwipeVC

// TODO: Add Play/Pause Button For Videos

import ALExt

import UIKit
import AVFoundation

enum SwipeDirection {
    case left
    case right
}

protocol CardCellDelegate {
    func didSwipeAway(indexPath: IndexPath, direction: SwipeDirection)
    func didAddToAlbum(Photo: Asset, Album: Album)
    func didTap(indexPath: IndexPath)
}

class CardCell: UICollectionViewCell {
    
    // MARK: Class Variables
    
    let assetScale = CGFloat(0.9)
    let shadowOpacity = Float(0.5)
    
    var asset: Asset!
    var indexPath: IndexPath!
    
    var delegate: CardCellDelegate?
    
    let symbolHelper = Symbols()
    
    // MARK: User Interface Variables
    
    var shadowView: UIView
    var imageView: UIImageView
    
    var actionTray: ActionTray!
    var albumTray: AlbumTray?
    
    var player: AVPlayer?
    var roundedPlayerView: UIView?
    var playerLayer: AVPlayerLayer?
    var playerButton: UIButton?
    
    var tapRecognizer: UITapGestureRecognizer!
    var panRecognizer: UIPanGestureRecognizer!
    var holdRecognizer: UILongPressGestureRecognizer!
    
    var isDragEnabled = false
    var isForceTouchAvailable = false
    
    // MARK: Class Override Functions
    
    override init(frame: CGRect) {
        
        // MARK: Create
        // -----------------------------------------
        
        self.shadowView = UIView()
        self.imageView = UIImageView()
        
        // MARK: Initialize
        // -----------------------------------------
        
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        if settings.shouldDisplayBounds {
            let swipeBounds = UIScreen.main.bounds.insetBy(dx: (UIScreen.main.bounds.size.width * 0.2), dy: 0)
            
            let boundsView = UIView(frame: swipeBounds)
                boundsView.backgroundColor = .red
                boundsView.alpha = 0.3
                boundsView.layer.cornerRadius = 10
            
            self.contentView.addSubview(boundsView)
        }
        
        // MARK: Setup
        // -----------------------------------------
        
        self.tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        self.tapRecognizer.delegate = self
        
        self.panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.didPan))
        self.panRecognizer.delegate = self
        
        // Check For Force Touch
        if self.traitCollection.forceTouchCapability == .available {
            self.isForceTouchAvailable = true
        }
        else {
            self.holdRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.didHold))
            self.holdRecognizer?.allowableMovement = 0.0
            self.holdRecognizer?.delegate = self
            
            self.shadowView.addGestureRecognizer(self.holdRecognizer)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        self.playerLayer?.player = nil
    }
    
    // MARK: Setup CardCell Data
    
    public func setup(_ image: UIImage) {
        /*
        var scaledImage = image
        
        if image.size.height > image.size.width {
            let scaledImageSize = CGSize(width: image.size.width * self.assetScale, height: image.size.height * self.assetScale)
            scaledImage = image.resize(targetSize: scaledImageSize)
        }
        
        let point = CGPoint(x: ((self.frame.size.width - scaledImage.size.width) / 2), y: ((self.frame.size.height - scaledImage.size.height) / 2))
        */
        
        let shadowViewSize = CGSize(width: self.contentView.frame.size.width * self.assetScale, height: self.contentView.frame.size.height * self.assetScale)
        let shadowViewPoint = CGPoint(x: ((self.frame.size.width - shadowViewSize.width) / 2), y: ((self.frame.size.height - shadowViewSize.height) / 2))
        
        self.shadowView.frame = CGRect(origin: shadowViewPoint, size: shadowViewSize)
        
        // self.shadowView.frame = CGRect(origin: point, size: scaledImage.size)
        self.shadowView.clipsToBounds = false
        self.shadowView.layer.applySketchShadow(color: .black, alpha: self.shadowOpacity, x: 0, y: 0, blur: 4, spread: 0)
        
        self.shadowView.addGestureRecognizer(self.panRecognizer)
        self.shadowView.addGestureRecognizer(self.tapRecognizer)
        
        self.imageView.frame = self.shadowView.bounds
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.image = image.cornerRadius(12)!
        
        // self.imageView.image = scaledImage
        
        self.shadowView.addSubview(imageView)
        self.contentView.addSubview(shadowView)
    }
    
    public func setup(_ playerItem: AVPlayerItem) {
        
        // MARK: Create
        
        self.player = AVPlayer(playerItem: playerItem)
        // self.roundedPlayerView = UIView()
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerButton = UIButton()
        
        // MARK: Setup
        
        // - shadowView
        
        let shadowViewSize = CGSize(width: self.contentView.frame.size.width * self.assetScale, height: self.contentView.frame.size.height * self.assetScale)
        let shadowViewPoint = CGPoint(x: ((self.frame.size.width - shadowViewSize.width) / 2), y: ((self.frame.size.height - shadowViewSize.height) / 2))
        
        self.shadowView.frame = CGRect(origin: shadowViewPoint, size: shadowViewSize)
        self.shadowView.layer.applySketchShadow(color: .black, alpha: self.shadowOpacity, x: 0, y: 0, blur: 4, spread: 0)
        self.shadowView.clipsToBounds = true
        
        self.shadowView.layer.cornerRadius = 10
        self.shadowView.addGestureRecognizer(self.panRecognizer)
        
        self.tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        self.shadowView.addGestureRecognizer(self.tapRecognizer)
        
        // - player
        
        self.player?.actionAtItemEnd = .pause
        
        // - roundedPlayerView
        
        // self.roundedPlayerView?.frame = self.shadowView.frame
        // self.roundedPlayerView?.clipsToBounds = true
        // self.roundedPlayerView?.layer.masksToBounds = true
        // self.roundedPlayerView?.layer.cornerRadius = 12
        
        // - playerLayer
        
        self.playerLayer?.frame = self.shadowView.bounds
        self.playerLayer?.videoGravity = .resizeAspectFill
        //self.playerLayer?.setCornerRadiusUsingPath(12)
        
        self.playerLayer?.masksToBounds = true
        self.playerLayer?.cornerRadius = 12
        
        // playerDidFinish Observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinish(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        
        // - playerButton
        
        let playerButtonSize = CGSize(width: 60, height: 60)
        let playerButtonPoint = CGPoint(x: (shadowViewSize.width - playerButtonSize.width) / 2, y: (shadowViewSize.height - playerButtonSize.height) / 2)
        
        self.playerButton?.frame = CGRect(origin: playerButtonPoint, size: playerButtonSize)
        self.playerButton?.setImage(self.symbolHelper.playSymbol, for: .normal)
        self.playerButton?.addBlur(style: UIBlurEffect.Style.dark)
        self.playerButton?.addBorder(color: .white, width: 3.0)
        self.playerButton?.setCornerRadius(playerButtonSize.width / 2)
        self.playerButton?.tintColor = .white
        self.playerButton?.clipsToBounds = true
        
        // playerButton Action
        self.playerButton?.addTarget(self, action: #selector(playerButtonAction), for: .touchUpInside)
        
        // MARK: Add
        
        self.contentView.addSubview(self.shadowView)
        
        self.shadowView.layer.addSublayer(self.playerLayer!)
        
        self.shadowView.addSubview(self.playerButton!)
        self.shadowView.bringSubviewToFront(self.playerButton!)
        
        /*
        self.shadowView.addSubview(self.roundedPlayerView!)
        
        self.roundedPlayerView?.layer.addSublayer(self.playerLayer!)
        
        self.roundedPlayerView?.addSubview(self.playerButton!)
        self.roundedPlayerView?.bringSubviewToFront(self.playerButton!)
        */
    }
    
    @objc private func playerButtonAction(sender: UIButton!) {
        guard let player = self.player else { print("[ERROR] Unable To Validate AVPlayer."); return }
        
        if player.isPlaying {
            self.playerButton?.isHidden = false
            player.pause()
        }
        else {
            self.playerButton?.isHidden = true
            player.play()
        }
    }
    
    @objc private func playerDidFinish(note: NSNotification) {
        self.playerButton?.isHidden = false
        self.player?.seek(to: CMTime.zero)
    }

    // MARK: Handle UITouch Events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isForceTouchAvailable { for touch in touches { if touch.force > 4.5 { self.showAlbumTray() } } }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isDragEnabled { self.dismissAlbumTray() }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: User Interface Handler Functions

extension CardCell {
    private func handleSwipe(direction: SwipeDirection) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                if direction == .left {
                    self.shadowView.center = CGPoint(x: self.center.x + (self.frame.width * -1), y: self.shadowView.center.y)
                }
                else if direction == .right {
                    self.shadowView.center = CGPoint(x: self.center.x + (self.frame.width * 1), y: self.shadowView.center.y)
                }
                
                print("[SWIPE] didSwipeAway. Direction \(direction)")
                self.delegate?.didSwipeAway(indexPath: self.indexPath, direction: direction)
            })
        }
    }
    
    private func resetCardPosition() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                self.shadowView.center = self.contentView.center
            })
        }
    }
    
    private func showAlbumTray() {
        
        // Remove Any Other AlbumTrays
        
        for subview in self.subviews {
            if subview is AlbumTray {
                subview.removeFromSuperview()
            }
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                self.shadowView.alpha = 0.5
                self.shadowView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            })
        }
        
        self.isDragEnabled = true
        
        let cellHeight = ((frame.size.width - (4 * 20)) / 3)
        let trayHeight = (cellHeight * 4) + (20 * 3)
        
        let traySize = CGSize(width: ((self.frame.size.width) - (20 * 2)), height: trayHeight)
        let trayPoint = CGPoint(x: 20, y: self.frame.size.height - trayHeight /*(self.frame.size.height / 2)*/)
        
        let albumTray = AlbumTray(frame: CGRect(origin: trayPoint, size: traySize))
        
        self.albumTray = albumTray
        
        DispatchQueue.main.async {
            self.addSubview(albumTray)
            self.sendSubviewToBack(albumTray)
        }
    }
    
    private func dismissAlbumTray() {
        self.isDragEnabled = false
        
        self.shouldAddToAlbum { (shouldAdd, album) in
            if let photoAlbum = album {
                photoAlbum.add(self.asset) { (didAdd) in
                    print("[SUCCESS] Successfully Added Photo To Album Named: \(photoAlbum.name)")
                    
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.25, animations: {
                            self.shadowView.alpha = 1.0
                            self.shadowView.transform = CGAffineTransform(scaleX: 1, y: 1)
                            self.shadowView.center = self.contentView.center
                        })
                        
                        if let albumTray = self.albumTray { albumTray.removeFromSuperview() }
                    }
                    
                    self.delegate?.didAddToAlbum(Photo: self.asset, Album: photoAlbum)
                }
            }
            else {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.shadowView.alpha = 1.0
                        self.shadowView.transform = CGAffineTransform(scaleX: 1, y: 1)
                        self.shadowView.center = self.contentView.center
                    })
                    
                    if let albumTray = self.albumTray { albumTray.removeFromSuperview() }
                }
            }
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension CardCell: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.panRecognizer {
            let recognizer = gestureRecognizer as! UIPanGestureRecognizer
            let translation = recognizer.translation(in: self)
            
            if self.isDragEnabled { return true }
            else if abs(translation.y) > abs(translation.x) { return false }
            else { return true }
        }
        /*
        else if gestureRecognizer == self.tapRecognizer {
            if self.player.isPlaying { return false }
            else { return true }
        }
        */
        else {
            return true
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

// MARK: UIGestureRecognizer Handler Functions

extension CardCell {
    
    @objc func didTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if let player = self.player {
            if player.isPlaying {
                player.pause()
                self.playerButton?.isHidden = false
            }
            else {
                self.delegate?.didTap(indexPath: self.indexPath)
            }
        }
        else {
            self.delegate?.didTap(indexPath: self.indexPath)
        }
    }
    
    @objc func didHold(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if self.isDragEnabled == false {
            self.showAlbumTray()
        }
    }
    
    @objc func didPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if self.isDragEnabled {
            let translationPoint = gestureRecognizer.translation(in: self)
            DispatchQueue.main.async {
                self.shadowView.center = CGPoint(x: self.contentView.center.x + translationPoint.x, y: self.contentView.center.y + translationPoint.y)
            }
            
            if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled { self.dismissAlbumTray() }
        }
        else {
            self.shouldSwipeAway(gestureRecognizer: gestureRecognizer) { (shouldSwipe, swipeDirection) in
                if let direction = swipeDirection {
                    self.handleSwipe(direction: direction)
                }
                else {
                    self.resetCardPosition()
                }
            }
        }
    }
}

// MARK: Functions To Check CardCell Bounds (Used To Detect Card Swipes & Check For Overlapping AlbumCells)

extension CardCell {
    private func shouldSwipeAway(gestureRecognizer: UIPanGestureRecognizer, completion: @escaping (Bool, SwipeDirection?) -> ()) {
        let swipeBounds = UIScreen.main.bounds.insetBy(dx: (UIScreen.main.bounds.size.width * 0.2), dy: 0)
        
        if let shadowView = gestureRecognizer.view {
            let translationPoint = gestureRecognizer.translation(in: self)
            
            DispatchQueue.main.async { self.shadowView.center = CGPoint(x: self.center.x + translationPoint.x, y: shadowView.center.y) }
            
            if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
                let isInBounds = swipeBounds.contains(shadowView.center)
                let isOnLeft = shadowView.center.x <= swipeBounds.minX
                let isOnRight = shadowView.center.x >= swipeBounds.maxX
                
                if !isInBounds && isOnLeft { completion(true, .left) }
                else if !isInBounds && isOnRight { completion(true, .right) }
                else { completion(false, nil) }
            }
        }
    }
    
    private func shouldAddToAlbum(completion: @escaping (Bool, Album?) -> ()) {
        if let albumTray = self.albumTray {
            // let cardCenter = self.convert(self.shadowView.center, to: albumTray)
            
            let touchCenter = self.panRecognizer.location(in: albumTray)
            
            for cellIndex in albumTray.collectionView.indexPathsForVisibleItems {
                if let cellFrame = albumTray.collectionView.collectionViewLayout.layoutAttributesForItem(at: cellIndex)?.frame {
                    if cellFrame.contains(touchCenter /* cardCenter */) {
                        let cell = albumTray.collectionView.cellForItem(at: cellIndex) as! AlbumCell
                        
                        completion(true, cell.album)
                    }
                    else {
                        completion(false, nil)
                    }
                }
            }
        }
    }
}

extension CALayer {
    func setCornerRadiusUsingPath(_ radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius)
        
        let mask = CAShapeLayer()
            mask.path = path.cgPath
        
        self.mask = mask
    }
}
