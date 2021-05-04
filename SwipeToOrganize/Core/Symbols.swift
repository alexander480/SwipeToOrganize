//
//  Symbols.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 6/16/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import UIKit

struct Symbols {
    
    var trashSymbol = UIImage(systemName: "trash")!
    
    var emptyHeartSymbol = UIImage(systemName: "suit.heart")!
    var filledHeartSymbol = UIImage(systemName: "suit.heart.fill")!
    
    var hideSymbol = UIImage(systemName: "eye.slash")!
    
    var playSymbol = UIImage(systemName: "play.fill")!
    var pauseSymbol = UIImage(systemName: "pause.fill")!
    
    func configureSymbol(symbol: UIImage, size: CGFloat, weight: UIImage.SymbolWeight, color: UIColor = .black) -> UIImage {
        var newSymbol = symbol
        
        newSymbol = symbol.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: size, weight: weight))!
        newSymbol = newSymbol.withTintColor(color)
        
        return newSymbol
    }
}


