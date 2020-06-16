//
//  TapGoPayChipCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/16/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapThemeManager2020

class TapGoPayChipCollectionViewCell: GenericTapChip {

    @IBOutlet weak var goPayLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        reload()
    }
    
    
    public var viewModel:TapGoPayViewModel = .init() {
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
        guard let correctTypeModel:TapGoPayViewModel = viewModel as? TapGoPayViewModel else { return }
        self.viewModel = correctTypeModel
    }
    
    public override func selectStatusChaned(with status:Bool) {
        
        // No theming required for ayment gatewy chip cell
        return
    }
    
    public override func tapChipType() -> TapChipType {
        return .GoPayChip
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
    }

}


// Mark:- Theme methods
extension TapGoPayChipCollectionViewCell {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).\(viewModel.tapGoPayStatus.themePath()).backgroundColor")
        layer.tap_theme_cornerRadious = .init(keyPath: "horizontalList.chips.radius")
        layer.tap_theme_shadowColor = ThemeCgColorSelector.init(keyPath: "\(themePath).shadow.color")
        layer.shadowOffset = CGSize(width: CGFloat(TapThemeManager.numberValue(for: "\(themePath).shadow.offsetWidth")?.floatValue ?? 0), height: CGFloat(TapThemeManager.numberValue(for: "\(themePath).shadow.offsetHeight")?.floatValue ?? 0))
        layer.shadowOpacity = Float(TapThemeManager.numberValue(for: "\(themePath).shadow.opacity")?.floatValue ?? 0)
        layer.shadowRadius = CGFloat(TapThemeManager.numberValue(for: "\(themePath).shadow.radius")?.floatValue ?? 0)
        
        guard let _ = goPayLabel else { return }
        
        goPayLabel.tap_theme_font = .init(stringLiteral: "\(themePath).\(viewModel.tapGoPayStatus.themePath()).labelTextFont",shouldLocalise:false)
        goPayLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).\(viewModel.tapGoPayStatus.themePath()).labelTextColor")
        
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



extension TapGoPayChipCollectionViewCell:TapGoPayViewModelDelegate {
    
    func changeGoPayStatus(with status: TapGoPayStatus) {
        reload()
    }
    
    func changeSelection(with status: Bool) {
        selectStatusChaned(with: status)
    }
    
    
}

