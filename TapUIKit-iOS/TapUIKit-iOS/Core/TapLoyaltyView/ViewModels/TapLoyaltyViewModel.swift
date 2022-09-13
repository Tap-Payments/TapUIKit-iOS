//
//  TapLoyaltyViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 13/09/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import Foundation
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS

/// The view model that controlls the data shown inside a TapLoyaltyView
@objc public class TapLoyaltyViewModel: NSObject {
    
    // MARK:- Internal swift variables
    /// Reference to the  loyalty view itself as UI that will be rendered
    internal var tapLoyaltyView:TapLoyaltyView?
    /// Localisation kit keypath
    internal var localizationPath = "TapLoyaltyView"
    /// Configure the localisation Manager
    internal let sharedLocalisationManager = TapLocalisationManager.shared
    /// The loylty model to use
    internal var loyaltyModel:TapLoyaltyModel
    /// The currenct amount
    internal var amount:Double
    /// The currency being used
    internal var currency:TapCurrencyCode
    
    // MARK: - Public normal swift variables
    /// Public reference to the loyalty view itself as UI that will be rendered
    @objc public var attachedView:TapLoyaltyView {
        return tapLoyaltyView ?? .init()
    }
    
    /**
     Init method with the needed data
     - Parameter loyaltyModel: The loyalty model to use to render
     - Parameter amount: The initial amount to use
     - Parameter currency: The currency we will pay with
     */
    public init(loyaltyModel:TapLoyaltyModel, amount:Double = 0, currency:TapCurrencyCode) {
        self.loyaltyModel = loyaltyModel
        self.amount = amount
        self.currency = currency
        self.tapLoyaltyView = .init()
        super.init()
        defer{
            self.tapLoyaltyView?.changeViewModel(with: self)
        }
    }
    
    // MARK: - Internal
    /// Computes the header title text for the Loyalty view. Format is : Redeem ADCB TouchPoints
    internal var headerTitleText: String {
        return "Redeem \(loyaltyModel.loyaltyProgramName ?? "")"
    }
    
    /// Computes the header subtitle text for the Loyalty view. Format is : Balance: AED 520.00 (81,500 TouchPoints)
    internal var headerSubTitleText: String {
        return "Balance: \(currency.symbolRawValue) \(balance(forCurrency: currency)) (\(loyaltyModel.transactionsCount ?? "") \(loyaltyModel.loyaltyPointsName ?? ""))"
    }
    
    /// Decides what is the url if any to open for T&C for this specific loyalty. Returns nil if no link provided or malformed
    internal var termsAndConditions: URL? {
        // Check if the backend passed a link for t&c and it is a valid url
        guard let nonNullTermsAndConditionsLink:String = loyaltyModel.termsConditionsLink,
              let nonNullTermsAndConditionsURL:URL = URL(string: nonNullTermsAndConditionsLink) else {
            return nil
        }
        return nonNullTermsAndConditionsURL
    }
    
    /// Decides what is the url to load the loyalty icon and nil otehrwise
    internal var loyaltyIcon: URL? {
        // Check if the backend passed a link for logo and it is a valid url
        guard let nonNullLogoLink:String = loyaltyModel.bankLogo,
              let nonNullLogoURL:URL = URL(string: nonNullLogoLink) else {
            return nil
        }
        return nonNullLogoURL
    }
    
    
    
    
    /**
     Fetches the balance for the user for a given currency
     - Parameter forCurrency: The currency you want the balance for
     - Returns the user's balance in the currency and 0 as a fallback
     */
    internal func balance(forCurrency:TapCurrencyCode) -> Double {
        // We filter the supported currencies to get the currency code we are looking for and then fetch the balance amount
        return loyaltyModel.supportedCurrencies?.first{$0.currency == forCurrency}?.balanceAmount ?? 0
    }
    
    
}
