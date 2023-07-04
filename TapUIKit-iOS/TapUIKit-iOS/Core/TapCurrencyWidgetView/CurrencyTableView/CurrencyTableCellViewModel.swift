//
//  CurrencyTableCellViewModel.swift
//  TapUIKit-iOS
//
//  Created by MahmoudShaabanAllam on 01/06/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import CommonDataModelsKit_iOS
import class LocalisationManagerKit_iOS.TapLocalisationManager

import class UIKit.UIColor
import class UIKit.UIFont
import struct UIKit.NSUnderlineStyle

///// A protocol used to intstuct the cell with actions needed to be done
internal protocol CurrencyTableCellViewModelDelegate {

}

/// The view model that controlls the Items table cell
@objc public class CurrencyTableCellViewModel: TapGenericTableCellViewModel {
    
    // MARK:- inner Variables
    
    /// The  model to be represented by this view model
    internal var amountedCurrency: AmountedCurrency?
    internal var delegate: CurrencyTableCellViewModelDelegate?
    /// Defines if the table view is showing only 1 item to display different sizing
    internal var isSingleCell:Bool = false
 
    /// The delegate that the associated cell needs to subscribe to know the events and actions it should do
    internal var cellDelegate:TapCellViewModelDelegate? {
        didSet{
            cellDelegate?.reloadData()
        }
    }
    
    // MARK:- Public methods
    public override func identefier() -> String {
        return TapGenericCellType.CurrencyCell.nibName()
    }
    
    override init() {
        
    }
    
    /**
     Creates a new CurrencyTableCellViewModel
     - Parameter tapCurrencyCodeModel: The tap currency code model model to be represented by this view model
     - Parameter isSingleCell: Defines if the table view is showing only 1 item to display different sizing
     */
    @objc public init(amountedCurrency: AmountedCurrency, isSingleCell:Bool) {
        self.amountedCurrency = amountedCurrency
        self.isSingleCell = isSingleCell
    }
    
    
    public override func didSelectItem() {
        // When the view model get notified it's selected, the view model needs to inform the attached view so it re displays itself
        cellDelegate?.changeSelection(with: true)
        viewModelDelegate?.itemClicked(for: self)
    }
    
    public override func didDeselectItem() {
        // When the view model get notified it's deselected, the view model needs to inform the attached view so it re displays itself
        cellDelegate?.changeSelection(with: false)
        
    }
    
    /// Returns the formatted amount to be displayed
    public func amount() -> String {
        return "\(amountedCurrency?.currencySymbol ?? "")  \(amountedCurrency?.amount ?? 0.0)"
    }
    
    
    /// Returns the flag logo
    public func flag() -> String {
        return amountedCurrency?.flag ?? ""
    }

    
    // MARK:- Internal methods
    internal override  func correctCellType(for cell:TapGenericTableCell) -> TapGenericTableCell {
        return cell as! CurrencyTableViewCell
    }
    
}

