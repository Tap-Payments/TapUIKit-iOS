//
//  ItemTableViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
// import SimpleAnimation
import LocalisationManagerKit_iOS

/// Represents the item table view cell that will show the items inside the items table view screen
@objc public class ItemTableViewCell: TapGenericTableCell {
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemDiscountPriceLabel: UILabel!
    @IBOutlet weak var itemQuantityView: UIView!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    @IBOutlet weak var itemDescrriptionView: UIView!
    @IBOutlet weak var itemDescLabel: UILabel!
    @IBOutlet weak var separatorView: TapSeparatorView!
    
    @IBOutlet var toBeLocalizedDirectionViews: [UIView]!
    
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    
    /// view model that will control the cell view
    var viewModel:ItemCellViewModel = .init() {
        didSet{
            // Upon assigning a new view model we attach ourslef as the delegate
            viewModel.cellDelegate = self
            viewModel.delegate = self
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
    
    /// The method will be fires when the user clicks on show and hide description button
    @IBAction func showDescriptionClicked(_ sender: Any) {
        viewModel.toggleDiscriptionStatus()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        self.contentView.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        toBeLocalizedDirectionViews.forEach{ $0.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight }
        
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        commonInit()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Apply the correct logic based on the selection state and inform the view model
        if selected {
            viewModel.didSelectItem()
        }else{
            viewModel.didDeselectItem()
        }
        // Configure the view for the selected state
    }
    
    /// Reload the cell view with new data coming in
    internal func reload() {
        // Fade oit the item price label
        let animationDuration:Double = 0.25
        itemPriceLabel.fadeOut(duration: animationDuration)
        itemDiscountPriceLabel.fadeOut(duration: animationDuration){ [weak self] (_) in
            // Now it is time to how the new data after fading in
            self?.itemPriceLabel.fadeIn(duration: animationDuration)
            self?.itemDiscountPriceLabel.fadeIn(duration: animationDuration)
            self?.itemDiscountPriceLabel.attributedText = self?.viewModel.itemDiscount(with: self!.itemDiscountPriceLabel.font, and: self!.itemDiscountPriceLabel.textColor)
            self?.itemPriceLabel.text = self?.viewModel.itemPrice()
        }
        // Now let the values be attached to the labels and the views
        itemTitleLabel.text = viewModel.itemTitle()
        itemDescriptionLabel.text = viewModel.itemDesctiptionButtonTitle()
        itemQuantityLabel.text = viewModel.itemQuantity()
        itemDescLabel.text = viewModel.itemDescription()
        itemDescLabel.sizeToFit()
        self.layoutIfNeeded()
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
        
        itemTitleLabel.tap_theme_font = .init(stringLiteral: "\(themePath).titleLabelFont")
        itemTitleLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).titleLabelColor")
        
        itemDescriptionLabel.tap_theme_font = .init(stringLiteral: "\(themePath).descLabelFont")
        itemDescriptionLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).descLabelColor")
        
        itemDescLabel.tap_theme_font = .init(stringLiteral: "\(themePath).descLabelFont")
        itemDescLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).descLabelColor")
        itemDescLabel.textAlignment = (TapLocalisationManager.shared.localisationLocale == "ar") ? .right : .left
        itemDescrriptionView.tap_theme_backgroundColor = .init(keyPath: "\(themePath).descriptionBackgroundColor")
        
        
        
        itemPriceLabel.tap_theme_font = .init(stringLiteral: "\(themePath).priceLabelFont")
        itemPriceLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).priceLabelColor")
        itemPriceLabel.textAlignment = (TapLocalisationManager.shared.localisationLocale == "ar") ? .left : .right
        
        itemDiscountPriceLabel.tap_theme_font = .init(stringLiteral: "\(themePath).calculatedPriceLabelFont")
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


extension ItemTableViewCell:ItemCellViewModelDelegate {
    
    func reloadDescription(with state: DescriptionState) {
        guard let tableView:UITableView = self.superview as? UITableView,
            let indexPath:IndexPath = tableView.indexPath(for: self) else { return }
        // Reload the expanded/collapsed the
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(0)) {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}
