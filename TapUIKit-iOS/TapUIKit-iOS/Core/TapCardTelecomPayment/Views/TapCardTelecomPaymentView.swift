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

public class TapCardTelecomPaymentView: UIView {

    // MARK:- Outlets
    /// Represents the content view that holds all the subviews
    @IBOutlet var contentView: UIView!
    /// Represents the content view that holds all the subviews
    @IBOutlet weak var tapCardPhoneListView: TapCardPhoneBarList!
    /// Represents the content view that holds all the subviews
    @IBOutlet weak var cardInputView: TapCardInput! {
        didSet {
            cardInputView.delegate = self
        }
    }
    @IBOutlet weak var phoneInputView: TapPhoneInput! {
        didSet {
            phoneInputView.delegate = self
        }
    }
    internal let disposeBag:DisposeBag = .init()
    
    
    public var tapCardPhoneListViewModel:TapCardPhoneBarListViewModel = .init() {
        didSet {
            tapCardPhoneListView.setupView(with: tapCardPhoneListViewModel)
            bindObserverbales()
            clearViews()
        }
    }
    
    public var tapCountry:TapCountry? {
        didSet {
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
    
    private func bindObserverbales() {
        tapCardPhoneListViewModel.selectedSegmentObserver
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (newSegmentID) in
                self?.showInputFor(for: newSegmentID)
            }).disposed(by: disposeBag)
    }
    
    
    private func showInputFor(for  segment:String) {
        if segment == "telecom" {
            cardInputView.fadeOut()
            phoneInputView.fadeIn()
        }else if segment == "cards" {
            cardInputView.fadeIn()
            phoneInputView.fadeOut()
        }
    }
    
    private func clearViews() {
        cardInputView.reset()
        cardInputView.setup(for: .InlineCardInput,allowedCardBrands: tapCardPhoneListViewModel.dataSource.map{ $0.associatedCardBrand.rawValue })
        tapCardPhoneListViewModel.resetCurrentSegment()
    }
}

extension TapCardTelecomPaymentView: TapCardInputProtocol {
    public func cardDataChanged(tapCard: TapCard) {
        
    }
    
    public func brandDetected(for cardBrand: CardBrand, with validation: CrardInputTextFieldStatusEnum) {
        
        //tapCardPhoneListViewModel.select(segment: cardBrand.brandSegmentIdentifier)
        
        
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

