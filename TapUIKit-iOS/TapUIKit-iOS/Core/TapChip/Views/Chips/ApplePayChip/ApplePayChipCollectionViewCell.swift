//
//  ApplePayChipCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/18/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import TapApplePayKit_iOS
import enum CommonDataModelsKit_iOS.TapCountryCode
import enum CommonDataModelsKit_iOS.TapCurrencyCode


class ApplePayChipCollectionViewCell: GenericTapChip {

    // MARK:- Variables
    
    /// Reference to the saved card icon image view
    @IBOutlet weak var applePayContainerView: UIView!
    private var tapApplePayButton:TapApplePayButton?
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// view model that will control the cell view
    public var viewModel:ApplePayChipViewCellModel = .init() {
        didSet{
            // Upon assigning a new view model we attach ourslef as the delegate
            viewModel.cellDelegate = self
            // We reload the cell data from the view model
            reload()
        }
    }
    
    // MARK:- Internal methods
    
    func identefier() -> String {
        return viewModel.identefier()
    }
    
    override func configureCell(with viewModel: GenericTapChipViewModel) {
        // Defensive coding it is the correct view model type
        guard let correctTypeModel:ApplePayChipViewCellModel = viewModel as? ApplePayChipViewCellModel else { return }
        self.viewModel = correctTypeModel
    }
    
    override func selectStatusChaned(with status:Bool) {
        
        // update the shadow for GoPayCell
        applyTheme()
    }
    
    override func tapChipType() -> TapChipType {
        return .ApplePayChip
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
        configureApplePayButton()
    }
    
    /// Holds the logic needed to display and fetch all the requied data and displays it inside the cell view
    func reload() {
        configureApplePayButton()
    }
    
    private func configureApplePayButton() {
        guard let _ = applePayContainerView else { return }
        
        tapApplePayButton = TapApplePayButton.init(frame: applePayContainerView.bounds)
        tapApplePayButton?.setup()
        //tapApplePayButton?.removeFromSuperview()
        reloadApplePayButtonStyle()
        //applePayContainerView.addSubview(tapApplePayButton!)
        
        tapApplePayButton?.dataSource = self
        tapApplePayButton?.delegate = self
    }
    
    private func reloadApplePayButtonStyle() {
        tapApplePayButton?.buttonStyle = viewModel.applePayButtonStyle
        tapApplePayButton?.buttonType = viewModel.applePayButtonType
    }
}


// Mark:- Theme methods
extension ApplePayChipCollectionViewCell {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        let shadowPath:String = isSelected ? "selected" : "unSelected"
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        layer.tap_theme_cornerRadious = .init(keyPath: "horizontalList.chips.radius")

        layer.tap_theme_shadowColor = ThemeCgColorSelector.init(keyPath: "\(themePath).\(shadowPath).shadow.color")
        layer.shadowOffset = CGSize(width: CGFloat(TapThemeManager.numberValue(for: "\(themePath).\(shadowPath).shadow.offsetWidth")?.floatValue ?? 0), height: CGFloat(TapThemeManager.numberValue(for: "\(themePath).\(shadowPath).shadow.offsetHeight")?.floatValue ?? 0))
        layer.shadowOpacity = Float(TapThemeManager.numberValue(for: "\(themePath).\(shadowPath).shadow.opacity")?.floatValue ?? 0)
        layer.shadowRadius = CGFloat(TapThemeManager.numberValue(for: "\(themePath).\(shadowPath).shadow.radius")?.floatValue ?? 0)
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



extension ApplePayChipCollectionViewCell:ApplePayChipViewModelDelegate {
    
    func reloadApplePayButton() {
        reloadApplePayButtonStyle()
    }
    
    
    func changeSelection(with status: Bool) {
        selectStatusChaned(with: status)
    }
    
    
}

extension ApplePayChipCollectionViewCell:TapApplePayButtonDataSource,TapApplePayButtonDelegate {
    var tapApplePayRequest: TapApplePayRequest {
        return viewModel.applePayRequest()
    }
    
    func tapApplePayFinished(with tapAppleToken: TapApplePayToken) {
        //showTokenizedData(with: tapAppleToken)
    }
}
