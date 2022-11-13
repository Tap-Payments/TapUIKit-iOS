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
import NBBottomSheet

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
            self.customerContactDataCollectionView = .init()
            self.customerContactDataCollectionView?.setupView(with: self)
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
        // Adjust the phone country text
        customerContactDataCollectionView?.reloadPhone()
    }
    
    /// Defines what is the height required by this view to show its elements fully
    internal func requiredHeightForFieldsContainer() -> CGFloat {
        // Calculate the needed height of the the text fields
        return 48.0 * CGFloat(toBeCollectedData.count)
    }
    
    /// Defines what is the height required by this view to show its elements fully
    internal func requiredHeight() -> CGFloat {
        // Height for fields
        let heightForFields:CGFloat = requiredHeightForFieldsContainer() + 8
        // The header required height
        let heightForHeader:CGFloat = 30.0
        // The spacing we need
        let spacingRequired:CGFloat = 8.0+16.0
        
        return heightForHeader + heightForFields + spacingRequired
    }
    
    /// Handles the logic needed to be done whenever the user clicks on the country code picker in the UI
    internal func countryPickerClicked() {
        
        // Fetch the controller to display the country tables
        let story:UIStoryboard = .init(name: "TapUIKitStoryboard", bundle: Bundle(for: CountryPickerViewController.self))
        
        guard let ctr:CountryPickerViewController = story.instantiateViewController(identifier: "CountryPickerViewController") as? CountryPickerViewController,
              let topController:UIViewController = UIViewController.topViewController()
        else { return }
        
        // Adjust the bottom sheet to display the picker
        let configuration = NBBottomSheetConfiguration(animationDuration: 0.4, sheetSize: .fixed(countryPickerControllerHeight()))
        let bottomSheetController = NBBottomSheetController(configuration: configuration)
        bottomSheetController.present(ctr, on: topController)
        
        // Configure the view with the allowed countries
        ctr.configure(with: self.allowedCountries, delegate: self)
    }
    
    /// Computes the needed height to display the list if countries in the bottom sheet picker
    internal func countryPickerControllerHeight() -> CGFloat {
        // Get the required height
        let requiredFillHeight:CGFloat = CGFloat(self.allowedCountries.count+1) * CountryCodeTableViewCell.hountryCodeTableViewCellHeight + 30
        
        // Return the approproate height
        return min(requiredFillHeight, 300)
    }
    
    
    /// Creates the country picker view needed to be displaed in the popup
    internal func createCountryPickerView() -> CountryPickerTableView {
        // The picker view
        let customView = CountryPickerTableView()
        // Let the picker which countries the user can select from
        customView.configure(with: allowedCountries)
        return customView
    }
}

internal extension UIViewController {
    static func topViewController(_ viewController: UIViewController? = nil) -> UIViewController? {
        let viewController = viewController ?? UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        
        if let navigationController = viewController as? UINavigationController,
           !navigationController.viewControllers.isEmpty
        {
            return self.topViewController(navigationController.viewControllers.last)
            
        } else if let tabBarController = viewController as? UITabBarController,
                  let selectedController = tabBarController.selectedViewController
        {
            return self.topViewController(selectedController)
            
        } else if let presentedController = viewController?.presentedViewController {
            return self.topViewController(presentedController)
            
        }
        
        return viewController
    }
}


extension CustomerContactDataCollectionViewModel: CountryCodePickerViewControllerDelegate {
    
    func didSelect(country: TapCountry) {
        selectedCountry = country
        customerContactDataCollectionView?.reloadPhone()
    }
    
}
