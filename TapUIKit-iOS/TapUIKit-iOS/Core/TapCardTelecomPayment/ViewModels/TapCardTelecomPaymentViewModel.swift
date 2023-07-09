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
import TapThemeManager2020

/// External protocol to allow the TapCardInput to pass back data and events to the parent UIViewController
@objc public protocol TapCardTelecomPaymentProtocol {
    /**
     This method will be called whenever the card data in the form has changed. It is being called in a live manner
     - Parameter tapCard: The TapCard model that hold sthe data the currently enetred by the user till now
     - Parameter cardStatusUI: The current state of the card input. Saved card or normal card
     */
    @objc func cardDataChanged(tapCard:TapCard,cardStatusUI:CardInputUIStatus)
    /**
     This method will be called whenever the a brand is detected based on the current data typed by the user in the card form.
     - Parameter cardBrand: The detected card brand
     - Parameter validation: Tells the validity of the detected brand, whether it is invalid, valid or still incomplete
     - Parameter cardStatusUI: The current state of the card input. Saved card or normal card
     - Parameter isCVVFocused: Will tell the focusing state of the CVV, will be used not to show CVV hint if the field is focused in the saved card view
     */
    @objc func brandDetected(for cardBrand:CardBrand,with validation:CrardInputTextFieldStatusEnum,cardStatusUI:CardInputUIStatus,isCVVFocused:Bool)
    
    
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
     This method will be called whenever the user change the status of the save card option for merchant or TAP
     - Parameter for saveCard: Defines for which save card type the action was done. Merchant or TAP
     - Parameter to enabled: The new status
     */
    @objc func saveCardChanged(for saveCardType:SaveCardType,to enabled:Bool)
    
    /// Fires when one of the card fields is now focused & none of them were focused before.
    @objc func cardFieldsAreFocused()
    
    /// Asks of the saved card option can be displayed
    /// - Returns: True means, no run time logic is forcing the card element not to show the save card option, otherwise it will forced not be shown.
    @objc func showSavedCard() -> Bool
}

/// Represents a view model to control the wrapper view that does the needed connections between cardtelecomBar, card input and telecom input
@objc public class TapCardTelecomPaymentViewModel: NSObject {
    
    // MARK:- Internal variables
    
    /// Reference to the tabbar of payments icons + the card + the phone input view to be rendered
    public var tapCardTelecomPaymentView:TapCardTelecomPaymentView?
    
    // MARK:- Public variables
    
    /// Public Reference to the tabbar of payments icons + the card + the phone input view to be rendered
    @objc public var attachedView:TapCardTelecomPaymentView {
        return tapCardTelecomPaymentView ?? .init()
    }
    /// Represents if the attached view should be visible or not, based on the existence of items inside the list
    @objc public var shouldShow:Bool = false
    
    /// Indicates whether or not to show the supported card brands list
    @objc public var showCardBrandsBar:Bool = true
    
    /// Indicates whether or not to show scan a card functionality
    @objc public var showScanner:Bool = true
    
    ///  Decide whether to show the normal card header or we need to add OR before the card title
    @objc public var cardHeaderType:TapHorizontalHeaderType = .CardInputTitle
    
    /// Indicates if the saved card switch is activated for Merchant
    @objc public var isMerchantSaveAllowed:Bool {
        return attachedView.saveCrdView.saveCardSwitch.isOn
    }
    
    /// If true, powered by tap will be visible under the card form
    @objc public var showPoweredByTapView:Bool = false
    
    /// Indicates if the saved card switch is activated for TAP
    @objc public var isTapSaveAllowed:Bool {
        return attachedView.saveCrdForTapView.isSavedCardEnabled
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
        tapCardTelecomPaymentView?.shouldShowSupportedBrands(!cardNumberValid && showCardBrandsBar)
    }
    
    /// Computes if the conditions to show the save card switch are met and we have to
    /// - Returns: Bool,Bool first for merchant save and second for Tap save
    internal func shouldShowSaveCardView() -> (Bool,Bool) {
        // Make sure that the view model enabled it and that user did enter a valid card data (all fields are valid)
        // Also we need to make sure we are in the saved card flow already
        guard saveCardType != .None,
              allCardFieldsValid(),
              attachedView.cardInputView.cardUIStatus != .SavedCard,
              attachedView.pre3DSLoadingView.alpha == 0,
              delegate?.showSavedCard() ?? true else { return (false,false) }
        // Then yes we should show the save card view :)
        return ((saveCardType == .All || saveCardType == .Merchant),(( saveCardType == .All || saveCardType == .Tap) && self.isMerchantSaveAllowed))
        
    }
    
    /// Decides whether to show or hide the save card, then instructs the view to show/hide it
    internal func showHideSaveCardView() {
        let (showMerchantSaveCard, showTapSaveCard) = shouldShowSaveCardView()
        tapCardTelecomPaymentView?.shouldShowSaveCardView(showMerchantSaveCard, showTapSaveCard)
    }
    
    /// The delegate that wants to hear from the view on new data and events
    @objc public var delegate:TapCardTelecomPaymentProtocol?
    /// Indicates whether or not to collect the card name in case of credit card payment
    @objc public var collectCardName:Bool = false
    /// Indicates if we have to pre fill the card holder name
    @objc public var preloadCardHolderName:String = ""
    /// Indicates whether or not to offer the save card and to which level
    @objc public var saveCardType:SaveCardType = .None
    /// Defines if the card info textfields should support RTL in Arabic mode or not
    @objc public var shouldFlip:Bool = true
    /// Indicates if the card form shall have its own background theming or it should be clear and reflect whatever is behind it
    @objc public var shouldThemeSelf:Bool = false
    /// Indicates whether or not the user can edit the card holder name field. Default is true
    @objc public var editCardName:Bool = true
    /**
     Creates a new view model to control the tabbar of payments icons + the card + the phone input view to be rendered
     - Parameter tapCardPhoneListViewModel: The view model that has the needed payment options and data source to display the payment view
     - Parameter tapCountry: Represents the country that telecom options are being shown for, used to handle country code and correct phone length
     - Parameter showSaveCardOption: Indicates whether or not to offer the save card switch when a valid card info is filled
     - Parameter shouldFlip: Defines if the card info textfields should support RTL in Arabic mode or not
     - Parameter shouldThemeSelf:ndicates if the card form shall have its own background theming or it should be clear and reflect whatever is behind it
     */
    @objc public init(with tapCardPhoneListViewModel:TapCardPhoneBarListViewModel, and tapCountry:TapCountry? = nil,collectCardName:Bool = false, showSaveCardOption:SaveCardType, shouldFlip:Bool, shouldThemeSelf:Bool) {
        super.init()
        self.collectCardName = collectCardName
        self.saveCardType = showSaveCardOption
        self.shouldFlip = shouldFlip
        self.tapCardPhoneListViewModel = tapCardPhoneListViewModel
        self.shouldThemeSelf = shouldThemeSelf
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
     - Parameter forceNoFocus: If it is true, then no field will be focused whatsoever
     */
    @objc public func setCard(with card:TapCard,then focusCardNumber:Bool,shouldRemoveCurrentCard:Bool = true,for cardUIStatus:CardInputUIStatus, forceNoFocus:Bool = false) {
        tapCardTelecomPaymentView?.lastReportedTapCard = card
        tapCardTelecomPaymentView?.cardInputView.setCardData(tapCard: card, then: focusCardNumber,shouldRemoveCurrentCard:shouldRemoveCurrentCard,for: cardUIStatus, forceNoFocus: forceNoFocus)
        tapCardTelecomPaymentView?.headerView.headerType = (cardUIStatus == .SavedCard) ? .SaveCardInputTitle : self.cardHeaderType
    }
    
    
    /// Saves the current card data before resetting if there will be a need to restore it afterwards
    @objc public func cacheCard() {
        tapCardTelecomPaymentView?.cardInputView.saveCardDataBeforeMovingToSavedCard()
    }
    
    /// Adds a view on top of the current card element
    /// - Parameter view: The view to add on top full size of the card element view
    /// - Parameter shouldFadeIn: The view added will fade in if it is true. Otherwise, it will appear right away
    @objc public func addFullScreen(view:UIView?, shouldFadeIn:Bool = false) {
        guard let view = view else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        
        attachedView.addSubview(view)
        attachedView.bringSubviewToFront(view)
        view.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(20)
            make.trailing.equalToSuperview()//.offset(-8)
            make.leading.equalToSuperview()//.offset(8)
        }
        view.layoutIfNeeded()
        attachedView.layoutIfNeeded()
        if shouldFadeIn {
            view.fadeIn(duration:0.5)
        }else{
            view.alpha = 1
        }
        attachedView.pre3DSLoadingView.fadeOut(duration:0.1)
    }
    
    
    /**
     Changes the card view to show/hide the pre loading status before showing a 3ds page inside the card
     - Parameter to: If true it will be visible and invisible otherwise
     */
    @objc public func change3dsLoadingStatus(to:Bool) {
        attachedView.change3dsLoadingStatus(to: to)
    }
    
    /**
     Will adjust the enablement of the card form baed on the given value.
     - Parameter to: If true, the card will be dimmed & if false it will look normal again
     - Parameter doPostLogic: If true, the card component will handle its ui and logic based on enabling the card. Otherwise, means it will be handled by the caller
     */
    @objc public func changeEnableStatus(to:Bool = true, doPostLogic:Bool = false) {
        // Check if it is neccessary
        guard (to && self.attachedView.stackView.alpha != 1) || (!to && self.attachedView.stackView.alpha != 0) else { return }
        
        UIView.animate(withDuration: 0.3) {
            if !to {
                self.attachedView.stackView.alpha = 0.4
                self.attachedView.stackView.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            }else{
                self.attachedView.stackView.alpha = 1
                self.attachedView.stackView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        } completion: { done in
            if to {
                //self.tapCardTelecomPaymentView?.cardInputView.cardChan
            }
        }
        
        // If we need to update post logic details based on enable settings
        if doPostLogic {
            postChangingEnablementLogic(enabled: to)
        }
    }
    
    /// Call this method to refire the notification of the current card brand after run time currency change coming from the currency card widget
    @objc public func reValidateTheCard() {
        // First we need to reinform the parent app that now the currency changed, hence, the validation of the card brand may change
        let (cardBrand, validationStatus) = attachedView.cardInputView.cardBrandWithStatus()
        guard let cardBrand = cardBrand else { return }
        delegate?.brandDetected(for: cardBrand , with: .init(status: validationStatus), cardStatusUI: .NormalCard, isCVVFocused: false)
        
        // Then, let us re-render the card element to see if it is ok now to show the save card switch or not
        let (merchantSaveCard,tapSaveCard) = shouldShowSaveCardView()
        attachedView.shouldShowSaveCardView(merchantSaveCard, tapSaveCard)
    }
    
    /// If we need to update post logic details based on enable settings
    internal func postChangingEnablementLogic(enabled:Bool) {
        // If we are disabling the card view
        if !enabled {
            // then we will have to hide the saved card component as well
            attachedView.saveCrdView.saveCardSwitch.setOn(false, animated: true)
            attachedView.saveCrdView.saveCardSwitchChanged(attachedView.saveCrdView.saveCardSwitch)
            // let us also unfocus all the card elements
            attachedView.cardInputView.endEditing(true)
            // let us store the current card data
            attachedView.cardInputView.saveCardDataBeforeMovingToSavedCard()
        }else{
            // If we are showing the card view
            // let us restore the state of the card
            attachedView.cardInputView.restoreCachedCardData()
        }
    }
    
    /**
     Call this method to display the saved card details for the user and prompt him to enter the CVV
     - Parameter savedCard: The saved card you want to validate before using
     */
    @objc public func setSavedCard(savedCard:SavedCard) {
        tapCardTelecomPaymentView?.cardInputView.setSavedCard(savedCard: savedCard)
        tapCardTelecomPaymentView?.shouldShowSupportedBrands(false)
        tapCardTelecomPaymentView?.headerView.headerType = .SaveCardInputTitle
    }
    
    /**
     Call this method when scanner is closed to reset the scanning icon
     */
    @objc public func scanerClosed() {
        tapCardTelecomPaymentView?.cardInputView.scannerClosed()
    }
    
    
    /**
     Decides which hint status to be shown based on the validation statuses for the card input fields
     - Parameter with tapCard: The current tap card input by the user
     - Parameter and cardUIStatus: The current card status whether a new card form or a saved card one
     - Parameter isCVVFocused: Will tell the focusing state of the CVV, will be used not to show CVV hint if the field is focused in the saved card view
     */
    @objc public func decideHintStatus(with tapCard:TapCard? = nil, and cardUIStatus:CardInputUIStatus = .NormalCard, isCVVFocused:Bool) -> TapHintViewStatusEnum {
        
        guard let tapCardTelecomPaymentView = tapCardTelecomPaymentView else {
            return .None
        }
        
        let tapCard:TapCard = tapCard ?? tapCardTelecomPaymentView.lastReportedTapCard
        
        var newStatus:TapHintViewStatusEnum = .None
        
        // If we are in saved card scenario, we only need to show hints based on CVV validty
        if cardUIStatus == .SavedCard {
            let (_,_,cardCVVValid,_) = tapCardTelecomPaymentView.cardInputView.fieldsValidationStatuses()
            // We will only display the CVV hint for saved card if CVV is not focused and the CVV is not valid
            guard !isCVVFocused, !cardCVVValid else { return .None }
            return .WarningCVV
        }
        
        // Check first if the card nnumber has data otherwise we are in the IDLE state
        guard let cardNumber:String = tapCard.tapCardNumber, cardNumber != "" else {
            return .Error
        }
        
        // Let us get the validation status of the fields
        let (cardNumberValid,cardExpiryValid,cardCVVValid,cardNameValid) = tapCardTelecomPaymentView.cardInputView.fieldsValidationStatuses()
        
        // Firs we check the validation result of the card number (has the highest priority)
        if !cardNumberValid {
            // If not valid, report a wrong card number hint,
            // AS per new requirement we will only display the error message if it is invalid not in the incomplete state
            if tapCardTelecomPaymentView.cardInputView.cardNumberValidationStatus() == .Invalid {
                newStatus = .ErrorCardNumber
            }
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
    public func saveCardChanged(for saveCardType: SaveCardType, to enabled: Bool) {
        // If the user switches off the save card for merchant switch, we will have to hide the save card for tap details
        if saveCardType == .Merchant {
            let (showSaveForMerchant,showSaveForTap) = shouldShowSaveCardView()
            attachedView.shouldShowSaveCardView(showSaveForMerchant,showSaveForTap)
        }
        delegate?.saveCardChanged(for: saveCardType, to: enabled)
    }
}

/// Defines which save card should be displayed
@objc public enum SaveCardType:Int,Codable,CaseIterable {
    /// Don't show the save card option at all
    case None
    /// Only display save card for merchant
    case Merchant
    /// Only display save card for TAP
    case Tap
    /// Display save card for merchant & TAP
    case All
    
    /// Retrusn string representation for the enum
    public func toString() -> String {
        switch self {
        case .None:
            return "None"
        case .Merchant:
            return "Merchant"
        case .Tap:
            return "Tap"
        case .All:
            return "All"
        }
    }
    
    public init(stringValue:String) {
        if stringValue.lowercased() == "none" {
            self = .None
        }else if stringValue.lowercased() == "merchant" {
            self = .Merchant
        }else if stringValue.lowercased() == "tap" {
            self = .Tap
        }else if stringValue.lowercased() == "all" {
            self = .All
        }else{
            self = .None
        }
    }
}
