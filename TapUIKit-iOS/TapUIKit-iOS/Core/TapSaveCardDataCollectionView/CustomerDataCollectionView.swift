//
//  CustomerDataCollectionView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 01/11/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import UIKit
import SnapKit
import TapThemeManager2020

/// Defines the View used to display the fields data collection for customer when saving a card for tap
@objc public class CustomerDataCollectionView: UIView {

    /// The main content view
    @IBOutlet var contentView: UIView!
    /// The view holding the fields collecting the cutomer's contact data
    @IBOutlet weak var customerDataCollectionView: CustomerContactDataCollectionView!
    /// The view model that controls the customer contact data collection view
    internal var customerContactDataCollectionViewModel:CustomerContactDataCollectionViewModel?
    
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
    
    /// Computes the needed height for the save customer data overall view
    internal func updateHeight() {
        guard let customerContactDataCollectionViewModel = customerContactDataCollectionViewModel else { return }
        // Get the height needed for the contact details view
        let heightForContactDetails:CGFloat = customerContactDataCollectionViewModel.requiredHeight()
        // Get the height needed for the shipping details view
        snp.remakeConstraints { make in
            make.height.equalTo(heightForContactDetails)
        }
        layoutIfNeeded()
    }
    
    
    // MARK: - Public methods
    /**
     Apply the needed setup and attach the passed view model
     - Parameter viewModel: The TapCardPhoneIconViewModel responsible for controlling this icon view
     */
    @objc public func setupView(with viewModel:CustomerContactDataCollectionViewModel) {
        customerDataCollectionView.setupView(with: viewModel)
        customerContactDataCollectionViewModel = viewModel
        updateHeight()
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
        contentView.backgroundColor = .clear
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
