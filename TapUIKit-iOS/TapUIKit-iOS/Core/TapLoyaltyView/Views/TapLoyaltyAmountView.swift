//
//  TapLoyaltyAmountView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 14/09/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import UIKit
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS
import TapThemeManager2020

/// A delegate to listen to events fired from the TapLoyaltyAmountView
internal protocol TapLoyaltyAmountViewDelegate {
    
    /**
     Get notified when the user changes the loyalty amount he wants to redeem
     - Parameter with newAmount: The new amount defined by the user
     */
    func loyaltyRedemptionAmountChanged(with newAmount:Double)
    
}
/// Represents the amount sub view in the loyalty widget
internal class TapLoyaltyAmountView: UIView {
    
    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!
    /// The title label
    @IBOutlet weak var titleLabel: UILabel!
    /// list of views that needs to be forceable RTL support if needed
    @IBOutlet var toBeLocalisedViews: [UIView]!
    /// Displays how many points will the user redeem
    @IBOutlet weak var pointsLabel: UILabel!
    /// Displays the name of the points in the scheme (e.g. Loyaltpoint, touchpoints etc.)
    @IBOutlet weak var pointsProgramNameLabel: UILabel!
    /// Allows the user to type in a specific amount he wants to redeem
    @IBOutlet weak var amountTextField: UITextField!
    /// Displays the currently being used currency
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var tapSeparator: TapSeparatorView!
    /// The path to look for theme entry in
    private let themePath = "loyaltyView.amountView"
    /// The current selected currency data
    internal var viewModel:TapLoyaltyViewModel?
    /// A delegate to listen to events fired from the TapLoyaltyAmountView
    internal var delegate:TapLoyaltyAmountViewDelegate?
    /// A shortcut to get the current amoutnt
    internal var amount:Double = 0 {
        didSet {
            postAmountUpdated()
        }
    }
    
    // MARK: Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.containerView = setupXIB()
        translatesAutoresizingMaskIntoConstraints = false
        configureDelegates()
        toBeLocalisedViews.forEach{ $0.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight }
        
        applyTheme()
    }
    
    
    /**
     Will stup the content of the view with the given data
     - Parameter with viewModel: The view model
     - Parameter initialAmount: The initial amount to display if any
     */
    internal func setup(with viewModel:TapLoyaltyViewModel, initialAmount:Double = 0) {
        // save the viewModel
        self.viewModel = viewModel
        // reset any data we have
        amountTextField.text = ""
        // save the initial amount
        amount = initialAmount
        // put the initial amount if any
        if initialAmount > 0 { amountTextField.text = viewModel.formattedAmount }
        reloadData()
        
    }
    
    /// Call it to reload the textual content of the amount view when a change happens (like selected currency.)
    internal func reloadData() {
        guard let nonNullCurrency = viewModel?.currency,
              let nonNullLoyalCurrency = viewModel?.loyaltyCurrency(forCurrency: nonNullCurrency),
              let usedPoints = viewModel?.usedPoints else { return }
        
        // Set the currency label
        currencyLabel.text = nonNullLoyalCurrency.currency?.displaybaleSymbol
        // Set the redemption points based on the amount and the rate
        pointsLabel.text = " \(usedPoints) "
        // Set the points name
        pointsProgramNameLabel.text = "\(viewModel?.loyaltyModel?.loyaltyPointsName ?? "")"
        // Set the title label
        titleLabel.text = TapLocalisationManager.shared.localisedValue(for: "TapLoyaltySection.amountView.title", with: TapCommonConstants.pathForDefaultLocalisation())
    }
    
    /// Assigns all needed delegates for different views
    internal func configureDelegates() {
        amountTextField.delegate = self
        amountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    
    /// Handles the logic needed to be done once the amount is changed
    internal func postAmountUpdated() {
        // Inform the delegate that amount had changed
        delegate?.loyaltyRedemptionAmountChanged(with: amount)
        // reload the text data in points deeduction basde on new amount
        reloadData()
    }
    
    /// Checks if a given string passes the decimal allowed places
    /// - Parameter for toBeCheckedString : The string value to check
    /// - Parameter regards ecimalPlaces: The max allowed decimal places
    internal func allowedDecimalPlaces(for toBeCheckedString:String, regards decimalPlaces:Int) -> Bool {
        var adjustedToBeCheckedString = toBeCheckedString
        // Check if the . is the begining of the number e.g. .12 add a leading zero
        if adjustedToBeCheckedString.hasPrefix(".") {
            adjustedToBeCheckedString = "0\(adjustedToBeCheckedString)"
        }
        // Now check that the given string has at most 1 decimal point
        let numberParts:[String] = adjustedToBeCheckedString.components(separatedBy: ".")
        if numberParts.count == 1 {
            // This means it has no decimal points at all
            return true
        }else if numberParts.count == 2 {
            // This means it has one decimal point and we need to check the count of the decimal places
            return numberParts[1].count <= decimalPlaces
        }else{
            // The given string has more than 1 decimal point, hence it is not a parsable number
            return false
        }
    }
    
    /// Will catch the event when the user changed the text in the amonut field with an accepted value
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Save the amount
        amount = Double(amountTextField.text ?? "0") ?? 0
        
    }
}

extension TapLoyaltyAmountView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        backgroundColor = .clear
        containerView.backgroundColor = .clear
        
        titleLabel.tap_theme_font = .init(stringLiteral: "\(themePath).titleFont")
        titleLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).titleTextColor")
        
        pointsLabel.tap_theme_font = .init(stringLiteral: "\(themePath).pointsFont", shouldLocalise: false)
        pointsLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).pointsTextColor")
        
        pointsProgramNameLabel.tap_theme_font = .init(stringLiteral: "\(themePath).pointsFont", shouldLocalise: false)
        pointsProgramNameLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).pointsTextColor")
        
        currencyLabel.tap_theme_font = .init(stringLiteral: "\(themePath).currencyFont")
        currencyLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).currencyTextColor")
        
        amountTextField.tap_theme_font = .init(stringLiteral: "\(themePath).amountFont")
        amountTextField.tap_theme_textColor = .init(stringLiteral: "\(themePath).amountTextColor")
        
        amountTextField.textAlignment = (TapLocalisationManager.shared.localisationLocale == "ar") ? .right : .left
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}


extension TapLoyaltyAmountView: UITextFieldDelegate {
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.amountTextField {
            // We will need to accept only decimal digits into the amount field
            
            // So first we need to check that the new string containts only numbers and .
            let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            guard string == numberFiltered else { return false }
            
            // Then we need to make sure that the string will be parsable as decimal number
            let currentString:String = textField.text ?? ""
            let newString = currentString.replacingCharacters(in: Range(range, in:currentString)!, with: string)
            // If the user cleared it is fine up to him
            guard newString != "" else { return true }
            
            // Otherwise let us check he didn't type a non decimal value
            guard let decimalInput : Decimal = Decimal(string: newString, locale: Locale(identifier: "en_US")) else { return false }
            // Don't accept any more decimals than the allowed placed by the currency
            // We don't accept a value bigger than the max balance for the user with this currency and not bigger than the total transaction amount
            
            guard allowedDecimalPlaces(for: newString, regards: viewModel?.loyaltyCurrency(forCurrency: viewModel?.currency)?.currency?.decimalDigits ?? 0),
                  NSDecimalNumber(decimal: decimalInput).doubleValue  <= viewModel?.loyaltyCurrency(forCurrency: viewModel?.currency)?.balanceAmount ?? 0,
                  NSDecimalNumber(decimal: decimalInput).doubleValue  <= viewModel?.transactionTotalAmount ?? 0
            else { return false }
            // We don't accept a value bigger than the max balance for the user with this currency
            
            // Apply a soft limit on the length of the amount
            return newString.count <= 8
        }
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = viewModel?.formattedAmount
    }
    
}
