//
//  TapCurrencyWidgetViewModel.swift
//  TapUIKit-iOS
//
//  Created by MahmoudShaabanAllam on 25/05/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import Foundation
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS

/// An external delegate to listen to events fired from the whole loyalty widget
public protocol TapCurrencyWidgetViewModelDelegate {
    
    /**
     Will be fired when a user click on confirm button
     */
    func confirmClicked()
    
}

internal protocol TapCurrencyWidgetViewDelegate {
    /// Consolidated one point to reload view
    func reload()
}

/// The view model that controls the data shown inside a TapCurrencyWidget
public class TapCurrencyWidgetViewModel:NSObject {
    
    // MARK:- Internal swift variables
    /// Reference to the  currency widget view itself as UI that will be rendered
    internal var tapCurrencyWidgetView:TapCurrencyWidgetView?
    /// Localisation kit key path
    internal var localizationPath = "CurrencyChangeWidget"
    /// Configure the localisation Manager
    internal let sharedLocalisationManager = TapLocalisationManager.shared
    
    internal var viewDelegate:TapCurrencyWidgetViewDelegate?
    
    
    /// The Amount user will pay when choose this payment option
    private var convertedAmount:AmountedCurrency
    /// The  payment option to be shown
    private var paymentOption: PaymentOption
    /// An external delegate to listen to events fired from the currency widget view
    private var delegate:TapCurrencyWidgetViewModelDelegate?
    
    // MARK: - Public normal swift variables
    /// Public reference to the loyalty view itself as UI that will be rendered
    public var attachedView: TapCurrencyWidgetView {
        return tapCurrencyWidgetView ?? .init()
    }
    
    
    
    
    /**
     Init method with the needed data
     - Parameter convertedAmount: The Amount user will pay when choose this payment option
     - Parameter currencyFlag: The Logo of currency user  pay when choose this payment option
     - Parameter paymentOptionLogo: The Logo of payment option to be shown
     - Parameter paymentOptionName: The name of payment option to be shown
     - Parameter currency: The currency being used
     */
    public init(convertedAmount:AmountedCurrency, paymentOption:PaymentOption) {
        self.convertedAmount = convertedAmount
        self.paymentOption = paymentOption
        super.init()
        defer{
            setup()
        }
    }
    
    // MARK: - private
    /// function to setup viewmodel
    private func setup() {
        self.tapCurrencyWidgetView = .init()
        self.tapCurrencyWidgetView?.changeViewModel(with: self)
        self.refreshData()
    }
    
    
    // MARK: - Internal functions
    /// Computes the message label value
    internal var messageLabel: String {
        let localisationLocale = sharedLocalisationManager.localisationLocale
        if localisationLocale == "ar" {
            // In case of mixed English and Arabic content in the same label, we will have to use String.localized otherwise, the content will be mixed.
            return String.localizedStringWithFormat("%@ %@", sharedLocalisationManager.localisedValue(for: "\(localizationPath).header", with:TapCommonConstants.pathForDefaultLocalisation()), paymentOption.displayableTitle(for: localisationLocale ?? paymentOption.displayableTitle))
        } else {
            return "\(paymentOption.displayableTitle(for: localisationLocale ?? paymentOption.displayableTitle)) \(sharedLocalisationManager.localisedValue(for: "\(localizationPath).header", with:TapCommonConstants.pathForDefaultLocalisation()))"
        }
        
    }
    /// Computes the confirm button text value
    internal var confirmButtonText: String {
        return "\(sharedLocalisationManager.localisedValue(for: "\(localizationPath).confirmButton", with: TapCommonConstants.pathForDefaultLocalisation()))"
    }
    
    /// Computes the currency text value
    internal var amountLabel: String {
        return "\(convertedAmount.currencySymbol) \(convertedAmount.amount)"
    }
    /// Computes the currency flag value
    internal var amountFlag: String {
        return convertedAmount.flag
    }
    
    /// Computes the payment Option logo value
    internal var paymentOptionLogo: URL {
        return paymentOption.correctCurrencyWidgetImageURL()
    }
    
    internal func confirmClicked() {
        delegate?.confirmClicked()
    }
    
    // MARK: - Public
    
    /// Refresh and reload view state
    public func refreshData() {
        // Reload view state
        tapCurrencyWidgetView?.reload()
    }
    
    /// Set view model delegate
    public func setTapCurrencyWidgetViewModelDelegate(delegate:TapCurrencyWidgetViewModelDelegate) {
        self.delegate = delegate
    }
}




