//
//  SavedCardCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/17/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//


import TapThemeManager2020
import SimpleAnimation


class SavedCardCollectionViewCell: GenericTapChip {

    @IBOutlet weak var cardBrandIconImageView: UIImageView!
    @IBOutlet weak var cardSchemeLabel: UILabel!
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    
    public var viewModel:SavedCardCollectionViewCellModel = .init() {
        didSet{
            viewModel.cellDelegate = self
            reload()
        }
    }
    
    public func identefier() -> String {
        return viewModel.identefier()
    }
    
    override func configureCell(with viewModel: GenericTapChipViewModel) {
        // Defensive coding it is the correct view model type
        guard let correctTypeModel:SavedCardCollectionViewCellModel = viewModel as? SavedCardCollectionViewCellModel else { return }
        self.viewModel = correctTypeModel
    }
    
    public override func selectStatusChaned(with status:Bool) {
        
        // update the shadow for GoPayCell
        applyTheme()
    }
    
    public override func tapChipType() -> TapChipType {
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
    
    
    public func reload() {
        // commonInit()
        loadImages()
        assignLabels()
    }
    
    
    private func loadImages() {
        cardBrandIconImageView.fadeOut()
        
        // Make sure we have a valid URL
        guard let iconURL:URL = URL(string: viewModel.icon ?? "") else { return }
        // load the image from the URL
        cardBrandIconImageView.setImage(with: iconURL, displayOptions: []) { downloadedImage in
            // Check the downloaded image is a proper image
            guard let downloadedImage = downloadedImage else { return }
            
            // Set the image and show it
            DispatchQueue.main.async { [weak self] in
                self?.cardBrandIconImageView.image = downloadedImage
                self?.cardBrandIconImageView.fadeIn()
            }
        }
    }
    
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



extension SavedCardCollectionViewCell:GenericChipViewModelDelegate {
    
    func changeSelection(with status: Bool) {
        selectStatusChaned(with: status)
    }
    
    
}

