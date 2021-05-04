//
//  QueueManager.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 7/14/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

/*
import Foundation
import Photos

class QueueManager<UIImage> {

    var assets: [Asset]
    var queue: [UIImage]
    
    var queueIndex = 0
    
    var queueSize: Int

    public var isEmpty: Bool {
        return queue.isEmpty
    }
    
    init(assets: [Asset], queueSize: Int) {
        self.assets = assets
        
        self.queueSize = queueSize
        
        while queue.count < self.queueSize {
            
        }
        
    }

    public func enqueueImage() {
        let asset = self.assets[queueIndex]
        
        asset.fetchImage(forWidth: nil) { (image) in
            self.queue.append(image)
        }
    }

    public func dequeue() -> PHAsset? {
        guard !list.isEmpty, let element = list.first else { return nil }

        list.remove(element)

        return element.value
    }

    public func peek() -> T? {
        return list.first?.value
    }
}

*/
