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
    /// Used to collect any reactive garbage
    internal let disposeBag:DisposeBag = .init()
    
    /// The view model that has the needed payment options and data source to display the payment view
    @objc public var tapCardPhoneListViewModel:TapCardPhoneBarListViewModel = .init() {
        didSet {
            // On init, we need to:
            
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
     Decides which input field should be shown based on the selected segment id
     - Parameter segment: The id of the segment of payment options we need to show the associated input
     */
    private func showInputFor(for  segment:String) {
        if segment == "telecom" {
            cardInputView.fadeOut()
            phoneInputView.fadeIn()
        }else if segment == "cards" {
            cardInputView.fadeIn()
            phoneInputView.fadeOut()
        }
    }
    
    /// Used to reset all segment selections and input fields upon changing the data source
    private func clearViews() {
        // Reset the card input
        cardInputView.reset()
        // Re init the card input
        cardInputView.setup(for: .InlineCardInput,allowedCardBrands: tapCardPhoneListViewModel.dataSource.map{ $0.associatedCardBrand.rawValue })
        // Reset any selection done on the bar layout
        tapCardPhoneListViewModel.resetCurrentSegment()
    }
}

extension TapCardTelecomPaymentView: TapCardInputProtocol {
    public func cardDataChanged(tapCard: TapCard) {
        
    }
    
    public func brandDetected(for cardBrand: CardBrand, with validation: CrardInputTextFieldStatusEnum) {
        
        if validation == .Invalid || cardBrand == .unknown {
            tapCardPhoneListViewModel.resetCurrentSegment()
        }else if validation == .Incomplete {
            tapCardPhoneListViewModel.select(brand: cardBrand, with: false)
        }else if validation == .Valid {
            tapCardPhoneListViewModel.select(brand: cardBrand, with: true)
        }
    }
    
    public func scanCardClicked() {
        
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
    }
    
}

