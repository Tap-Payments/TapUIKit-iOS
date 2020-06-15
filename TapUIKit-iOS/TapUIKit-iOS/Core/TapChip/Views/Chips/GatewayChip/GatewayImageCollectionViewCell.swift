//
//  GatewayImageCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/14/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapThemeManager2020

class GatewayImageCollectionViewCell: GenericTapChip {
    
    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!
    public var viewModel:GatewayChipViewModel = .init()
    
    override func identefier() -> String {
        "GatewayImageCollectionViewCell"
    }
    
    override func updateTheme(for state: Bool) {
        applyTheme()
    }
    
    override func tapChipType() -> TapChipType {
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
        self.containerView = setupXIB()
        applyTheme()
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
    

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var gatewayIconImageView: UIImageView!

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
        
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}



