//
//  TapAmountSectionView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/11/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapThemeManager2020

public class TapAmountSectionView: UIView {

    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!

    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.containerView = setupXIB()
        //handlerImageView.translatesAutoresizingMaskIntoConstraints = false
        applyTheme()
    }
}


// Mark:- Theme methods
extension TapAmountSectionView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}

