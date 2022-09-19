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
    
    @objc public var tapCardPhoneListViewModel:TapCardPhoneBarListViewModel? {
        didSet{
            // Assign the list view model to it
            // Create the attached view
            tapCardTelecomPaymentView = nil
            tapCardTelecomPaymentView = .init()
            tapCardTelecomPaymentView?.lastReportedTapCard = .init()
            tapCardTelecomPaymentView?.tapCardPhoneListViewModel = tapCardPhoneListViewModel!
            // Assign the view delegate to self
            tapCardTelecomPaymentView?.viewModel = self
            shouldShow =  tapCardTelecomPaymentView?.tapCardPhoneListViewModel.dataSource.count ?? 0 > 0
        }
    }
    
    /// The delegate that wants to hear from the view on new data and events
    @objc public var delegate:TapCardTelecomPaymentProtocol?
    
    /**
     Creates a new view model to control the tabbar of payments icons + the card + the phone input view to be rendered
     - Parameter tapCardPhoneListViewModel: The view model that has the needed payment options and data source to display the payment view
     - Parameter tapCountry: Represents the country that telecom options are being shown for, used to handle country code and correct phone length
     */
    @objc public init(with tapCardPhoneListViewModel:TapCardPhoneBarListViewModel, and tapCountry:TapCountry?) {
        super.init()
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
     */
    @objc public func setCard(with card:TapCard,then focusCardNumber:Bool,shouldRemoveCurrentCard:Bool = true) {
        tapCardTelecomPaymentView?.lastReportedTapCard = card
        tapCardTelecomPaymentView?.cardInputView.setCardData(tapCard: card, then: focusCardNumber,shouldRemoveCurrentCard:shouldRemoveCurrentCard)
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
    @objc public func decideHintStatus(with tapCard:TapCard? = nil) -> TapHintViewStatusEnum {
        
        guard let tapCardTelecomPaymentView = tapCardTelecomPaymentView else {
            return .None
        }
        
        let tapCard:TapCard = tapCard ?? tapCardTelecomPaymentView.lastReportedTapCard
        
        var newStatus:TapHintViewStatusEnum = .None
        
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
