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
import TapThemeManager2020

/// An external delegate to listen to events fired from the whole loyalty widget
public protocol TapCurrencyWidgetViewModelDelegate {
    
    /**
     Will be fired when a user click on confirm button
     - Parameter for viewModel: The view model that contains the button which clicked. This will help the delegate to know the data like (selected currency, attached payment option, etc.)
     */
    func confirmClicked(for viewModel:TapCurrencyWidgetViewModel)
    
    /**
     Will be fired when a user click on confirm button
     - Parameter for viewModel: The view model that contains the button which clicked. This will help the delegate to know the data like (selected currency, attached payment option, etc.)
     - Parameter and isOpened: If true, means the drop down is being visible now.
     */
    func dropDownClicked(for viewModel:TapCurrencyWidgetViewModel,and isOpened:Bool)
    
}
/// A delegate to communicate with the tao currency widget view
internal protocol TapCurrencyWidgetViewDelegate {
    /// Consolidated one point to reload view
    func reload()
    
    /// Remove any tool tip appear
    func removeTooltip()
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
    /// A delegate to communicate with the tao currency widget view
    internal var viewDelegate:TapCurrencyWidgetViewDelegate?
    /// Indicates to show the currency symbol or the currency code
    internal var tapCurrencyFormatterSymbol:TapCurrencyFormatterSymbol = .ISO
    
    /// Type of widget if it for disabled or enabled and have multi currencies
    private var type: TapCurrencyWidgetType
    /// The Amount user will pay when choose this payment option
    private var convertedAmounts: [AmountedCurrency]
    /// The  payment option to be shown
    public var paymentOption: PaymentOption
    /// An external delegate to listen to events fired from the currency widget view
    private var delegate:TapCurrencyWidgetViewModelDelegate?
    /// State of currency drop down menu
    private var isCurrencyDropDownShown: Bool = false
    /// The Amount user will pay when choose this payment option
    public var selectedAmountCurrency: AmountedCurrency?

    
    // MARK: - Public normal swift variables
    /// Public reference to the loyalty view itself as UI that will be rendered
    public var attachedView: TapCurrencyWidgetView {
        return tapCurrencyWidgetView ?? .init()
    }
    
    /**
     Init method with the needed data
     - Parameter convertedAmounts: The Amounts user will pay when choose this payment option
     - Parameter paymentOption: The payment option we want to convert to
     - Parameter type: The type of TapCurrencyWidget if it for disabled or enabled payment method
     */
    public init(convertedAmounts: [AmountedCurrency], paymentOption:PaymentOption, type:TapCurrencyWidgetType) {
        self.convertedAmounts = convertedAmounts
        self.paymentOption = paymentOption
        self.selectedAmountCurrency = convertedAmounts.first
        self.type = type
        super.init()
        defer{
            setup()
        }
    }

    /**
     Will update the content displayed on the widget with the newly given data
     - Parameter with convertedAmounts: The Amounts user will pay when choose this payment option
     - Parameter and paymentOption: The payment option we want to convert to
     */
    public func updateData(with convertedAmounts: [AmountedCurrency], and paymentOption:PaymentOption) {
        self.convertedAmounts = convertedAmounts
        self.paymentOption = paymentOption
        self.selectedAmountCurrency = convertedAmounts.first
        self.refreshData()
    }
    
    // MARK: - private
    private var messageLabelLocalizationPath: String {
        switch type {
        case .disabledPaymentOption:
            return "\(localizationPath).header"
        case .enabledPaymentOption:
            return "\(localizationPath).enabledHeader"
        }
    }
    
    /// function to setup viewmodel
    private func setup() {
        self.tapCurrencyWidgetView = .init()
        self.tapCurrencyWidgetView?.changeViewModel(with: self)
        self.refreshData()
    }
    
    /**
     Computes a formatted currency localized string representation for a given amount
     - Parameter amount: The double amount want to be formatted
     - Parameter currencyCode: The currency code we want to format with
     - Returns: A formatted localized currency paired string
     */
    private func currencyFormatted(amount:Double, currencyCode:TapCurrencyCode?, decimalDigits:Int?) -> String {
        guard let currencyCode = currencyCode, currencyCode != .undefined  else {
            return ""
        }
        let weakTapCurrencyFormatterSymbol = tapCurrencyFormatterSymbol
        
        let formatter = TapAmountedCurrencyFormatter {
            $0.currency = currencyCode
            $0.decimalDigits = decimalDigits ?? 2
            $0.locale = CurrencyLocale.englishUnitedStates
            // Check if the caller wants to show the currency symbol instead of the code
            if weakTapCurrencyFormatterSymbol == .LocalSymbol {
                $0.currencySymbol = currencyCode.symbolRawValue
                $0.localizeCurrencySymbol = true
            }else{
                $0.currencySymbol = currencyCode.appleRawValue
            }
        }
        return formatter.string(from: amount) ?? "KD0.000"
    }
    
    
    // MARK: - Internal functions
    /// Will compute the needed height for the drop down list,
    /// if it is a singleton then 12px padding + 50px height + 12x padding
    /// if it is 2+ items then 50px heght * count
    internal var drowDownListHeight:CGFloat {
        return getSupportedCurrenciesOptions().count == 1 ? 62.0 : CGFloat(46 * getSupportedCurrenciesOptions().count)
    }
    /// Computes the message label value
    internal var messageLabel: String {
        let localisationLocale = sharedLocalisationManager.localisationLocale
        if localisationLocale == "ar" {
            // In case of mixed English and Arabic content in the same label, we will have to use String.localized otherwise, the content will be mixed.
            return String.localizedStringWithFormat("%@ %@", sharedLocalisationManager.localisedValue(for: messageLabelLocalizationPath, with:TapCommonConstants.pathForDefaultLocalisation()), paymentOption.displayableTitle)
        } else {
            return "\(paymentOption.displayableTitle) \(sharedLocalisationManager.localisedValue(for: messageLabelLocalizationPath, with:TapCommonConstants.pathForDefaultLocalisation()))"
        }
        
    }
    /// Computes the confirm button text value
    internal var confirmButtonText: String {
        return "\(sharedLocalisationManager.localisedValue(for: "\(localizationPath).confirmButton", with: TapCommonConstants.pathForDefaultLocalisation()))"
    }
    
    /// Computes the currency text value
    internal var amountLabel: String {
        return currencyFormatted(amount: selectedAmountCurrency?.amount ?? 0, currencyCode: selectedAmountCurrency?.currency, decimalDigits: selectedAmountCurrency?.decimalDigits) //"\(selectedAmountCurrency?.currencySymbol ?? "") \(selectedAmountCurrency?.amount ?? 0)"
    }
    /// Computes the currency flag value
    internal var amountFlag: String {
        return selectedAmountCurrency?.flag ?? ""
    }
    
    /// Computes the payment Option logo value
    internal var paymentOptionLogo: URL {
        return paymentOption.correctCurrencyWidgetImageURL(showMonoForLightMode: TapThemeManager.showMonoForLightMode, showColoredForDarkMode: TapThemeManager.showColoredForDarkMode)
    }
    
    /// Computes the showing or disable the multiple currencies  option
    internal var showMultipleCurrencyOption: Bool {
       return convertedAmounts.count > 1
    }
    
    ///  State of drop currency down menu
    internal var isCurrencyDropDownExpanded: Bool {
        return isCurrencyDropDownShown;
    }
    
    /// On click on confirm button
    internal func confirmClicked() {
        delegate?.confirmClicked(for: self)
    }
    
    /// On click on currency
    internal func currencyClicked() {
        isCurrencyDropDownShown = !isCurrencyDropDownShown
        refreshData()
        delegate?.dropDownClicked(for: self, and: isCurrencyDropDownShown)
    }
    
    internal func getSupportedCurrenciesOptions() -> [AmountedCurrency] {
        return convertedAmounts.filter {
            $0.currency != selectedAmountCurrency?.currency
        }
    }
    
    internal func setSelectedAmountCurrency(selectedAmountCurrency: AmountedCurrency) {
        self.selectedAmountCurrency = selectedAmountCurrency
        tapCurrencyWidgetView?.removeTooltip()
        refreshData()
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

/// Type of TapCurrencyWidget if it for disabled payment option or enabled payment option
public enum TapCurrencyWidgetType {
    case disabledPaymentOption
    case enabledPaymentOption
}

    
    
