//
//  TapAmountSectionViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/11/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//
import class LocalisationManagerKit_iOS.TapLocalisationManager
import class CommonDataModelsKit_iOS.TapCommonConstants
import class CommonDataModelsKit_iOS.TapAmountedCurrencyFormatter
import enum CommonDataModelsKit_iOS.CurrencyLocale
import enum CommonDataModelsKit_iOS.TapCurrencyCode
import RxCocoa
/// The view model that controlls the data shown inside a TapAmountSectionView
public struct TapAmountSectionViewModel {
    // MARK:- RX Internal Observables
    
    /// Represent the original transaction total amount
    internal var originalAmountLabelObserver:BehaviorRelay<String> = .init(value: "")
    /// Represent the converted transaction total amount if any
    internal var convertedAmountLabelObserver:BehaviorRelay<String> = .init(value: "")
    /// Represent the number of items in the current transaction
    internal var itemsLabelObserver:BehaviorRelay<String> = .init(value: "")
    /// Indicates if the number of items should be shown
    internal var showItemsObserver:BehaviorRelay<Bool> = .init(value: true)
    /// Indicates if the amount labels should be shown
    internal var showAmount:BehaviorRelay<Bool> = .init(value: true)
    
    
    // MARK:- Public normal swift variables
    /// Represent the original transaction total amount
    public var originalTransactionAmount:Double = 0 {
        didSet {
            updateAmountObserver(for: originalTransactionAmount, with: originalTransactionCurrency, on: originalAmountLabelObserver)
        }
    }
    
    /// Represent the original transaction currenc code
    public var originalTransactionCurrency:TapCurrencyCode? {
        didSet {
            updateAmountObserver(for: originalTransactionAmount, with: originalTransactionCurrency, on: originalAmountLabelObserver)
        }
    }
    /// Represent the converted transaction total amount if any
    public var convertedTransactionAmount:Double = 0 {
        didSet {
            updateAmountObserver(for: convertedTransactionAmount, with: convertedTransactionCurrency, on: convertedAmountLabelObserver)
        }
    }
    /// Represent the converted transaction currenc code if any
    public var convertedTransactionCurrency:TapCurrencyCode? {
        didSet {
            updateAmountObserver(for: convertedTransactionAmount, with: convertedTransactionCurrency, on: convertedAmountLabelObserver)
        }
    }
    /// Represent the number of items in the current transaction
    public var numberOfItems:Int = 0 {
        didSet {
            itemsLabelObserver.accept("\(numberOfItems) \(sharedLocalisationManager.localisedValue(for: "Common.items", with: TapCommonConstants.pathForDefaultLocalisation()))")
        }
    }
    /// Indicates if the number of items should be shown
    public var shouldShowItems:Bool = true {
        didSet {
            showItemsObserver.accept(shouldShowItems)
        }
    }
    /// Indicates if the amount labels should be shown
    public var shouldShowAmount:Bool = true {
        didSet {
            showAmount.accept(shouldShowAmount)
        }
    }
    /// Indicates to show the currency symbol or the currency code
    public var tapCurrencyFormatterSymbol:TapCurrencyFormatterSymbol = .ISO {
        didSet {
            originalTransactionAmount = originalTransactionAmount + 0
            convertedTransactionAmount = convertedTransactionAmount + 0
        }
    }
    
    /// Localisation kit keypath
    internal var localizationPath = "TapMerchantSection"
    /// Configure the localisation Manager
    internal let sharedLocalisationManager = TapLocalisationManager.shared
   
    /**
     Creates a view model to handle the displayed data and interactions for an associated TapAmountSectionView
     - Parameter originalTransactionAmount:Represent the original transaction total amount
     - Parameter originalTransactionCurrency:Represent the original transaction total amount
     - Parameter convertedTransactionAmount:Represent the original transaction total amount
     - Parameter convertedTransactionCurrency:Represent the original transaction total amount
     - Parameter numberOfItems:Represent the original transaction total amount
     - Parameter shouldShowItems:Represent the original transaction total amount
     - Parameter shouldShowAmount:Represent the original transaction total amount
     - Parameter tapCurrencyFormatterSymbol:Indicates to show the currency symbol or the currency code
     */
    public init(originalTransactionAmount: Double = 0, originalTransactionCurrency: TapCurrencyCode? = nil, convertedTransactionAmount: Double = 0, convertedTransactionCurrency: TapCurrencyCode? = nil, numberOfItems: Int = 0, shouldShowItems: Bool = true, shouldShowAmount: Bool = true,tapCurrencyFormatterSymbol:TapCurrencyFormatterSymbol = .ISO) {
        defer {
            self.originalTransactionAmount = originalTransactionAmount
            self.originalTransactionCurrency = originalTransactionCurrency
            self.convertedTransactionAmount = convertedTransactionAmount
            self.convertedTransactionCurrency = convertedTransactionCurrency
            self.numberOfItems = numberOfItems
            self.shouldShowItems = shouldShowItems
            self.shouldShowAmount = shouldShowAmount
            self.tapCurrencyFormatterSymbol = tapCurrencyFormatterSymbol
        }
    }
    
    private func updateAmountObserver(for amount:Double, with currencyCode:TapCurrencyCode?, on observer:BehaviorRelay<String>) {
        guard let currencyCode = currencyCode  else {
            observer.accept("")
            return
        }
        let weakTapCurrencyFormatterSymbol = tapCurrencyFormatterSymbol
        
        let formatter = TapAmountedCurrencyFormatter {
            $0.currency = currencyCode
            $0.locale = CurrencyLocale.englishUnitedStates
            // Check if the caller wants to show the currency symbol instead of the code
            if weakTapCurrencyFormatterSymbol == .LocalSymbol {
                $0.currencySymbol = currencyCode.symbolRawValue
                $0.localizeCurrencySymbol = true
            }
        }
        observer.accept(formatter.string(from: amount) ?? "KD0.000")
    }
}

public enum TapCurrencyFormatterSymbol {
    case ISO
    case LocalSymbol
}
