//
//  CurrencyChipViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/18/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import CommonDataModelsKit_iOS

import class UIKit.UICollectionViewCell

/// The view model that controlls the SavedCard cell
@objc public class CurrencyChipViewModel: GenericTapChipViewModel {
    
    // MARK:- Variables
    public var currency:AmountedCurrency = .init(.KWD,0,"https://sandbox.payments.tap.company/images/currency/KWD.svg")
    /// The delegate that the associated cell needs to subscribe to know the events and actions it should do
    internal var cellDelegate:GenericCellChipViewModelDelegate?
    
    
    @objc public init(currency:AmountedCurrency = .init(.KWD,0,"https://sandbox.payments.tap.company/images/currency/KWD.svg")) {
        super.init(title: currency.currencySymbol, icon: currency.flag)
        self.currency = currency
    }
    
    @objc public init(currency:AmountedCurrency = .init(.KWD,0,"https://sandbox.payments.tap.company/images/currency/KWD.svg"), icon:String) {
        currency.flag = icon
        super.init(title: currency.currency.appleRawValue, icon: icon)
        self.currency = currency
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    // MARK:- Public methods
    public override func identefier() -> String {
        return "CurrencyChipCollectionViewCell"
    }
    
    
    public override func changedEditMode(to: Bool) {
        // When the view model get notified about the new editing mode status
        cellDelegate?.changedEditMode(to: to)
    }
    
    public override func didSelectItem() {
        cellDelegate?.changeSelection(with: true)
        viewModelDelegate?.currencyChip(for: self)
    }
    
    public override func didDeselectItem() {
        cellDelegate?.changeSelection(with: false)
    }
    
    // MARK:- Internal methods
    internal override  func correctCellType(for cell:GenericTapChip) -> GenericTapChip {
        return cell as! CurrencyChipCollectionViewCell
    }
}
