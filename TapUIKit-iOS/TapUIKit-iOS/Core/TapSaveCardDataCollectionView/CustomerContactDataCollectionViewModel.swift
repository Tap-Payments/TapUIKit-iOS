//
//  CustomerContactDataCollectionViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 03/11/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import Foundation
import UIKit
import CommonDataModelsKit_iOS

/// The view model that controls the customer contact data collection view
@objc public class CustomerContactDataCollectionViewModel:NSObject {
    
    // MARK: Internal variables
    
    /// Reference tot he View used to display the fields data collection for customer when saving a card for tap to be rendered
    internal var customerContactDataCollectionView:CustomerContactDataCollectionView?
    /// Defines which fields should be collected. Accepted format: .email, .phone
    internal var toBeCollectedData:[SaveCardCustomerDataSFieldEnum]
    /// The list of countries the user can select from
    internal var allowedCountries:[TapCountry]
    /// The default country to select on load
    internal var selectedCountry:TapCountry
    
    // MARK: Public variables
    
    /// Public Reference tothe View used to display the fields data collection for customer when saving a card for tap to be rendered
    @objc public var attachedView:CustomerContactDataCollectionView {
        return customerContactDataCollectionView ?? .init()
    }
    
    
    // MARK: Public functions
    /// Creates the view model that controls the customer contact data collection view
    /// - Parameter toBeCollectedData: Defines which fields should be collected. Accepted format: .email, .phone
    /// - Parameter allowedCountries: The list of countries the user can select from
    /// - Parameter selectedCountry: The default country to select on load
    public init(toBeCollectedData:[SaveCardCustomerDataSFieldEnum], allowedCountries:[TapCountry], selectedCountry:TapCountry) {
        self.toBeCollectedData = toBeCollectedData
        self.allowedCountries = allowedCountries
        self.selectedCountry = selectedCountry
        super.init()
        defer{
            reloadData()
        }
    }
    
    
    // MARK: Internal functions
    /// Reloads and redraws the uiview based on the provided data
    internal func reloadData() {
        // Set the view model
        //customerContactDataCollectionView = .init()
        //customerContactDataCollectionView?.viewModel = self
        
        // update the visbilities of the text fields
        customerContactDataCollectionView?.showHideViews()
        // Adjust the height of the view
        customerContactDataCollectionView?.updateHeight()
    }
    
    /// Defines what is the height required by this view to show its elements fully
    internal func requiredHeight() -> CGFloat {
        // Calculate the needed height of the the text fields
        return 48.0 * CGFloat(toBeCollectedData.count)
    }
}
