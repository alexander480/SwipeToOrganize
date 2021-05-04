//
//  Settings.swift
//  SwipeToOrganize
//
//  Created by Alexander Lester on 5/25/20.
//  Copyright © 2020 Alexander Lester. All rights reserved.
//

import Foundation


struct Settings {
    var shouldLimitPhotos: Bool
    var shouldDisplayProgress: Bool
    var shouldDisplayBounds: Bool
    var allowDarkMode: Bool
    var extraVerbose: Bool
    
    init(limitPhotos: Bool, displayProgress: Bool, displayBounds: Bool, allowDarkMode: Bool, extraVerbose: Bool) {
        self.shouldLimitPhotos = limitPhotos
        self.shouldDisplayProgress = displayProgress
        self.shouldDisplayBounds = displayBounds
        self.allowDarkMode = allowDarkMode
        self.extraVerbose = extraVerbose
    }
}
