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
import class CommonDataModelsKit_iOS.AmountedCurrency
import enum CommonDataModelsKit_iOS.CurrencyLocale
import enum CommonDataModelsKit_iOS.TapCurrencyCode

/// The protocl that informs the subscriber of any events happened/fired from the Amount Section View
@objc public protocol TapAmountSectionViewModelDelegate {
    /// A block to execute logic in view model when the items in the view is clicked by the user
    @objc optional func showItemsClicked()
    /// A block to execute logic in view model when the close items had been clicked
    @objc optional func closeItemsClicked()
    /// A block to execute logic in view model when the close scanner had been clicked
    @objc optional func closeScannerClicked()
    /// A block to execute logic in view model when the close GoPay login had been clicked
    @objc optional func closeGoPayClicked()
    /// A block to execute logic in view model when the amount section view in the view is clixked by the user
    @objc optional func amountSectionClicked()
}

/// The view model that controlls the data shown inside a TapAmountSectionView
@objc public class TapAmountSectionViewModel:NSObject {
    // MARK:- RX Internal Observables
    
    /// Represent the original transaction total amount
    internal var originalAmountLabelObserver:((String?)->()) = { _ in } {
        didSet {
            originalAmountLabelObserver(currencyFormatted(amount: originalTransactionAmount, currencyCode: originalTransactionCurrency.currency))
        }
    }
    /// Represent the converted transaction total amount if any
    internal var convertedAmountLabelObserver:((String?)->()) = { _ in } {
        didSet {
            convertedAmountLabelObserver(currencyFormatted(amount: convertedTransactionAmount, currencyCode: convertedTransactionCurrency.currency))
        }
    }
    /// Represent the number of items in the current transaction
    internal var itemsLabelObserver:((String?)->()) = { _ in } {
        didSet {
            itemsLabelObserver(itemsLabel)
        }
    }
    /// Indicates if the number of items should be shown
    internal var showItemsObserver:((Bool)->()) = { _ in } {
        didSet {
            showItemsObserver(shouldShowItems)
        }
    }
    /// Indicates if the amount labels should be shown
    internal var showAmount:((Bool)->()) = { _ in } {
        didSet {
            showAmount(shouldShowAmount)
        }
    }
    
    /// Computes the symbol of the currently used currency
    internal var usedCurrencyCode:String  {
        // We need to now if there is a conversion currency or we shall return the original currency code
        if self.convertedTransactionCurrency.currency != .undefined {
            return " | \(self.convertedTransactionCurrency.currency.appleRawValue)"
        }else if self.originalTransactionCurrency.currency != .undefined {
            return " | \(self.originalTransactionCurrency.currency.appleRawValue)"
        }
        return ""
    }
    /// Reference to the amount section view itself as UI that will be rendered
    internal var amountSectionView: TapAmountSectionView?
    /// Public reference to the list view itself as UI that will be rendered
    @objc public var attachedView: TapAmountSectionView {
        return amountSectionView ?? .init()
    }
    
    // MARK:- Public normal swift variables
    
    /// Attach yourself to this delegate to start getting events fired from this view model and its attached uiview
    @objc public var delegate:TapAmountSectionViewModelDelegate? {
        didSet {
            // Assign the view delegate
            amountSectionView = .init()
            // Instruct the list view that ME is the viewmodel of it
            amountSectionView!.changeViewModel(with: self)
        }
    }
    /// Enum to determine the current state of the amount view, whether we are shoing the default view or the items list is currencly visible
    var currentStateView:AmountSectionCurrentState = .DefaultView {
        didSet{
            configureItemsLabel()
        }
    }
    
    /// Represent the original transaction total amount
    @objc public var originalTransactionAmount:Double  {
        return originalTransactionCurrency.amount
    }
    
    /// Represent the original transaction total amount
    @objc public var originalTransactionAmountFormated:String  {
        return currencyFormatted(amount: originalTransactionAmount,currencyCode: originalTransactionCurrency.currency)
    }
    
    /// Represent the title that should be displayed inside the SHOW ITEMS/CLOSE button
    @objc public var itemsLabel:String = "" {
        didSet {
            itemsLabelObserver(itemsLabel)
        }
    }
    
    /// Represent the original transaction currenc code
    @objc public var originalTransactionCurrency:AmountedCurrency = .init(.undefined, 0, "") {
        didSet {
            updateAmountObserver(for: originalTransactionAmount, with: originalTransactionCurrency, on: originalAmountLabelObserver)
        }
    }
    /// Represent the converted transaction total amount if any
    @objc public var convertedTransactionAmount:Double {
        return convertedTransactionCurrency.amount
    }
    
    // Represent the original transaction total amount
    @objc public var convertedTransactionAmountFormated:String  {
        return currencyFormatted(amount: convertedTransactionAmount,currencyCode: convertedTransactionCurrency.currency)
    }
    
    /// Represent the converted transaction currenc code if any
    @objc public var convertedTransactionCurrency:AmountedCurrency = .init(.undefined, 0, "") {
        didSet {
            if convertedTransactionCurrency == originalTransactionCurrency || convertedTransactionCurrency.currency == .undefined {
                convertedTransactionCurrency = .init(.undefined, 0, "")
            }
            //updateAmountObserver(for: convertedTransactionAmount, with: convertedTransactionCurrency, on: convertedAmountLabelObserver)
        }
    }
    /// Represent the number of items in the current transaction
    @objc public var numberOfItems:Int = 0 {
        didSet {
            configureItemsLabel()
        }
    }
    /// Indicates if the number of items should be shown
    @objc public var shouldShowItems:Bool = true {
        didSet {
            showItemsObserver(shouldShowItems)
        }
    }
    /// Indicates if the amount labels should be shown
    @objc public var shouldShowAmount:Bool = true {
        didSet {
            showAmount(shouldShowAmount)
        }
    }
    /// Indicates to show the currency symbol or the currency code
    @objc public var tapCurrencyFormatterSymbol:TapCurrencyFormatterSymbol = .ISO {
        didSet {
            updateAmountObserver(for: convertedTransactionAmount, with: convertedTransactionCurrency, on: convertedAmountLabelObserver)
            updateAmountObserver(for: originalTransactionAmount, with: originalTransactionCurrency, on: originalAmountLabelObserver)
        }
    }
    
    /// Indicates whether this view should be displayed or not.
    @objc public var shouldShow:Bool = true
    
    /// Localisation kit keypath
    internal var localizationPath = "TapMerchantSection"
    /// Configure the localisation Manager
    internal let sharedLocalisationManager = TapLocalisationManager.shared
    
    /**
     Creates a view model to handle the displayed data and interactions for an associated TapAmountSectionView
     - Parameter originalTransactionCurrency:Represent the original transaction total amount
     - Parameter convertedTransactionCurrency:Represent the original transaction total amount
     - Parameter numberOfItems:Represent the original transaction total amount
     - Parameter shouldShowItems:Represent the original transaction total amount
     - Parameter shouldShowAmount:Represent the original transaction total amount
     - Parameter tapCurrencyFormatterSymbol:Indicates to show the currency symbol or the currency code
     */
    @objc public init(originalTransactionCurrency: AmountedCurrency = .init(.undefined, 0, ""), convertedTransactionCurrency: AmountedCurrency = .init(.undefined, 0, ""), numberOfItems: Int = 0, shouldShowItems: Bool = true, shouldShowAmount: Bool = true,tapCurrencyFormatterSymbol:TapCurrencyFormatterSymbol = .ISO) {
        super.init()
        defer {
            self.originalTransactionCurrency = originalTransactionCurrency
            self.convertedTransactionCurrency = convertedTransactionCurrency
            self.numberOfItems = numberOfItems
            self.shouldShowItems = shouldShowItems
            self.shouldShowAmount = shouldShowAmount
            self.tapCurrencyFormatterSymbol = tapCurrencyFormatterSymbol
        }
    }
    
    /// Call this method to informthe amount section the current state of the screen changed, hence the title of items button and its action will differ
    @objc public func screenChanged(to state:AmountSectionCurrentState) {
        // Adjust inner details to represent the new state
        currentStateView = state
    }
    
    private func updateAmountObserver(for amount:Double, with currencyCode:AmountedCurrency?, on observer:((String)->())) {
        observer(currencyFormatted(amount: amount, currencyCode: currencyCode?.currency))
    }
    
    /**
     Computes a formatted currency localized string representation for a given amount
     - Parameter amount: The double amount want to be formatted
     - Parameter currencyCode: The currency code we want to format with
     - Returns: A formatted localized currency paired string
     */
    private func currencyFormatted(amount:Double,currencyCode:TapCurrencyCode?) -> String {
        guard let currencyCode = currencyCode, currencyCode != .undefined  else {
            return ""
        }
        let weakTapCurrencyFormatterSymbol = tapCurrencyFormatterSymbol
        
        let formatter = TapAmountedCurrencyFormatter {
            $0.currency = currencyCode
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
    
    // MARK:- Internal methods to let the view talks with the delegate
    /// A block to execute logic in view model when the items in the view is clicked by the user
    internal func itemsClicked() {
        // Determine which method should we execute
        switch currentStateView {
            // Meaning, currently we are showing the normal view and we need to show the items list
        case .DefaultView:
            showItems()
            break
            // Meaning currently we are showing the list items and we need to go back to the normal view
        case .ItemsView:
            closeItems()
            break
            // Meaning currently we are showing the scanner and we need to go back to the normal view
        case .ScannerView:
            closeScanner()
            break
            // Meaning currently we are showing the GoPay Login and we need to go back to the normal view
        case .GoPayView:
            closeGoPay()
            break
        }
    }
    
    internal func configureItemsLabel() {
        switch currentStateView{
        case .DefaultView:
            itemsLabel = "\(numberOfItems) \(sharedLocalisationManager.localisedValue(for: (numberOfItems < 2) ? "Common.item" : "Common.items", with: TapCommonConstants.pathForDefaultLocalisation()))\(self.usedCurrencyCode)"
        case .ItemsView,.ScannerView,.GoPayView:
            itemsLabel = sharedLocalisationManager.localisedValue(for: "Common.close", with: TapCommonConstants.pathForDefaultLocalisation())
        }
    }
    
    /// Handles the logic for transitioning between the normal view and show the items view
    private func showItems() {
        // Adjust inner details to represent the new state
        currentStateView = .ItemsView
        // Inform the delegate that we need to take an action to show the items
        delegate?.showItemsClicked?()
    }
    
    /// Handles the logic for transitioning between the items view and default view
    private func closeItems() {
        // Adjust inner details to represent the new state
        currentStateView = .DefaultView
        numberOfItems = numberOfItems + 0
        // Inform the delegate that we need to take an action to show the items
        delegate?.closeItemsClicked?()
    }
    
    
    /// Handles the logic for transitioning between the items view and default view
    private func closeScanner() {
        // Adjust inner details to represent the new state
        currentStateView = .DefaultView
        numberOfItems = numberOfItems + 0
        // Inform the delegate that we need to take an action to show the items
        delegate?.closeScannerClicked?()
    }
    
    
    private func closeGoPay() {
        // Adjust inner details to represent the new state
        currentStateView = .DefaultView
        numberOfItems = numberOfItems + 0
        // Inform the delegate that we need to take an action to show the items
        delegate?.closeGoPayClicked?()
    }
    
    /// A block to execute logic in view model when the amount section view in the view is clixked by the user
    internal func amountSectionClicked() {
        delegate?.amountSectionClicked?()
    }
}

/// Enum to state all different formatting to show the currency symbols
@objc public enum TapCurrencyFormatterSymbol:Int {
    case ISO
    case LocalSymbol
}

/// Enum to determine the current state of the amount view, whether we are shoing the default view or the items list is currencly visiblt
@objc public enum AmountSectionCurrentState:Int {
    /// Default view, which has the normal payment screen + title is "ITEMS"
    case DefaultView
    /// Means, the current screen displays the items list
    case ItemsView
    /// Means, the current screen displays the scannner
    case ScannerView
    /// Means, the current screen displays the GoPay
    case GoPayView
}
