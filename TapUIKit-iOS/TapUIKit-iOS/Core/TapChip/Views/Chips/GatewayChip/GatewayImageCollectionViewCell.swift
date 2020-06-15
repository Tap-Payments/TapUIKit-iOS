//
//  GatewayImageCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/14/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapThemeManager2020
import MapleBacon

public class GatewayImageCollectionViewCell: GenericTapChip {
    
    //@IBOutlet weak var mainView: UIView!
    @IBOutlet weak var gatewayIconImageView: UIImageView!
    
    public var viewModel:GatewayChipViewModel = .init() {
        didSet{
            reload()
        }
    }
    
    public func identefier() -> String {
        return viewModel.identefier()
    }
    
    override func configureCell(with viewModel: GenericTapChipViewModel) {
        // Defensive coding it is the correct view model type
        guard let correctTypeModel:GatewayChipViewModel = viewModel as? GatewayChipViewModel else { return }
        self.viewModel = correctTypeModel
    }
    
    public override func tapChipType() -> TapChipType {
        return .GatewayChip
    }
    
    
    /// The path to look for theme entry in
    private var themePath:String {
        get{
            return tapChipType().themePath()
        }
    }
    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        applyTheme()
    }
    
    
    public func reload() {
        commonInit()
        guard let iconURLString:String = viewModel.icon, iconURLString.isValidURL(), let iconURL:URL = URL(string: iconURLString) else { gatewayIconImageView.image = nil
            return
        }
        
        
        gatewayIconImageView.setImage(with: iconURL, displayOptions: []) { downloadedImage in
            // Check the downloaded image is a proper image
            guard let downloadedImage = downloadedImage else { return }
            
            // Set the image and show it
            DispatchQueue.main.async { [weak self] in
                self?.gatewayIconImageView.image = downloadedImage
            }
        }
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
        layer.shadowOpacity = 0.2//Float(TapThemeManager.numberValue(for: "\(themePath).shadow.opacity")?.floatValue ?? 0)
        layer.shadowRadius = CGFloat(TapThemeManager.numberValue(for: "\(themePath).shadow.radius")?.floatValue ?? 0)
        
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}



