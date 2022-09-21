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
    public var loyaltyModel:TapLoyaltyModel?
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
    internal var amount:Double = 0
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
     - Parameter transactionTotalAmount: The total amount in the transaction
     - Parameter currency: The currency we will pay with
     */
    public init(loyaltyModel:TapLoyaltyModel? = nil, transactionTotalAmount:Double = 0, currency:TapCurrencyCode = .undefined) {
        self.loyaltyModel = loyaltyModel
        self.currency = currency
        self.transactionTotalAmount = transactionTotalAmount
        super.init()
        defer{
            self.transactionTotalAmount = transactionTotalAmount
            self.hintViewModel = .init(with: .WarningCVV)
            self.tapLoyaltyView = .init()
            self.tapLoyaltyView?.changeViewModel(with: self)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) { [weak self] in
                self?.refreshData()
            }
        }
    }
    
    // MARK: - Internal
    /// Computes the minimum redemeption amount warning textual content
    internal var hintWarningTitle: String {
        return "\(sharedLocalisationManager.localisedValue(for: "TapLoyaltySection.hintView.minimumWarning", with: TapCommonConstants.pathForDefaultLocalisation())) \(loyaltyCurrency(forCurrency: currency)?.currency?.displaybaleSymbol ?? currency.appleRawValue) \(loyaltyCurrency(forCurrency: currency)?.minimumAmount ?? 0)"
    }
    /// Computes the header title text for the Loyalty view. Format is : Redeem ADCB TouchPoints
    internal var headerTitleText: String {
        return "\(sharedLocalisationManager.localisedValue(for: "TapLoyaltySection.headerView.redeem", with: TapCommonConstants.pathForDefaultLocalisation())) \(loyaltyModel?.loyaltyProgramName ?? "")"
    }
    
    /// Computes the header subtitle text for the Loyalty view. Format is : Balance: AED 520.00 (81,500 TouchPoints)
    internal var headerSubTitleText: String {
        if transactionTotalAmount < loyaltyCurrency(forCurrency: currency)?.minimumAmount ?? 0 {
            return "\(loyaltyCurrency(forCurrency: currency)?.currency?.displaybaleSymbol ?? "") \(loyaltyCurrency(forCurrency: currency)?.minimumAmount ?? 0) \(sharedLocalisationManager.localisedValue(for: "TapLoyaltySection.headerView.lessThanMinimum", with: TapCommonConstants.pathForDefaultLocalisation()))"
        }else{
            return "\(sharedLocalisationManager.localisedValue(for: "TapLoyaltySection.headerView.balance", with: TapCommonConstants.pathForDefaultLocalisation())): \(loyaltyCurrency(forCurrency: currency)?.currency?.displaybaleSymbol ?? "") \(loyaltyCurrency(forCurrency: currency)?.balanceAmount ?? 0) (\(loyaltyModel?.transactionsCount ?? "") \(loyaltyModel?.loyaltyPointsName ?? ""))"
        }
    }
    
    
    /// Computes the remaining points localisation
    internal var pointsRemaningText: String {
        return "\(sharedLocalisationManager.localisedValue(for: "TapLoyaltySection.footerView.points", with: TapCommonConstants.pathForDefaultLocalisation())) " //\(loyaltyModel.loyaltyPointsName ?? ""): \(loyaltyModel.numericTransactionCount - usedPoints)"
    }
    
    /// The points program name
    internal var pointsNameText:String {
        return "\(loyaltyModel?.loyaltyPointsName ?? "") : "
    }
    
    /// Computes the remaining points after redeeming the current amount
    internal var remainingPoints:String {
        let totalPoints:Int = loyaltyModel?.numericTransactionCount ?? 0
        let remainingPoints:Int = Int(totalPoints - usedPoints)
        return "\(remainingPoints)"
    }
    
    /// Computes the remaining amount to pay after redemption
    internal var amountRemaningText: String {
        // let us format the remaining amount as per the currency
        let amountRmaining:Double = transactionTotalAmount - amount
        let formatter = TapAmountedCurrencyFormatter { [weak self] in
            $0.currency = self?.loyaltyCurrency(forCurrency: self?.currency)?.currency?.currency ?? .USD
            $0.locale = CurrencyLocale.englishUnitedStates
            $0.currencySymbol = (self?.loyaltyCurrency(forCurrency: self?.currency)?.currency?.currency ?? .USD).appleRawValue
            $0.showCurrencySymbol = false
            $0.hasGroupingSeparator = false
            $0.currencySymbol = ""
        }
        
        return "\(sharedLocalisationManager.localisedValue(for: "TapLoyaltySection.footerView.amount", with: TapCommonConstants.pathForDefaultLocalisation())): \(loyaltyCurrency(forCurrency: currency)?.currency?.displaybaleSymbol ?? currency.appleRawValue) \(formatter.string(from: amountRmaining) ?? "\(amountRmaining)")"
    }
    
    /// Decides what is the url if any to open for T&C for this specific loyalty. Returns nil if no link provided or malformed
    internal var termsAndConditions: URL? {
        // Check if the backend passed a link for t&c and it is a valid url
        guard let nonNullTermsAndConditionsLink:String = loyaltyModel?.termsConditionsLink,
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
        guard let nonNullLogoLink:String = loyaltyModel?.bankLogo,
              let nonNullLogoURL:URL = URL(string: nonNullLogoLink) else {
            return nil
        }
        return nonNullLogoURL
    }
    
    
    /// Decides the correct height for the widget
    /// it checks if the widget is enabled or not, then if we are showing a hint or not
    internal var widgetHeight:Double {
        // Define the margins top+bottom
        let expandedCasemargins:Double = 48
        let shrinkedCaseMargins:Double = 16
        // Define the row hiehg
        let rowHeight:Double = 44
        // If not enabled, we only show the first row, which is the header
        guard isEnabled else { return rowHeight + shrinkedCaseMargins }
        // Now, we have three constant views always : Header, Amount and Footer. At some points, we will show a hint view as well.
        return ((rowHeight*4)) + expandedCasemargins
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
        return loyaltyModel?.supportedCurrencies?.first{$0.currency?.currency == forCurrency}
    }
    
    /// Computes the current used points, but converting the plain amount into points using the conversion rate
    internal var usedPoints: Int {
        return Int(amount * (loyaltyCurrency(forCurrency: currency)?.currency?.rate ?? 0))
    }
    
    /// Computes the correctly formatted amount regards the current selected currency
    internal var formattedAmount:String {
        // In this case, then we will show a discount/single amount string
        let formatter = TapAmountedCurrencyFormatter { [weak self] in
            $0.currency = self?.loyaltyCurrency(forCurrency: self?.currency)?.currency?.currency ?? .USD
            $0.locale = CurrencyLocale.englishUnitedStates
            $0.currencySymbol = (self?.loyaltyCurrency(forCurrency: self?.currency)?.currency?.currency ?? .USD).appleRawValue
            $0.showCurrencySymbol = false
            $0.hasGroupingSeparator = false
            $0.currencySymbol = ""
        }
        return formatter.string(from: amount) ?? "\(amount)"
    }
    
    
    
    // MARK: Public functions
    
    /**
     Call it to change the currency and hence, the transaction amount at run time.
     - Parameter currency: The new currency the user is trying to pay with now
     - Parameter transactionAmount: If you want to update the transaction amount as well. Default is 0, then we will use the previos/current one
     */
    @objc public func change(currency:TapCurrencyCode, transactionAmount:Double = 0) {
        // Set the new currency
        self.currency = currency
        // Get the loyalty currency and the needed data
        // Defensive code to make sure we have a currency
        guard let nonNullLoyaltyCurrency = loyaltyCurrency(forCurrency: currency) else { return }
        // Set the new transaction amount to the converted amount from the new currency
        self.transactionTotalAmount = transactionAmount != 0 ? transactionAmount : nonNullLoyaltyCurrency.currency?.amount ?? 0
        // Time to refresh the view model + the view to reflect the new currency and the new transaction amount
        refreshData()
    }
    
    /**
     The method will do the post logic after setting the transaction amount and the selected currency.
     Will disable if the transaction amount is less than the minimum amount.
     Will set the initial redeem amount to the max allowed balance if transaction amount is bigger.
     */
    @objc public func refreshData() {
        // calculate the initial amount
        calculateInitialAmount()
        // decide the enablity of the loyalty view
        
        // We will have to disable the loyalty widget if the transaction amount is less than the minimum allowed amount to redeem
        if amount ==  0 {
            // Disable the widget
            attachedView.isUserInteractionEnabled = false
            isEnabled = false
        }else{
            attachedView.isUserInteractionEnabled = true
            isEnabled = true
        }
        // call the delegate with the new changes
        delegate?.changeLoyaltyAmount(to: amount)
        delegate?.changeLoyaltyEnablement(to: isEnabled)
        tapLoyaltyView?.resetData()
        tapLoyaltyView?.changeState(to: attachedView.isUserInteractionEnabled)
    }
    
    /// Computes the initial amount based on comparing the amx allowed balance and the total transaction amount
    internal func calculateInitialAmount() {
        // get the loyalty model related to the current currency
        
        // Defensive code to make sure we have a currency
        guard let nonNullLoyaltyCurrency = loyaltyCurrency(forCurrency: currency) else { return }
        
        // Get the max data required to make the checks
        // The max amount for the currency
        let maxAllowedAmountForCurrency = nonNullLoyaltyCurrency.balanceAmount ?? 0
        // The min amount for the currency
        let minAllowedAmountForCurrency = nonNullLoyaltyCurrency.minimumAmount ?? 0
        
        // We will have to disable the loyalty widget if the transaction amount is less than the minimum allowed amount to redeem
        if minAllowedAmountForCurrency > transactionTotalAmount {
            amount = 0
        }else{
            amount = min(transactionTotalAmount,maxAllowedAmountForCurrency)
        }
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
