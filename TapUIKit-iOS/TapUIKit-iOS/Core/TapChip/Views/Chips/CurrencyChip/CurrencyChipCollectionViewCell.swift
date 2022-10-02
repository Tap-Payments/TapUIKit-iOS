//
//  CurrencyChipCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/18/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import Nuke

@objc class CurrencyChipCollectionViewCell: GenericTapChip {
    // MARK:- Variables
    
    /// Reference to the saved card icon image view
    @IBOutlet weak var countryIconImageView: UIImageView!
    /// Reference to the saved card secured number
    @IBOutlet weak var currencyCodeLabel: UILabel!
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// view model that will control the cell view
    @objc public var viewModel:CurrencyChipViewModel = .init() {
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
    
    override func configureCell(with viewModel: GenericTapChipViewModel) {
        // Defensive coding it is the correct view model type
        guard let correctTypeModel:CurrencyChipViewModel = viewModel as? CurrencyChipViewModel else { return }
        self.viewModel = correctTypeModel
        // Apply the editing ui if needed
        changedEditMode(to: viewModel.editMode)
    }
    
    override func selectStatusChaned(with status:Bool) {
        
        // update the shadow for GoPayCell
        
        applyTheme()
    }
    
    override func tapChipType() -> TapChipType {
        return .CurrencyChip
    }
    
    
    /// The path to look for theme entry in
    private var themePath:String {
        get{
            return tapChipType().themePath()
        }
    }
    
    // Mark:- Init methods
    override func awakeFromNib() {
        super.awakeFromNib()
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        commonInit()
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        applyTheme()
    }
    
    /// Holds the logic needed to display and fetch all the requied data and displays it inside the cell view
    func reload() {
        loadImages()
        assignLabels()
    }
    
    
    /// Responsible for all logic needed to load all images in the cell
    private func loadImages() {
        //cardBrandIconImageView.fadeOut()
        
        // Make sure we have a valid URL
        guard let iconURL:URL = URL(string: viewModel.icon ?? "") else { return }
        // load the image from the URL
        let options = ImageLoadingOptions(
            transition: .fadeIn(duration: 0.2)
        )
        countryIconImageView.downloadImage(with: iconURL, nukeOptions: options)
    }
    
    /// Responsible for all logic needed to assign the textual info into the corresponding labels
    private func assignLabels() {
        currencyCodeLabel.text = viewModel.title
    }
}


// Mark:- Theme methods
extension CurrencyChipCollectionViewCell {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        let shadowPath:String = isSelected ? "selected" : "unSelected"
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        layer.tap_theme_cornerRadious = .init(keyPath: "horizontalList.chips.radius")
        //layer.shadowColor = try! UIColor(tap_hex: "#FF0000").cgColor
        layer.tap_theme_shadowColor = ThemeCgColorSelector.init(keyPath: "\(themePath).\(shadowPath).shadow.color")
        layer.shadowOffset = CGSize(width: CGFloat(TapThemeManager.numberValue(for: "\(themePath).\(shadowPath).shadow.offsetWidth")?.floatValue ?? 0), height: CGFloat(TapThemeManager.numberValue(for: "\(themePath).\(shadowPath).shadow.offsetHeight")?.floatValue ?? 0))
        layer.shadowOpacity = Float(TapThemeManager.numberValue(for: "\(themePath).\(shadowPath).shadow.opacity")?.floatValue ?? 0)
        layer.shadowRadius = CGFloat(TapThemeManager.numberValue(for: "\(themePath).\(shadowPath).shadow.radius")?.floatValue ?? 0)
        layer.tap_theme_borderColor = .init(keyPath: "\(themePath).\(shadowPath).shadow.borderColor")
        layer.tap_theme_borderWidth = .init(keyPath: "\(themePath).\(shadowPath).shadow.borderWidth")
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        
        guard let _ = currencyCodeLabel else { return }
        
        currencyCodeLabel.tap_theme_font = .init(stringLiteral: "\(themePath).labelTextFont",shouldLocalise:false)
        currencyCodeLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).labelTextColor")
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



extension CurrencyChipCollectionViewCell:GenericCellChipViewModelDelegate {
    
    func changedEditMode(to: Bool) {
        // Currency chip doesn't care about this
        return
    }
    
    func changeSelection(with status: Bool) {
        selectStatusChaned(with: status)
    }
    
    
}
