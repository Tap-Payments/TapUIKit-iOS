//
//  TapLoyaltyView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 13/09/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import UIKit
import TapThemeManager2020

/// A view represents the loyalty points view used while paying
@objc public class TapLoyaltyView: UIView {

    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!
    
    /// The actual container view that holds everything from the XIB
    @IBOutlet var cardView: UIView!
        
    /// The path to look for theme entry in
    private let themePath = "loyaltyView"
    
    // MARK: Init methods
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
        translatesAutoresizingMaskIntoConstraints = false
        //handlerImageView.translatesAutoresizingMaskIntoConstraints = false
        applyTheme()
    }
    
    
    // MARK: Private
    internal func loadLabels() {
        
    }
    
    internal func loadImages() {
        
    }
    
    // MARK: Public
    
    @objc public var viewModel:TapLoyaltyViewModel? {
        didSet{
            refresh()
        }
    }
    
    /// Updates the view with the new view model
    public func changeViewModel(with viewModel:TapLoyaltyViewModel) {
        self.viewModel = viewModel
    }
    
    /// Call to refresh the UI if any data changed
    @objc public func refresh() {
        loadLabels()
        loadImages()
    }
}



// Mark:- Theme methods
extension TapLoyaltyView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        backgroundColor = .clear
        containerView.backgroundColor = .clear
        cardView.layer.tap_theme_cornerRadious = .init(keyPath: "\(themePath).cardView.radius")
        cardView.layer.tap_theme_shadowColor = .init(keyPath: "\(themePath).cardView.shadowColor")
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cardView.layer.tap_theme_shadowRadius = .init(keyPath: "\(themePath).cardView.shadowRadius")
        cardView.layer.shadowOpacity =
        TapThemeManager.numberValue(for: "\(themePath).cardView.shadowRadius")?.floatValue ?? 0
        cardView.tap_theme_backgroundColor = .init(keyPath: "\(themePath).cardView.backgroundColor")
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
