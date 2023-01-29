//
//  CustomerShippingDataCollectionViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 28/01/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import Foundation

import UIKit
import CommonDataModelsKit_iOS
import TapThemeManager2020
import LocalisationManagerKit_iOS

/// The view model that controls the customer shipping data collection view
@objc public class CustomerShippingDataCollectionViewModel:NSObject {
    
    // MARK: Internal variables
    
    /// Reference tot he View used to display the fields data collection for customer when saving a card for tap to be rendered
    internal var customerShippingDataCollectionView:CustomerShippingDataCollectionView?
    /// The list of countries the user can select from
    internal var allowedCountries:[TapCountry]
    /// The default country to select on load
    internal var selectedCountry:TapCountry?
    /// The theme configuration for the country picker table view
    internal var configMaker = Config(
        countryNameTextColor: TapThemeManager.colorValue(for: "customerDataCollection.countryPicker.countryCell.titleLabelColor")!,
        countryNameTextFont: TapThemeManager.fontValue(for: "customerDataCollection.countryPicker.countryCell.titleLabelFont")!,
        selectedCountryCodeBackgroundColor: .green,
        closeButtonText: TapLocalisationManager.shared.localisedValue(for: "Common.cancel", with: TapCommonConstants.pathForDefaultLocalisation()),
        titleTextColor: TapThemeManager.colorValue(for: "customerDataCollection.countryPicker.countryTable.titleColor")!,
        titleFont: TapThemeManager.fontValue(for: "customerDataCollection.countryPicker.countryTable.titleFont")!,
        titleText: TapLocalisationManager.shared.localisedValue(for: "HorizontalHeaders.SaveCardHeader.contactCountryPickerHeader", with: TapCommonConstants.pathForDefaultLocalisation()),
        separatorColor: TapThemeManager.colorValue(for: "tapSeparationLine.backgroundColor")!
    )
    // MARK: Public variables
    
    /// Public Reference tothe View used to display the fields data collection for customer when saving a card for tap to be rendered
    @objc public var attachedView:CustomerShippingDataCollectionView {
        return customerShippingDataCollectionView ?? .init()
    }
    
    // MARK: Public functions
    /// Creates the view model that controls the customer contact data collection view
    /// - Parameter allowedCountries: The list of countries the user can select from
    /// - Parameter selectedCountry: The default country to select on load
    public init(allowedCountries:[TapCountryCode], selectedCountry:TapCountryCode) {
        self.allowedCountries = TapCountry.getCountryDetails(fromEnums: allowedCountries)
        self.selectedCountry = TapCountry.getCountryDetails(fromEnums: [selectedCountry]).first
        super.init()
        defer{
            self.customerShippingDataCollectionView = .init()
            self.customerShippingDataCollectionView?.setupView(with: self)
            reloadData()
        }
    }
    
    // MARK: Internal functions
    /// Reloads and redraws the uiview based on the provided data
    internal func reloadData() {
        // Adjust the country text
        customerShippingDataCollectionView?.reloadCountryDetails()
    }
    
    /// Handles the logic needed to be done whenever the user clicks on the country code picker in the UI
    internal func countryPickerClicked() {
        guard let topController:UIViewController = UIViewController.topViewController()
        else { return }
        
        CountryManager.shared.config = configMaker
        CountryManager.shared.localeIdentifier = TapLocalisationManager.shared.localisationLocale ?? "en"
        let countryPicker = CountryPickerViewController()
        
        countryPicker.selectedCountry = selectedCountry?.countryCode.rawValue ?? "KW"
        countryPicker.delegate = self
        topController.present(countryPicker, animated: true)
    }
}


extension CustomerShippingDataCollectionViewModel: CountryPickerDelegate {
    public func countryPicker(didSelect country: Country) {
        if  let countryCode:TapCountryCode = TapCountryCode(rawValue: country.isoCode),
            let countryModel:TapCountry = TapCountry.getCountryDetails(fromEnums: [countryCode]).first {
            selectedCountry = countryModel
            customerShippingDataCollectionView?.reloadCountryDetails()
        }
    }
    
}
