//
//  CountryCodeTableViewCell.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 08/11/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import UIKit
import CommonDataModelsKit_iOS
import TapThemeManager2020
import LocalisationManagerKit_iOS

/// Represents the cell view for the country when selecting a country code when collecting user's contact information when saving a card for tap
@objc public class CountryCodeTableViewCell: UITableViewCell {
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// The set of views that needs to reflect based on language direction
    @IBOutlet var toBeLocalizedDirectionViews: [UIView]!
    /// The separator view to be displayed at the bottom o the cell
    @IBOutlet weak var separatorView: TapSeparatorView!
    /// The label used to display the cointry code + name
    @IBOutlet weak var countryCodeLabel: UILabel!
    /// The country it is representing
    var country:TapCountry = .init(nameAR: "", nameEN: "", code: "0", phoneLength: 0) {
        didSet {
            if oldValue.code != country.code {
                reload()
            }
        }
    }
    /// The  theme path to theme the country cell
    var themePath:String = "customerDataCollection.countryPicker.countryCell"
    
    /// The height required for the country picker table view cell
    internal static let hountryCodeTableViewCellHeight:CGFloat = 48
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        self.contentView.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        toBeLocalizedDirectionViews.forEach{ $0.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight }
        
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        commonInit()
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Apply the correct logic based on the selection state and inform the view model
        if selected {
            //viewModel.didSelectItem()
        }else{
            //viewModel.didDeselectItem()
        }
        // Configure the view for the selected state
    }
    
    // MARK: - Internal methods
    
    internal func identefier() -> String {
        return "CountryCodeTableViewCell"
    }
    
    
    /// Reload the cell view with new data coming in
    internal func reload() {
        // Set the country name and code in the cell label
        countryCodeLabel.text = "+\(country.code ?? "") \(country.nameEN ?? "")"
        countryCodeLabel.sizeToFit()
        self.layoutIfNeeded()
    }
    
    /// Adjusting the cell with the correct country to show
    /// - Parameter with country: The country to be displayed in the cell
    /// - Parameter shouldShowSeparator: Boolean to indicate whether to show a separator or not. Default is true
    internal func configureCell(with country: TapCountry, shouldShowSeparator:Bool = true) {
        self.country = country
        separatorView.isHidden = !shouldShowSeparator
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        applyTheme()
    }
    
}



extension CountryCodeTableViewCell {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
       
        countryCodeLabel.tap_theme_font = .init(stringLiteral: "\(themePath).titleLabelFont")
        countryCodeLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).titleLabelColor")
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
