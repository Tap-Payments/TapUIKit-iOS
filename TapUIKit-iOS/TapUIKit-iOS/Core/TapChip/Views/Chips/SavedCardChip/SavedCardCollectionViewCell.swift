//
//  SavedCardCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/17/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//


import TapThemeManager2020
import Nuke
/// Represents the Saved card chip cell

class SavedCardCollectionViewCell: GenericTapChip {
    // MARK:- Variables
    
    /// Reference to the saved card icon image view
    @IBOutlet weak var cardBrandIconImageView: UIImageView!
    /// Reference to the saved card secured number
    @IBOutlet weak var cardSchemeLabel: UILabel!
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// view model that will control the cell view
    public var viewModel:SavedCardCollectionViewCellModel = .init() {
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
        guard let correctTypeModel:SavedCardCollectionViewCellModel = viewModel as? SavedCardCollectionViewCellModel else { return }
        self.viewModel = correctTypeModel
    }
    
     override func selectStatusChaned(with status:Bool) {
        
        // update the shadow for GoPayCell
        applyTheme()
    }
    
    override func tapChipType() -> TapChipType {
        return .SavedCardChip
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
        Nuke.loadImage(with: iconURL, into: cardBrandIconImageView)
    }
    
    /// Responsible for all logic needed to assign the textual info into the corresponding labels
    private func assignLabels() {
        cardSchemeLabel.text = viewModel.title
    }
}


// Mark:- Theme methods
extension SavedCardCollectionViewCell {
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
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        
        guard let _ = cardSchemeLabel else { return }
        
        cardSchemeLabel.tap_theme_font = .init(stringLiteral: "\(themePath).labelTextFont",shouldLocalise:false)
        cardSchemeLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).labelTextColor")
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



extension SavedCardCollectionViewCell:GenericCellChipViewModelDelegate {
    
    func changeSelection(with status: Bool) {
        selectStatusChaned(with: status)
    }
    
    
}

