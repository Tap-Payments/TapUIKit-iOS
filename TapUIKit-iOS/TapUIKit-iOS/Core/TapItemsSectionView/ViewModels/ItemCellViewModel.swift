//
//  ItemCellViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class CommonDataModelsKit_iOS.TapAmountedCurrencyFormatter
import enum CommonDataModelsKit_iOS.CurrencyLocale
import enum CommonDataModelsKit_iOS.TapCurrencyCode
import class UIKit.UIColor
import class UIKit.UIFont
import struct UIKit.NSUnderlineStyle

/// A protocol used to intstuct the cell with actions needed to be done
internal protocol ItemCellViewModelDelegate {
    func reloadPriceLabels()
}

/// The view model that controlls the Items table cell
public class ItemCellViewModel: TapGenericTableCellViewModel {
    
    // MARK:- inner Variables
    /// The item model to be represented by this view model
    private var itemModel:ItemModel?
    /// The original currency, the item is created with
    private var originalCurrency:TapCurrencyCode?
    /// The new currency the user wants to convert to
    public var convertCurrency:TapCurrencyCode? {
        didSet{
            cellDelegate?.reloadData()
        }
    }
    /// The delegate that the associated cell needs to subscribe to know the events and actions it should do
    internal var cellDelegate:TapCellViewModelDelegate? {
        didSet{
            cellDelegate?.reloadData()
        }
    }
    
    // MARK:- Public methods
    public override func identefier() -> String {
        return "ItemTableViewCell"
    }
    
    override init() {
        
    }
    
    /**
     Creates a new ItemCellView model
     - Parameter itemModel: The item model to be represented by this view model
     - Parameter originalCurrency: The original currency, the item is created with
     */
    public init(itemModel:ItemModel, originalCurrency:TapCurrencyCode) {
        self.itemModel = itemModel
        self.originalCurrency = originalCurrency
        self.convertCurrency = originalCurrency
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
    
    /// Returns the formatted Item title to be displayed
    public func itemTitle() -> String {
        return (itemModel?.title ?? "").uppercased()
    }
    
    
    /// Returns the formatted Item quantity to be displayed
    public func itemQuantity() -> String {
        return "\(itemModel?.quantity ?? 1)"
    }
    
    /// Returns the formatted Item description to be displayed
    public func itemDesctiption() -> String {
        return itemModel?.description ?? ""
    }
    
    
    /// Returns the formatted Item price to be displayed
    public func itemPrice() -> String {
        // Check if we have a valid price, then format it based on the currency
        guard let itemModel = itemModel, let currency = convertCurrency else { return "" }
        let itemPrice = currency.convert(from: originalCurrency, for: itemModel.itemFinalPrice())
        let formatter = TapAmountedCurrencyFormatter {
            $0.currency = currency
            $0.locale = CurrencyLocale.englishUnitedStates
        }
        return formatter.string(from: itemPrice) ?? "KD0.000"
    }
    
    /// Returns the raw item price
    public func itemPrice() -> Double {
        // Check if we have a valid price, then format it based on the currency
        guard let itemModel = itemModel  else { return 0 }
        let itemPrice = itemModel.itemFinalPrice()
        
        return itemPrice
    }
    
    
    /**
     Returns the formatted Item discount to be displayed, will show text ONLY if the quantity is more than 1 or there is a discount applied
     - Parameter font: A font to apply to the generated string
     - Parameter fontColornt: A font color to apply to the generated string
     - Returns: Attributed string as follows : If no discount and no quantity, returns nothing. If only quantity returns the single item price, if discount returns the original price with a strike through
     */
    public func itemDiscount(with font:UIFont = UIFont.systemFont(ofSize: 12.0), and fontColor:UIColor = .lightGray) -> NSAttributedString {
        // Check if we have a valid discount OR the quantity is more than 1, then format it based on the currency
        guard let itemModel = itemModel,  let price = itemModel.price, let currency = convertCurrency else { return NSAttributedString.init(string: "") }
        guard itemModel.quantity ?? 0 > 1  || itemModel.discount?.value ?? 0 > 0 else { return NSAttributedString.init(string: "") }
        
        // In this case, then we will show a discount/single amount string
        let formatter = TapAmountedCurrencyFormatter {
            $0.currency = currency
            $0.locale = CurrencyLocale.englishUnitedStates
        }
        // Create the default value which will be the case of having only quantity, hence displaying the single item price
        let toBeDisplayedPrice:Double = price
        let attributedText : NSMutableAttributedString =  NSMutableAttributedString(string: formatter.string(from: toBeDisplayedPrice) ?? "KD0.000")
        attributedText.addAttributes([
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.foregroundColor : fontColor
        ], range: NSMakeRange(0, attributedText.length))
        
        // If there is no discount, then we only return the single item price
        guard let _ = itemModel.discount else { return attributedText }
        
        // In this case, there is a discount, hence, we need to show the original price, but we have to apply some more design attributes
        attributedText.addAttributes([
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.strikethroughColor: fontColor,
        ], range: NSMakeRange(0, attributedText.length))
        
        
        return attributedText
        
    }
    
    
}
