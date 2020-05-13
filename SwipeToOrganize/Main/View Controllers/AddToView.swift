//
//  AddToView.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 5/9/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import UIKit

class AddToView: UIView {
	
	var photo: Photo
	var tableView: UITableView!
	
	let helper = PHHelper()
	var albums = [Album]()
	
	init(frame: CGRect, photo: Photo) {
		// MARK: Set Class Variables
		
		self.photo = photo
		
		// MARK: Initialize AddToView

		super.init(frame: frame)
		self.setupGestureRecognizer()
		
		// MARK: Create Subviews
		
		// - contentView
		let contentSize = CGSize(width: frame.size.width - 80, height: frame.size.height / 2) // Width: 40px Margins On Each Side. // Height: 1/2 of Display.
		let contentPoint = CGPoint(x: (self.frame.size.width - contentSize.width) / 2, y: (self.frame.size.height - contentSize.height) / 2)
		
		let contentView = UIView(frame: CGRect(origin: contentPoint, size: contentSize))
		
		// - tableView
		self.tableView = UITableView(frame: CGRect(origin: .zero, size: contentSize))
		
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
		// MARK: Set Design Properties
		
		// - AddToView
		self.toggleBlur(true, style: .prominent)
		self.backgroundColor = .clear
		
		// - contentView
		contentView.layer.cornerRadius = 10
		
		// - tableView
		self.tableView.layer.cornerRadius = 10
		
		// MARK: Add Subviews
		
		contentView.addSubview(self.tableView)
		self.addSubview(contentView)
		
		// MARK: Add Loading View
		let loadingView = LoadingView()
			loadingView.show(self)
		
		// MARK: Fetch Data

		// - Fetch Albums
		self.helper.fetchAlbums { (albums) in
			self.albums = albums
			DispatchQueue.main.async {
				self.tableView.reloadData()
				loadingView.hide()
			}
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func dismiss() {
		if let recognizers = self.gestureRecognizers {
			// Remove Gesture Recognizers
			for recognizer in recognizers { self.removeGestureRecognizer(recognizer) }
			
			// Dismiss
			self.removeFromSuperview()
		}
		else {
			// Dismiss
			self.removeFromSuperview()
		}
	}
	
	private func setupGestureRecognizer() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(close(sender:)))
		self.addGestureRecognizer(tapGesture)
	}
	
	@objc func close(sender: UIGestureRecognizer) { DispatchQueue.main.async { self.dismiss() } }
}

extension AddToView: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedAlbum = self.albums[indexPath.row]
		selectedAlbum.add(self.photo) { (didAdd) in
			DispatchQueue.main.async {
				self.dismiss()
			}
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
		
		let cell = UITableViewCell(style: .default, reuseIdentifier: "AlbumCell")
			cell.textLabel?.text = self.albums[row].name
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 55.0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.albums.count
	}
}
