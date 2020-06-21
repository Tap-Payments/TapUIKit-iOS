//
//  ItemCellViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//
/// The view model that controlls the Items table cell
import class LocalisationManagerKit_iOS.TapLocalisationManager
import class CommonDataModelsKit_iOS.TapCommonConstants
import class CommonDataModelsKit_iOS.TapAmountedCurrencyFormatter
import enum CommonDataModelsKit_iOS.CurrencyLocale
import enum CommonDataModelsKit_iOS.TapCurrencyCode


public class ItemCellViewModel: TapGenericTableCellViewModel {
    
    // MARK:- Variables
    /// The item model to be represented by this view model
    private var itemModel:ItemModel?
    /// The original currency, the item is created with
    private var originalCurrency:TapCurrencyCode?
    /// The item model to be represented by this view model
    private var newCurrency:TapCurrencyCode?
    
    
    
    /// The delegate that the associated cell needs to subscribe to know the events and actions it should do
    internal var cellDelegate:TapCellViewModelDelegate?
    
    // MARK:- Public methods
    
    public override func identefier() -> String {
        return "ItemTableViewCell"
    }
    
    public init(itemModel:ItemModel) {
        self.itemModel = itemModel
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
    
    // MARK:- Internal methods
    
    internal override  func correctCellType(for cell:TapGenericTableCell) -> TapGenericTableCell {
        return cell as! ItemTableViewCell
    }
    
    
    internal func itemTitle() -> String {
        return itemModel?.title ?? ""
    }
    
    internal func itemDesctiption() -> String {
        return itemModel?.description ?? ""
    }
    
    
    internal func itemPriceLabel() -> String {
        guard let itemModel = itemModel, let itemPrice = itemModel.price else { return "" }
        
    }
    
    
}
