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

/// An external delegate to listen to events fired from the whole loyalty widget
@objc public protocol TapLoyaltyDelegate {
    
    /**
     Will be fired when a user enable/disable the usage of the loyalty
     - Parameter to: if true, then he enables it, false otherwise.
     */
    @objc func changeLoyaltyEnablement(to:Bool)
    
    /**
     Get notified when the user changes the loyalty amount he wants to redeem
     - Parameter to: The new amount defined by the user
     */
    @objc func changeLoyaltyAmount(to:Double)
    
}

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
    /// The hint view model to control the hint view in the UIView itself
    internal var hintViewModel:TapHintViewModel = .init() {
        didSet{
            // Set the correct displayable title in the warning
            hintViewModel.overrideTitle = hintWarningTitle
        }
    
    }
    /// The transaction total amount
    internal var transactionTotalAmount:Double
    /// The currenct amount
    internal var amount:Double
    /// The currency being used
    internal var currency:TapCurrencyCode
    /// Indicates the current status of enablind/gisabling the loyalty program
    @objc public var isEnabled:Bool = true
    /// An external delegate to listen to events fired from the whole loyalty widget
    @objc public var delegate:TapLoyaltyDelegate?
    // MARK: - Public normal swift variables
    /// Public reference to the loyalty view itself as UI that will be rendered
    @objc public var attachedView:TapLoyaltyView {
        return tapLoyaltyView ?? .init()
    }
    
    /**
     Init method with the needed data
     - Parameter loyaltyModel: The loyalty model to use to render
     - Parameter amount: The initial amount to use
     - Parameter transactionTotalAmount: The total amount in the transaction
     - Parameter currency: The currency we will pay with
     */
    public init(loyaltyModel:TapLoyaltyModel, amount:Double = 0, transactionTotalAmount:Double = 0, currency:TapCurrencyCode) {
        self.loyaltyModel = loyaltyModel
        self.amount = amount
        self.currency = currency
        self.transactionTotalAmount = transactionTotalAmount
        self.tapLoyaltyView = .init()
        super.init()
        defer{
            self.hintViewModel = .init(with: .WarningCVV)
            self.tapLoyaltyView?.changeViewModel(with: self)
        }
    }
    
    // MARK: - Internal
    /// Computes the minimum redemeption amount warning textual content
    internal var hintWarningTitle: String {
        return "Minimum redemption is \(loyaltyCurrency(forCurrency: currency)?.currency?.displaybaleSymbol ?? currency.appleRawValue) \(loyaltyCurrency(forCurrency: currency)?.minimumAmount ?? 0)"
    }
    /// Computes the header title text for the Loyalty view. Format is : Redeem ADCB TouchPoints
    internal var headerTitleText: String {
        return "Redeem \(loyaltyModel.loyaltyProgramName ?? "")"
    }
    
    /// Computes the header subtitle text for the Loyalty view. Format is : Balance: AED 520.00 (81,500 TouchPoints)
    internal var headerSubTitleText: String {
        return "Balance: \(loyaltyCurrency(forCurrency: currency)?.currency?.displaybaleSymbol ?? "") \(loyaltyCurrency(forCurrency: currency)?.balanceAmount ?? 0) (\(loyaltyModel.transactionsCount ?? "") \(loyaltyModel.loyaltyPointsName ?? ""))"
    }
    
    
    /// Computes the remaining points after redemption
    internal var pointsRemaningText: String {
        return "Remaining \(loyaltyModel.loyaltyPointsName ?? ""): \(loyaltyModel.numericTransactionCount - usedPoints)"
    }
    
    /// Computes the remaining amount to pay after redemption
    internal var amountRemaningText: String {
        return "Remaining amount to pay: \(loyaltyCurrency(forCurrency: currency)?.currency?.displaybaleSymbol ?? currency.appleRawValue) \(transactionTotalAmount - amount)"
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
    
    /// Checks if we have to show the terms button or not
    internal var shouldShowTermsButton:Bool {
        guard let _ = termsAndConditions else { return false }
        return true
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
    
    
    /// Decides the correct height for the widget
    /// it checks if the widget is enabled or not, then if we are showing a hint or not
    internal var widgetHeight:Double {
        // Define the row hiehg
        let rowHeight:Double = 44
        // If not enabled, we only show the first row, which is the header
        guard isEnabled else { return rowHeight }
        // Now, we have three constant views always : Header, Amount and Footer. At some points, we will show a hint view as well.
        return ((rowHeight*3) + (shouldShowHint ? rowHeight : 0)) + 32
    }
    
    
    /// As per the UI if the user is typing in amount, that is minimum than the allowed redemption value for this currency. We need to inform him
    internal var shouldShowHint:Bool {
        return amount < loyaltyCurrency(forCurrency: currency)?.minimumAmount ?? 0
    }
    
    
    /**
     Fetches the supporte loyaly csurrency
     - Parameter forCurrency: The currency you want the loyalty model for
     - Returns the loyalty model currency
     */
    internal func loyaltyCurrency(forCurrency:TapCurrencyCode?) -> LoyaltySupportedCurrency? {
        // We filter the supported currencies to get the currency code we are looking for and then fetch it
        return loyaltyModel.supportedCurrencies?.first{$0.currency?.currency == forCurrency}
    }
    
    /// Computes the current used points, but converting the plain amount into points using the conversion rate
    internal var usedPoints: Double {
        return amount * (loyaltyCurrency(forCurrency: currency)?.currency?.rate ?? 0)
    }
}


// MARK: Extensions and delegates
extension TapLoyaltyViewModel: TapLoyaltyHeaderDelegate {
    
    func termsAndConditionsClicked() {
        // Defensive code to make sure URL exists and valid
        if let url = termsAndConditions {
            UIApplication.shared.open(url)
        }
    }
    
    func enableLoyaltySwitch(enable: Bool) {
        // save it for firther access
        isEnabled = enable
        // instructs the loyalty view to update its ui based on the new selectoin
        tapLoyaltyView?.changeState(to: enable)
        // inform the delegae
        delegate?.changeLoyaltyEnablement(to: enable)
    }
    
}



extension TapLoyaltyViewModel: TapLoyaltyAmountViewDelegate {
    
    func loyaltyRedemptionAmountChanged(with newAmount: Double) {
        // change the view model amount
        amount = newAmount
        // inform the delegae
        delegate?.changeLoyaltyAmount(to: newAmount)
        // inform the view to show/hide the minimum amount warning
        tapLoyaltyView?.adjustHintViewConstraints()
        // inform the footer to change the consumed points and remaining amount
        tapLoyaltyView?.footerView.reloadData()
    }
    
}
