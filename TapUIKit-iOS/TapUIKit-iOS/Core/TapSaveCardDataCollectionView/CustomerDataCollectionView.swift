//
//  CustomerDataCollectionView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 01/11/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import UIKit

/// Defines the View used to display the fields data collection for customer when saving a card for tap
@objc public class CustomerDataCollectionView: UIView {

    /// The main content view
    @IBOutlet var contentView: UIView!
    /// The view holding the fields collecting the cutomer's contact data
    @IBOutlet weak var customerDataCollectionView: CustomerContactDataCollectionView!
    
    //MARK: - Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Private methods
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        applyTheme()
    }
    
    internal func updateHeight() {
        
    }
    
    
    // MARK: - Public methods
    /**
     Apply the needed setup and attach the passed view model
     - Parameter viewModel: The TapCardPhoneIconViewModel responsible for controlling this icon view
     */
    @objc public func setupView(with viewModel:CustomerContactDataCollectionViewModel) {
        customerDataCollectionView.setupView(with: viewModel)
    }
}



extension CustomerDataCollectionView {
    // Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
        
        updateHeight()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        backgroundColor = .clear
        contentView.backgroundColor = .white
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
