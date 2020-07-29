//
//  TapCardTelecomPaymentView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/7/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapCardInputKit_iOS
import CommonDataModelsKit_iOS
import TapCardVlidatorKit_iOS
import SimpleAnimation
import RxSwift
import RxCocoa

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
}


/// Represents a wrapper view that does the needed connections between cardtelecomBar, card input and telecom input
@objc public class TapCardTelecomPaymentView: UIView {

    // MARK:- Outlets
    /// Represents the content view that holds all the subviews
    @IBOutlet var contentView: UIView!
    /// Represents the tab bar that holds the list of segmented availble payment options
    @IBOutlet weak var tapCardPhoneListView: TapCardPhoneBarList!
    /// Represents the card input view
    @IBOutlet weak var cardInputView: TapCardInput! {
        didSet {
            cardInputView.delegate = self
        }
    }
    /// Represents the phone input view
    @IBOutlet weak var phoneInputView: TapPhoneInput! {
        didSet {
            phoneInputView.delegate = self
        }
    }
    
    /// last reported tap card
    internal var lastReportedTapCard:TapCard = .init()
    
    /// The delegate that wants to hear from the view on new data and events
    @objc public var delegate:TapCardTelecomPaymentProtocol?
    
    /// Computed value based on data source, will be nil if we have more than 1 brand. and will be the URL if the icon of the brand in case ONLY 1 brand
    internal var brandIconUrl:String? {
        if tapCardPhoneListViewModel.dataSource.count != 1 {
            return nil
        }else {
            return tapCardPhoneListViewModel.dataSource[0].tapCardPhoneIconUrl
        }
    }
    
    /// Used to collect any reactive garbage
    internal let disposeBag:DisposeBag = .init()
    
    /// Used to collect any reactive garbage
    internal var hintStatus:TapHintViewStatusEnum? {
        willSet{
            if newValue != hintStatus {reportHintStatus(with: newValue )}
        }
    }
    
    /// Used to remove the tab bar when there is only one payment option
    @IBOutlet weak var tabBarHeightConstraint: NSLayoutConstraint!
    
    /// The view model that has the needed payment options and data source to display the payment view
    @objc public var tapCardPhoneListViewModel:TapCardPhoneBarListViewModel = .init() {
        didSet {
            // On init, we need to:
            // Check if we have one brand or more
            configureTabBarHeight()
            // Setup the bar view with the passed payment options list
            tapCardPhoneListView.setupView(with: tapCardPhoneListViewModel)
            // Listen to changes in the view model
            bindObserverbales()
            // Reset all the selections and the input fields
            clearViews()
        }
    }
    
    /// Represents the country that telecom options are being shown for, used to handle country code and correct phone length
    @objc public var tapCountry:TapCountry? {
        didSet {
            // Ons et, we need to setup the phont input view witht the new country details
            phoneInputView.setup(with: tapCountry)
        }
    }
    
    /**
     Call this method when you  need to fill in the text fields with data.
     - Parameter tapCard: The TapCard that holds the data needed to be filled into the textfields
     */
    @objc public func setCard(with card:TapCard) {
        lastReportedTapCard = card
        cardInputView.setCardData(tapCard: card)
    }
    
    
    // Mark:- Init methods
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
        self.contentView = setupXIB()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = bounds
    }
    
    /// Decides whether we show the tab bar or not depending on number of payment options == 1 or > 1
    private func configureTabBarHeight() {
        
        if tapCardPhoneListViewModel.dataSource.count == 1 {
            // Then we need to hide the tab bar in this case and tell the card input that we will show only one icon :)
            tapCardPhoneListView.translatesAutoresizingMaskIntoConstraints = false
            tabBarHeightConstraint.constant = 0
            tapCardPhoneListView.isHidden = true
        }else {
            translatesAutoresizingMaskIntoConstraints = false
            heightAnchor.constraint(equalToConstant: requiredHeight()).isActive = true
        }
        layoutIfNeeded()
    }
    
    /// Creates connections and listen to events and data changes reactivly from the tab bar view model
    private func bindObserverbales() {
        // We need to know when a new segment is selected in the tab bar payment list, then we need to decide which input field should be shown
        tapCardPhoneListViewModel.selectedSegmentObserver
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (newSegmentID) in
                self?.showInputFor(for: newSegmentID)
            }).disposed(by: disposeBag)
    }
    
    /**
        Decides which delegate function about hint status to be called
        - Parameter status: The hint status to be reported. If nill, then we will insntruct the delegate to hide all the statuses
     */
    internal func reportHintStatus(with status:TapHintViewStatusEnum?) {
        // Check if there is a status to show, or we need to hide the hint view
        guard let status = status else {
            delegate?.hideHints()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetStatusNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetStatusNotification:TapActionButtonStatusEnum.ValidPayment] )
            return
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetStatusNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetStatusNotification:TapActionButtonStatusEnum.InvalidPayment] )
        delegate?.showHint(with: status)
    }
    
    /**
     Decides which hint status to be shown based on the validation statuses for the card input fields
     - Parameter tapCard: The current tap card input by the user
     */
    public func decideHintStatus(with tapCard:TapCard? = nil) -> TapHintViewStatusEnum? {
        let tapCard:TapCard = tapCard ?? lastReportedTapCard
        var newStatus:TapHintViewStatusEnum?
        
        // Check first if the card nnumber has data otherwise we are in the IDLE state
        guard let cardNumber:String = tapCard.tapCardNumber, cardNumber != "" else {
            return nil
        }
        // Let us get the validation status of the fields
        let (cardNumberValid,cardExpiryValid,cardCVVValid) = cardInputView.fieldsValidationStatuses()
        
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
            }
        }
        return newStatus
    }
    
    
    /**
     Decides which input field should be shown based on the selected segment id
     - Parameter segment: The id of the segment of payment options we need to show the associated input
     */
    private func showInputFor(for  segment:String) {
        if segment == "telecom" {
            cardInputView.fadeOut()
            phoneInputView.fadeIn()
            hintStatus = nil
        }else if segment == "cards" {
            cardInputView.fadeIn()
            phoneInputView.fadeOut()
            hintStatus = decideHintStatus(with: lastReportedTapCard)
        }
    }
    
    /// Used to reset all segment selections and input fields upon changing the data source
    private func clearViews() {
        // Reset the card input
        cardInputView.reset()
        // Re init the card input
        cardInputView.setup(for: .InlineCardInput, allowedCardBrands: tapCardPhoneListViewModel.dataSource.map{ $0.associatedCardBrand }.filter{ $0.brandSegmentIdentifier == "cards" }.map{ $0.rawValue }, cardIconUrl: brandIconUrl)
        // Reset any selection done on the bar layout
        tapCardPhoneListViewModel.resetCurrentSegment()
        
        delegate?.brandDetected(for: .unknown, with: .Invalid)
    }
    
    /**
     tells the caller the required height of this view based on the number of payment options available
     - Returns: 45 if one brand allowed and 95 otherwise
     */
    @objc public func requiredHeight() -> CGFloat {
        return tapCardPhoneListViewModel.dataSource.count > 1 ? 95 : 49
    }
}

extension TapCardTelecomPaymentView: TapCardInputProtocol {
    public func dataChanged(tapCard: TapCard) {
        hintStatus = decideHintStatus(with: tapCard)
    }
    
    public func cardDataChanged(tapCard: TapCard) {
        delegate?.cardDataChanged(tapCard: tapCard)
        lastReportedTapCard = tapCard
        hintStatus = decideHintStatus(with: tapCard)
        
    }
    
    public func brandDetected(for cardBrand: CardBrand, with validation: CrardInputTextFieldStatusEnum) {
        
        if validation == .Invalid || cardBrand == .unknown {
            tapCardPhoneListViewModel.resetCurrentSegment()
        }else if validation == .Incomplete {
            tapCardPhoneListViewModel.select(brand: cardBrand, with: false)
        }else if validation == .Valid {
            tapCardPhoneListViewModel.select(brand: cardBrand, with: true)
        }
        
        delegate?.brandDetected(for: cardBrand, with: validation)
    }
    
    public func scanCardClicked() {
        delegate?.scanCardClicked()
    }
    
    public func saveCardChanged(enabled: Bool) {
        
    }
}

extension TapCardTelecomPaymentView: TapPhoneInputProtocol {
    
    public func phoneBrandDetected(for cardBrand: CardBrand, with validation: CrardInputTextFieldStatusEnum) {
        
        if validation == .Invalid || cardBrand == .unknown {
            tapCardPhoneListViewModel.resetCurrentSegment()
        }else if validation == .Incomplete {
            tapCardPhoneListViewModel.select(brand: cardBrand, with: false)
        }else if validation == .Valid {
            tapCardPhoneListViewModel.select(brand: cardBrand, with: true)
        }
        
        delegate?.brandDetected(for: cardBrand, with: validation)
        if validation == .Valid {
            endEditing(true)
        }
    }
    
}

