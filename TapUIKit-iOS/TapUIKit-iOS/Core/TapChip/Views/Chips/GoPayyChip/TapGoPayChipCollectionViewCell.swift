//
//  TapGoPayChipCollectionViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/16/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//


import TapThemeManager2020
// import SimpleAnimation
import SnapKit

/// Represents the GoPay chip cell
@objc class TapGoPayChipCollectionViewCell: GenericTapChip {
    // MARK:- Variables
    
    /// Reference to GoPay title label
    var goPayLabel: UILabel = .init()
    /// Reference to the tap icon image view
    var tapBrandIconImageView: UIImageView = .init()
    /// Holds the main view, used to control the size of the cell at run time
    @IBOutlet weak var mainView: UIView!
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    
    /// view model that will control the cell view
    var viewModel:TapGoPayViewModel = .init() {
        didSet{
            // Upon assigning a new view model we attach ourslef as the delegate
            viewModel.cellDelegate = self
            reload()
        }
    }
    
    // MARK:- Internal methods
    
    func identefier() -> String {
        return viewModel.identefier()
    }
    
    override func configureCell(with viewModel: GenericTapChipViewModel) {
        // Defensive coding it is the correct view model type
        guard let correctTypeModel:TapGoPayViewModel = viewModel as? TapGoPayViewModel else { return }
        self.viewModel = correctTypeModel
        // Apply the editing ui if needed
        changedEditMode(to: viewModel.editMode)
    }
    
    override func selectStatusChaned(with status:Bool) {
        
        // update the shadow for GoPayCell
        applyTheme()
    }
    
    override func tapChipType() -> TapChipType {
        return .GoPayChip
    }
    
    
    /// The path to look for theme entry in
    private var themePath:String {
        get{
            return tapChipType().themePath()
        }
    }
    
    func reload() {
        // Apply the editing ui if needed
        changedEditMode(to: viewModel.editMode)
    }
    
    // Mark:- Init methods
    override func awakeFromNib() {
        super.awakeFromNib()
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        commonInit()
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        addSubViews()
        setupConstraints()
        applyTheme()
    }
    
    
    func addSubViews() {
        addSubview(tapBrandIconImageView)
        addSubview(goPayLabel)
    }
    func setupConstraints() {
        tapBrandIconImageView.snp.remakeConstraints { (make) in
            //make.left.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(19)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        goPayLabel.snp.remakeConstraints { (make) in
            //make.right.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(41).priority(.high)
            make.right.equalToSuperview().offset(-18).priority(.high)
            make.centerY.equalTo(tapBrandIconImageView.snp.centerY)
        }
        
        goPayLabel.textAlignment = .center
        
        layoutIfNeeded()
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
        
        goPayLabel.tap_theme_font = .init(stringLiteral: "\(themePath).labelTextFont",shouldLocalise:false)
        goPayLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).labelTextColor")
    
        tapBrandIconImageView.image = UIImage(named: "tap", in: Bundle(for: TapGoPayChipCollectionViewCell.self), compatibleWith: nil)
        
        goPayLabel.text = "goPay"
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



extension TapGoPayChipCollectionViewCell:GenericCellChipViewModelDelegate {
    func changedDisabledMode(to: Bool) {
        return
    }
    
    
    func changedEditMode(to: Bool) {
        self.contentView.alpha = to ? 0.5 : 1
        self.isUserInteractionEnabled = !to
    }
    
    
    func changeSelection(with status: Bool) {
        selectStatusChaned(with: status)
    }
    
    
}

