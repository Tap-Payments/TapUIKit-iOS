//
//  TapCardTelecomPaymentViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 8/4/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import TapCardInputKit_iOS
import CommonDataModelsKit_iOS
import TapCardVlidatorKit_iOS

/// External protocol to allow the TapCardInput to pass back data and events to the parent UIViewController
@objc public protocol TapCardTelecomPaymentProtocol {
    /**
     This method will be called whenever the card data in the form has changed. It is being called in a live manner
     - Parameter tapCard: The TapCard model that hold sthe data the currently enetred by the user till now
     */
    @objc func cardDataChanged(tapCard:TapCard)
    /**
     This method will be called whenever the a brand is detected based on the current data typed by the user in the card form.
     - Parameter cardBrand: The detected card brand
     - Parameter validation: Tells the validity of the detected brand, whether it is invalid, valid or still incomplete
     */
    @objc func brandDetected(for cardBrand:CardBrand,with validation:CrardInputTextFieldStatusEnum)
    
    
    /// This method will be called once the user clicks on Scan button
    @objc func scanCardClicked()
    
    /// This method will be called once the user clicks on close saved card button
    @objc func closeSavedCardClicked()
    
    /**
     This method will be called whenever there is a need to show a certain hint below the card phone input form
     - Parameter status: The status of the required hint to be shown
     */
    @objc func showHint(with status:TapHintViewStatusEnum)
    
    ///This method will be called whenever there is no need to show ay hints views
    @objc func hideHints()
    
    /**This method will be called whenever the user tries to enter new digits inside the card number, then we need to the delegate to tell us if we can complete the card number.
     - Parameter with cardNumber: The card number after changes.
     - Returns: True if the entered card number till now less than 6 digits or the prefix matches the allowed types (credit or debit)
     */
    @objc func shouldAllowChange(with cardNumber:String) -> Bool
    
    /**
     This method will be called whenever the user change the status of the save card option
     - Parameter enabled: Will be true if the switch is enabled and false otherwise
     */
    @objc func saveCardChanged(enabled:Bool)
}

/// Represents a view model to control the wrapper view that does the needed connections between cardtelecomBar, card input and telecom input
@objc public class TapCardTelecomPaymentViewModel: NSObject {
    
    // MARK:- Internal variables
    
    /// Reference to the tabbar of payments icons + the card + the phone input view to be rendered
    internal var tapCardTelecomPaymentView:TapCardTelecomPaymentView?
    
    // MARK:- Public variables
    
    /// Public Reference to the tabbar of payments icons + the card + the phone input view to be rendered
    @objc public var attachedView:TapCardTelecomPaymentView {
        return tapCardTelecomPaymentView ?? .init()
    }
    /// Represents if the attached view should be visible or not, based on the existence of items inside the list
    @objc public var shouldShow:Bool = false
    
    /// Indicates if the saved card switch is activated
    @objc public var isMerchantSaveAllowed:Bool {
        return attachedView.saveCrdView.saveCardSwitch.isOn
    }
    
    @objc public var tapCardPhoneListViewModel:TapCardPhoneBarListViewModel? {
        didSet{
            // Assign the list view model to it
            // Create the attached view
            tapCardTelecomPaymentView = nil
            tapCardTelecomPaymentView = .init()
            tapCardTelecomPaymentView?.lastReportedTapCard = .init()
            // Assign the view delegate to self
            tapCardTelecomPaymentView?.viewModel = self
            tapCardTelecomPaymentView?.saveCrdView.delegate = self
            tapCardTelecomPaymentView?.tapCardPhoneListViewModel = tapCardPhoneListViewModel!
            shouldShow =  tapCardTelecomPaymentView?.tapCardPhoneListViewModel.dataSource.count ?? 0 > 0
        }
    }
    
    /// Decides whether to show or hide the supported brands bar. Based on the validty of the card data
    internal func decideVisibilityOfSupportedBrandsBar() {
        // Then we need to hide it. The user did enter a full valid card data
        // Otherwise, We will have to show it. The user didn't yet type in a full valid card data
        let (cardNumberValid,_,_,_) = tapCardTelecomPaymentView?.cardInputView.fieldsValidationStatuses() ?? (false,false,false,false)
        tapCardTelecomPaymentView?.shouldShowSupportedBrands(!cardNumberValid)
    }
    
    /// Computes if the conditions to show the save card switch are met and we have to
    internal func shouldShowSaveCardView() -> Bool {
        // Make sure that the view model enabled it and that user did enter a valid card data (all fields are valid)
        // Also we need to make sure we are in the saved card flow already
        guard showSaveCardOption,
              allCardFieldsValid(),
              attachedView.cardInputView.cardUIStatus != .SavedCard else { return false }
        // Then yes we should show the save card view :)
        return true
    }
    
    /// Decides whether to show or hide the save card, then instructs the view to show/hide it
    internal func showHideSaveCardView() {
        tapCardTelecomPaymentView?.shouldShowSaveCardView(shouldShowSaveCardView())
    }
    
    /// The delegate that wants to hear from the view on new data and events
    @objc public var delegate:TapCardTelecomPaymentProtocol?
    /// Indicates whether or not to collect the card name in case of credit card payment
    @objc public var collectCardName:Bool = false
    /// Indicates whether or not to offer the save card switch when a valid card info is filled
    @objc public var showSaveCardOption:Bool = false
    
    /**
     Creates a new view model to control the tabbar of payments icons + the card + the phone input view to be rendered
     - Parameter tapCardPhoneListViewModel: The view model that has the needed payment options and data source to display the payment view
     - Parameter tapCountry: Represents the country that telecom options are being shown for, used to handle country code and correct phone length
     - Parameter showSaveCardOption: Indicates whether or not to offer the save card switch when a valid card info is filled
     */
    @objc public init(with tapCardPhoneListViewModel:TapCardPhoneBarListViewModel, and tapCountry:TapCountry? = nil,collectCardName:Bool = false, showSaveCardOption:Bool) {
        super.init()
        self.collectCardName = collectCardName
        self.showSaveCardOption = showSaveCardOption
        self.tapCardPhoneListViewModel = tapCardPhoneListViewModel
        tapCardTelecomPaymentView?.tapCountry = tapCountry
    }
    
    /**
     Changes the country of the telecom operatorrs list
     - Parameter tapCountry: Represents the country that telecom options are being shown for, used to handle country code and correct phone length
     */
    @objc public func changeTapCountry(to tapCountry:TapCountry?) {
        tapCardTelecomPaymentView?.tapCountry = tapCountry
    }
    
    @objc override public init() {
        super.init()
    }
    
    /**
     Call this method when you  need to fill in the text fields with data.
     - Parameter tapCard: The TapCard that holds the data needed to be filled into the textfields
     - Parameter then focusCardNumber: Indicate whether we need to focus the card number after setting the card data
     - Parameter for cardUIStatus: Indicates whether the given card is from a normal process like scanning or to show the special UI for a saved card flow
     */
    @objc public func setCard(with card:TapCard,then focusCardNumber:Bool,shouldRemoveCurrentCard:Bool = true,for cardUIStatus:CardInputUIStatus) {
        tapCardTelecomPaymentView?.lastReportedTapCard = card
        tapCardTelecomPaymentView?.cardInputView.setCardData(tapCard: card, then: focusCardNumber,shouldRemoveCurrentCard:shouldRemoveCurrentCard,for: cardUIStatus)
    }
    
    
    /**
     Call this method to display the saved card details for the user and prompt him to enter the CVV
     - Parameter savedCard: The saved card you want to validate before using
     */
    @objc public func setSavedCard(savedCard:SavedCard) {
        tapCardTelecomPaymentView?.cardInputView.setSavedCard(savedCard: savedCard)
        tapCardTelecomPaymentView?.shouldShowSupportedBrands(false)
    }
    
    /**
     Call this method when scanner is closed to reset the scanning icon
     */
    @objc public func scanerClosed() {
        tapCardTelecomPaymentView?.cardInputView.scannerClosed()
    }
    
    
    /**
     Decides which hint status to be shown based on the validation statuses for the card input fields
     - Parameter tapCard: The current tap card input by the user
     */
    @objc public func decideHintStatus(with tapCard:TapCard? = nil, and cardUIStatus:CardInputUIStatus = .NormalCard) -> TapHintViewStatusEnum {
        
        guard let tapCardTelecomPaymentView = tapCardTelecomPaymentView else {
            return .None
        }
        
        let tapCard:TapCard = tapCard ?? tapCardTelecomPaymentView.lastReportedTapCard
        
        var newStatus:TapHintViewStatusEnum = .None
        
        // If we are in saved card scenario, we only need to show hints based on CVV validty
        if cardUIStatus == .SavedCard {
            let (_,_,cardCVVValid,_) = tapCardTelecomPaymentView.cardInputView.fieldsValidationStatuses()
            if !cardCVVValid {
                newStatus = .WarningCVV
            }
            return newStatus
        }
        
        // Check first if the card nnumber has data otherwise we are in the IDLE state
        guard let cardNumber:String = tapCard.tapCardNumber, cardNumber != "" else {
            return .Error
        }
        // Let us get the validation status of the fields
        let (cardNumberValid,cardExpiryValid,cardCVVValid,cardNameValid) = tapCardTelecomPaymentView.cardInputView.fieldsValidationStatuses()
        
        // Firs we check the validation result of the card number (has the highest priority)
        if !cardNumberValid {
            // If not valid, report a wrong card number hint
            newStatus = .ErrorCardNumber
        }else {
            // Now we need to check if there is text in CVV and Expiry
            if !cardExpiryValid {
                newStatus = .WarningExpiryCVV
            }else if !cardCVVValid {
                newStatus = .WarningCVV
            }else if !cardNameValid {
                newStatus = .WarningName
            }
        }
        return newStatus
    }
    
    
    /**
     Decides if each field is a valid one or not
     - Returns: tuble of (card number valid or not, card expiry valid or not, card cvv is valid or not, card name is valid or not)
     */
    public func fieldsValidationStatuses() -> (Bool,Bool,Bool, Bool) {
        return tapCardTelecomPaymentView?.cardInputView.fieldsValidationStatuses() ?? (false,false,false,false)
    }
    
    /**
     Decides if each field is a valid one or not
     - Returns: tuble of (card number valid or not, card expiry valid or not, card cvv is valid or not, card name is valid or not)
     */
    @objc public func allCardFieldsValid() -> Bool {
        guard let tapCardTelecomPaymentView = tapCardTelecomPaymentView else {
            return false
        }
        // Let us get the validation status of the fields
        let (cardNumberValid,cardExpiryValid,cardCVVValid,cardNameValid) = tapCardTelecomPaymentView.cardInputView.fieldsValidationStatuses()
        // Check if all fields are valid
        return cardCVVValid && cardNameValid && cardNumberValid && cardExpiryValid
    }
    
}


extension TapCardTelecomPaymentViewModel: TapSaveCardViewDelegate {
    public func saveCardChanged(enabled: Bool) {
        delegate?.saveCardChanged(enabled: enabled)
    }
}
