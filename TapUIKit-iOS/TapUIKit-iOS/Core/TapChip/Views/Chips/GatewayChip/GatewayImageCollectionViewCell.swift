//
//  GatewayImageCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/14/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import MapleBacon

/// Represents the Gateway payment chip cell
class GatewayImageCollectionViewCell: GenericTapChip {
    
    // MARK:- Variables
    
    /// Reference to the icon image view
    @IBOutlet weak var gatewayIconImageView: UIImageView!
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    
    /// view model that will control the cell view
    var viewModel:GatewayChipViewModel = .init() {
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        commonInit()
    }
    
    /// Holds the logic needed to display and fetch all the requied data and displays it inside the cell view
    func reload() {
        // Check if the view model has a valid icon URL
        guard let iconURLString:String = viewModel.icon, iconURLString.isValidURL(), let iconURL:URL = URL(string: iconURLString) else { gatewayIconImageView.image = nil
            return
        }
        
        // Load the image from the URL or from the cache if availble
        gatewayIconImageView.setImage(with: iconURL, displayOptions: []) { downloadedImage in
            // Check the downloaded image is a proper image
            guard let downloadedImage = downloadedImage else { return }
            
            // Set the image and show it
            DispatchQueue.main.async { [weak self] in
                self?.gatewayIconImageView.image = downloadedImage
            }
        }
    }
    
    override func tapChipType() -> TapChipType {
        return .GatewayChip
    }
    
    internal override func configureCell(with viewModel: GenericTapChipViewModel) {
        // Defensive coding it is the correct view model type
        guard let correctTypeModel:GatewayChipViewModel = viewModel as? GatewayChipViewModel else { return }
        self.viewModel = correctTypeModel
    }
    
    /// The path to look for theme entry in
    private var themePath:String {
        get{
            return tapChipType().themePath()
        }
    }
    
    
    
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        applyTheme()
    }
}


// Mark:- Theme methods
extension GatewayImageCollectionViewCell {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {

        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        layer.tap_theme_cornerRadious = .init(keyPath: "horizontalList.chips.radius")
        
        layer.tap_theme_shadowColor = ThemeCgColorSelector.init(keyPath: "\(themePath).shadow.color")
        layer.shadowOffset = CGSize(width: CGFloat(TapThemeManager.numberValue(for: "\(themePath).shadow.offsetWidth")?.floatValue ?? 0), height: CGFloat(TapThemeManager.numberValue(for: "\(themePath).shadow.offsetHeight")?.floatValue ?? 0))
        layer.shadowOpacity = Float(TapThemeManager.numberValue(for: "\(themePath).shadow.opacity")?.floatValue ?? 0)
        layer.shadowRadius = CGFloat(TapThemeManager.numberValue(for: "\(themePath).shadow.radius")?.floatValue ?? 0)
        
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        
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



extension GatewayImageCollectionViewCell:GenericCellChipViewModelDelegate{
    func changeSelection(with status: Bool) {
        selectStatusChaned(with: status)
    }
}
