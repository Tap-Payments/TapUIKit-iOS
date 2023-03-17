//
//  ItemCellViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import CommonDataModelsKit_iOS
import class LocalisationManagerKit_iOS.TapLocalisationManager

import class UIKit.UIColor
import class UIKit.UIFont
import struct UIKit.NSUnderlineStyle

/// A protocol used to intstuct the cell with actions needed to be done
internal protocol ItemCellViewModelDelegate {
    //func reloadPriceLabels()
    func reloadDescription(with state:DescriptionState)
}

/// The view model that controlls the Items table cell
@objc public class ItemCellViewModel: TapGenericTableCellViewModel {
    
    // MARK:- inner Variables
    /// The item model to be represented by this view model
    private var itemModel:ItemModel?
    internal var delegate:ItemCellViewModelDelegate?
    
    /// The original currency, the item is created with
    private var originalCurrency:AmountedCurrency?
    private let sharedLocalisationManager = TapLocalisationManager.shared
    internal var descriptionState:DescriptionState = .hidden {
        didSet {
            delegate?.reloadDescription(with: descriptionState)
        }
    }
    
    /// The delegate that the associated cell needs to subscribe to know the events and actions it should do
    internal var cellDelegate:TapCellViewModelDelegate? {
        didSet{
            cellDelegate?.reloadData()
        }
    }
    
    // MARK:- Public Variables
    /// The new currency the user wants to convert to
    @objc public var convertCurrency:AmountedCurrency = .init(.undefined, 0, "") {
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
    @objc public init(itemModel:ItemModel, originalCurrency:AmountedCurrency) {
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
    
    /// Returns the formatted Item title to be displayed
    public func itemTitle() -> String {
        return (itemModel?.title ?? "").uppercased()
    }
    
    
    /// Returns the formatted Item quantity to be displayed
    public func itemQuantity() -> String {
        return "\(itemModel?.quantity ?? 1)"
    }
    
    /// Returns the formatted Item description to be displayed
    public func itemDesctiptionButtonTitle() -> String {
        // Nothing ig there is no description
        guard let _ = itemModel?.itemDescription else { return "" }
        return sharedLocalisationManager.localisedValue(for: (descriptionState == .hidden) ? "ItemList.showDesc" : "ItemList.hideDesc", with: TapCommonConstants.pathForDefaultLocalisation())
    }
    
    
    public func itemDescription() -> String {
        guard let description = itemModel?.itemDescription else { return "" }
        return (descriptionState == .shown) ? "\n\(description)\n" : ""
    }
    
    /// Returns the formatted Item price to be displayed
    public func itemPrice() -> String {
        // Check if we have a valid price, then format it based on the currency
        guard let itemModel = itemModel, convertCurrency.currency != .undefined else { return "" }
        
        let itemPrice = itemModel.itemFinalPrice(convertFromCurrency: originalCurrency, convertToCurrenct: convertCurrency)
        let formatter = TapAmountedCurrencyFormatter { [weak self] in
            $0.currency = self?.convertCurrency.currency ?? .USD
            $0.locale = CurrencyLocale.englishUnitedStates
            $0.currencySymbol = self!.convertCurrency.currency.appleRawValue
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
        // First let us get the x quantity text
        let quantityText:String = "x \(itemQuantity())"
        // Check if we have a valid discount OR the quantity is more than 1, then format it based on the currency
        guard let itemModel = itemModel, let price = itemModel.price , convertCurrency.currency != .undefined else { return NSAttributedString.init(string: "") }
        let itemPrice:String = itemPrice()
        guard itemModel.quantity > 1  || itemModel.discount?.count ?? 0 > 0 else { return NSAttributedString.init(string: "\(itemPrice) \(quantityText)") }
        
        let quantity = itemModel.quantity
        
        // In this case, then we will show a discount/single amount string
        let formatter = TapAmountedCurrencyFormatter { [weak self] in
            $0.currency = self?.convertCurrency.currency ?? .USD
            $0.locale = CurrencyLocale.englishUnitedStates
            $0.currencySymbol = self!.convertCurrency.currency.appleRawValue
        }
        // We need to calculate which price will show in the sub label.
        // Whether we will show the original price for one item, in case we only have quntity
        var correctPrice:Double = price
        // Or we will show the quantity*original price before discount
        if let _ = itemModel.discount {
            correctPrice = price * Double(quantity)
        }
        
        // Create the default value which will be the case of having only quantity, hence displaying the single item price
        let toBeDisplayedPrice:Double = convertCurrency.currency.convert(from: originalCurrency?.currency, for:correctPrice)
        let attributedText : NSMutableAttributedString =  NSMutableAttributedString(string: "\(formatter.string(from: toBeDisplayedPrice) ?? "KD0.000") \(quantityText)")
        attributedText.addAttributes([
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.foregroundColor : fontColor
        ], range: NSMakeRange(0, attributedText.length))
        
        // If there is no discount, then we only return the single item price
        guard let _ = itemModel.discount else { return attributedText }
        
        
        let discountAttributedText : NSMutableAttributedString =  NSMutableAttributedString(string: "\(sharedLocalisationManager.localisedValue(for: "ItemList.Discount", with: TapCommonConstants.pathForDefaultLocalisation())) ")
        discountAttributedText.addAttributes([
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.foregroundColor : fontColor
        ], range: NSMakeRange(0, discountAttributedText.length))
        
        
        
        // In this case, there is a discount, hence, we need to show the original price, but we have to apply some more design attributes
        attributedText.addAttributes([
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.strikethroughColor: fontColor,
        ], range: NSMakeRange(0, attributedText.length))
        
        discountAttributedText.append(attributedText)
        
        return discountAttributedText
    }
    
    // MARK:- Internal methods
    
    internal override  func correctCellType(for cell:TapGenericTableCell) -> TapGenericTableCell {
        return cell as! ItemTableViewCell
    }
    
    
    internal func toggleDiscriptionStatus() {
        descriptionState = (descriptionState == .shown) ? .hidden : .shown
    }
}


internal enum DescriptionState {
    case shown
    case hidden
}
