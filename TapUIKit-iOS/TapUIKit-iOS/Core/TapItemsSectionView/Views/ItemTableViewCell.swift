//
//  ItemTableViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import SimpleAnimation

public class ItemTableViewCell: TapGenericTableCell {
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemDiscountPriceLabel: UILabel!
    @IBOutlet weak var itemQuantityView: UIView!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    @IBOutlet weak var separatorView: TapSeparatorView!
    
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    
    /// view model that will control the cell view
    var viewModel:ItemCellViewModel = .init() {
        didSet{
            // Upon assigning a new view model we attach ourslef as the delegate
            viewModel.cellDelegate = self
            if oldValue != viewModel {
                // We reload the cell data from the view model
                reload()
            }
        }
    }
    
    // MARK:- Internal methods
    
    func identefier() -> String {
        return viewModel.identefier()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        commonInit()
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            viewModel.didSelectItem()
        }else{
            viewModel.didDeselectItem()
        }
        // Configure the view for the selected state
    }
    
    
    internal func reload() {
        
        itemPriceLabel.fadeOut()
       
        itemDiscountPriceLabel.fadeOut(duration: 0.2){ [weak self] (_) in
            self?.itemPriceLabel.fadeIn()
            self?.itemDiscountPriceLabel.fadeIn()
            self?.itemDiscountPriceLabel.attributedText = self?.viewModel.itemDiscount(with: self!.itemDiscountPriceLabel.font, and: self!.itemDiscountPriceLabel.textColor)
            self?.itemPriceLabel.text = self?.viewModel.itemPrice()
        }
        
        itemTitleLabel.text = viewModel.itemTitle()
        itemDescriptionLabel.text = viewModel.itemDesctiption()
        itemQuantityLabel.text = viewModel.itemQuantity()
        
        self.layoutIfNeeded()
        
        adjustViews()
    }
    
    
    private func adjustViews() {
        /*if itemDescriptionLabel.text != "" {
            if !itemInfoStackView.arrangedSubviews.contains(itemDescriptionLabel) {
                itemInfoStackView.addArrangedSubview(itemDescriptionLabel)
            }
        }else {
            itemInfoStackView.removeArrangedSubview(itemDescriptionLabel)
        }*/
    }
    
    
    override func tapCellType() -> TapGenericCellType {
        return .ItemTableCell
    }
    
    internal override func configureCell(with viewModel: TapGenericTableCellViewModel) {
        // Defensive coding it is the correct view model type
        guard let correctTypeModel:ItemCellViewModel = viewModel as? ItemCellViewModel else { return }
        self.viewModel = correctTypeModel
    }
    
    /// The path to look for theme entry in
    private var themePath:String {
        get{
            return tapCellType().themePath()
        }
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        applyTheme()
    }
    
}


// Mark:- Theme methods
extension ItemTableViewCell {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        separatorView.tap_theme_backgroundColor = .init(keyPath: "itemsList.separatorColor")
        
        itemTitleLabel.tap_theme_font = .init(stringLiteral: "\(themePath).titleLabelFont",shouldLocalise:false)
        itemTitleLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).titleLabelColor")
        
        itemDescriptionLabel.tap_theme_font = .init(stringLiteral: "\(themePath).descLabelFont",shouldLocalise:false)
        itemDescriptionLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).descLabelColor")
        
        itemPriceLabel.tap_theme_font = .init(stringLiteral: "\(themePath).priceLabelFont",shouldLocalise:false)
        itemPriceLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).priceLabelColor")
        
        itemDiscountPriceLabel.tap_theme_font = .init(stringLiteral: "\(themePath).calculatedPriceLabelFont",shouldLocalise:false)
        itemDiscountPriceLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).calculatedPriceLabelColor")
        
        itemQuantityView.tap_theme_backgroundColor = .init(keyPath: "\(themePath).count.backgroundColor")
        itemQuantityView.layer.cornerRadius = itemQuantityView.frame.width / 2
        itemQuantityLabel.tap_theme_font = .init(stringLiteral: "\(themePath).count.countLabelFont",shouldLocalise:false)
        itemQuantityLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).count.countLabelColor")
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        
        guard lastUserInterfaceStyle != self.traitCollection.userInterfaceStyle else {
            return
        }
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        applyTheme()
    }
}


extension ItemTableViewCell:TapCellViewModelDelegate {
   
    func changeSelection(with status: Bool) {
        // In items case, no specific UI upon selection
        return
    }
    
    func reloadData() {
        reload()
    }
}
