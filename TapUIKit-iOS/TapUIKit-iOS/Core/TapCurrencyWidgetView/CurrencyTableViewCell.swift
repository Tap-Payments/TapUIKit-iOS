//
//  CurrencyTableViewCell.swift
//  TapUIKit-iOS
//
//  Created by MahmoudShaabanAllam on 01/06/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import LocalisationManagerKit_iOS
import Nuke

/// Represents the currency table  view cell that will show the items inside the items table view screen
@objc public class CurrencyTableViewCell: TapGenericTableCell {
    
    /// The amount label reference
    @IBOutlet weak var amountLabel: UILabel!
    
    /// The currency Flag ImageView  reference
    @IBOutlet weak var currencyFlagImageView: UIImageView!
    
    /// Hold views to be localized
    @IBOutlet var toBeLocalizedDirectionViews: [UIView]!
    
    /// view model that will control the cell view
    var viewModel:CurrencyTableCellViewModel = .init() {
        didSet{
            // Upon assigning a new view model we attach ourself as the delegate
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
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        self.contentView.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        toBeLocalizedDirectionViews.forEach{ $0.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight }
        
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
    }
    
    /// Reload the cell view with new data coming in
    internal func reload() {
        loadImages()
        setUILabels()
        self.layoutIfNeeded()
    }
    
    /// Responsabile for bind labels
    private func setUILabels() {
        self.amountLabel.text = viewModel.amount()
    }
    
    /// Responsible for all logic needed to load images
    private func loadImages() {
        let options = ImageLoadingOptions(
            transition: .fadeIn(duration: 0.2)
        )
        // load currencyFlag
        // Make sure we have a valid URL
        guard let currencyFlag:URL = URL(string: viewModel.flag()) else { return }
        // load the image from the URL
        currencyFlagImageView.downloadImage(with: currencyFlag, nukeOptions: options)
    }
    
    override func tapCellType() -> TapGenericCellType {
        return .CurrencyCell
    }
    
    internal override func configureCell(with viewModel: TapGenericTableCellViewModel) {
        // Defensive coding it is the correct view model type
        guard let correctTypeModel:CurrencyTableCellViewModel = viewModel as? CurrencyTableCellViewModel else { return }
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
extension CurrencyTableViewCell {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        backgroundColor = .clear
        amountLabel.tap_theme_font = .init(stringLiteral: "\(themePath).labelFont")
        amountLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).labelColor")
        layer.masksToBounds = true
        clipsToBounds = false
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}


extension CurrencyTableViewCell: TapCellViewModelDelegate {
    
    func changeSelection(with status: Bool) {
    }
    
    func reloadData() {
        reload()
    }
}

extension CurrencyTableViewCell: CurrencyTableCellViewModelDelegate {
    
}

