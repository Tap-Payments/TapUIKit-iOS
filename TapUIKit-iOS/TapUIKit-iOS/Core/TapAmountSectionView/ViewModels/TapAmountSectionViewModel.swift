//
//  TapAmountSectionViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/11/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//
import Foundation
import LocalisationManagerKit_iOS
import class CommonDataModelsKit_iOS.TapCommonConstants
import enum CommonDataModelsKit_iOS.TapCurrencyCode
/// The view model that controlls the data shown inside a TapAmountSectionView
public struct TapAmountSectionViewModel {
    
    
    
    /// Represent the original transaction total amount
    public var originalTransactionAmount:Double = 0
    /// Represent the original transaction currenc code
    public var originalTransactionCurrency:TapCurrencyCode?
    /// Represent the converted transaction total amount if any
    public var convertedTransactionAmount:Double = 0
    /// Represent the converted transaction currenc code if any
    public var convertedTransactionCurrency:TapCurrencyCode?
    /// Represent the number of items in the current transaction
    public var numberOfItems:Int = 0
    /// Indicates if the number of items should be shown
    public var shouldShowItems:Bool = true
    /// Indicates if the amount labels should be shown
    public var shouldShowAmount:Bool = true
    
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
     */
    public init(originalTransactionAmount: Double = 0, originalTransactionCurrency: TapCurrencyCode? = nil, convertedTransactionAmount: Double = 0, convertedTransactionCurrency: TapCurrencyCode? = nil, numberOfItems: Int = 0, shouldShowItems: Bool = true, shouldShowAmount: Bool = true) {
        self.originalTransactionAmount = originalTransactionAmount
        self.originalTransactionCurrency = originalTransactionCurrency
        self.convertedTransactionAmount = convertedTransactionAmount
        self.convertedTransactionCurrency = convertedTransactionCurrency
        self.numberOfItems = numberOfItems
        self.shouldShowItems = shouldShowItems
        self.shouldShowAmount = shouldShowAmount
    }
    
}
