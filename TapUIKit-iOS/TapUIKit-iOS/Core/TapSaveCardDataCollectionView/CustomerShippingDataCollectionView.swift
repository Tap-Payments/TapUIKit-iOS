//
//  CustomerShippingDataCollectionView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 25/01/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import Foundation
import UIKit
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS
import SnapKit
import TapThemeManager2020
//import FlagKit

/// Defines the View used to display the fields data collection for customer when saving a card for tap
@objc public class CustomerShippingDataCollectionView: UIView {
    
    /// The main content view
    @IBOutlet var contentView: UIView!
    /// The contact details collection section header view
    @IBOutlet weak var headerView: TapHorizontalHeaderView!
    /// The view that holds the fields we will collect from the user
    @IBOutlet weak var fieldsContainerView: UIView!
    /// The field responsible for collecting the flat of the user
    @IBOutlet weak var flatTextField: UITextField!
    /// The field responsible for collecting the additiona line of user shipping details of the user
    @IBOutlet weak var additionalLineTextField: UITextField!
    /// The field responsible for collecting the city of the user
    @IBOutlet weak var cityTextField: UITextField!
    /// Represents the label that displays the selected country name
    @IBOutlet weak var countryNameLabel: UILabel!
    /// Represents the label that displays the selected country flag
    @IBOutlet weak var countryFlagImageView: UIImageView!
    /// Indicates that the user can select from the countries list
    @IBOutlet weak var countryDropDownArrowImageView: UIImageView!
    /// Holds all the textfields we will collect data with
    @IBOutlet var textFields: [UITextField]!
    /// Popup dialog to select the country code picker
    
    /// Holds the UIViews that needed to be RTL supported based on the selected locale
    @IBOutlet var toBeLocalizedViews: [UIView]!
    /// The theme pathe
    internal let themePath:String = "customerDataCollection"
    /// The view model
    internal var viewModel:CustomerShippingDataCollectionViewModel?
    
    //MARK: - Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    // MARK: - Public methods
    /**
     Apply the needed setup and attach the passed view model
     - Parameter viewModel: The TapCardPhoneIconViewModel responsible for controlling this icon view
     */
    @objc public func setupView(with viewModel:CustomerShippingDataCollectionViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Private methods
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        applyTheme()
        localize()
        assignDelegates()
        adjustHeight()
        reloadCountryDetails()
    }
    
    /// Adjusts the view and the sub views heights
    private func adjustHeight() {
        // Assign the height for the text fields
        textFields.forEach{ $0.snp.remakeConstraints { make in
            make.height.equalTo(48)
        }
        }
        
        // Assing the height for the fields container view
        fieldsContainerView.snp.remakeConstraints { make in
            make.height.equalTo(195)
        }
        
        // The height for the whole view
        snp.remakeConstraints{ make in
            make.height.equalTo(240)
        }
        
        fieldsContainerView.layoutIfNeeded()
        layoutIfNeeded()
    }
    
    /// reload the country details
    internal func reloadCountryDetails() {
        guard let country:TapCountry = viewModel?.selectedCountry else { return }
        
        countryNameLabel.text = country.localizedName(for: TapLocalisationManager.shared.localisationLocale ?? "en")
        //countryFlagImageView.image = Flag(countryCode: country.countryCode.rawValue)!.originalImage
    }
    
    /// Assigns the text fields delegates to self
    private func assignDelegates() {
        textFields.forEach{ $0.delegate = self }
    }
    
    /// Used to localize and force UI directions based on the locale
    private func localize() {
        // Adjust the direction of the UI based on the locale
        adjustViewsDirections()
        // Now time to set localized string representations for the corresponding views
        localizeTextualContent()
    }
    
    /// Adjust the direction of the UI based on the locale
    private func adjustViewsDirections() {
        // Decide which direction should be used in the UIView based on the current selected locale
        let correctSemanticContent:UISemanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        // Adjust the main view that holds everything
        contentView.semanticContentAttribute = correctSemanticContent
        // Adjust all the subviews marked to be localized based on direction
        toBeLocalizedViews.forEach{ $0.semanticContentAttribute = correctSemanticContent }
        // Adjust the text aligments
        textFields.forEach{ $0.textAlignment = (TapLocalisationManager.shared.localisationLocale == "ar") ? .right : .left }
    }
    
    /// Now time to set localized string representations for the corresponding views
    private func localizeTextualContent() {
        
        let placeHolderColor:UIColor = TapThemeManager.colorValue(for: "\(themePath).textfields.placeHolderColor") ?? .black
        
        flatTextField.attributedPlaceholder = .init(string: TapLocalisationManager.shared.localisedValue(for: "TapCardInputKit.flatPlaceHolder", with: TapCommonConstants.pathForDefaultLocalisation()).capitalized, attributes: [.foregroundColor:placeHolderColor, .font : TapThemeManager.fontValue(for: "\(themePath).textfields.font", shouldLocalise: true)!])
        
        additionalLineTextField.attributedPlaceholder = .init(string: TapLocalisationManager.shared.localisedValue(for: "TapCardInputKit.additionalLinePlaceHolder", with: TapCommonConstants.pathForDefaultLocalisation()).capitalized, attributes: [.foregroundColor:placeHolderColor, .font : TapThemeManager.fontValue(for: "\(themePath).textfields.font", shouldLocalise: true)!])
        
        cityTextField.attributedPlaceholder = .init(string: TapLocalisationManager.shared.localisedValue(for: "TapCardInputKit.cityPlaceHolder", with: TapCommonConstants.pathForDefaultLocalisation()).capitalized, attributes: [.foregroundColor:placeHolderColor, .font : TapThemeManager.fontValue(for: "\(themePath).textfields.font", shouldLocalise: true)!])
    }
    
    /// Will be called once the country code picker button is clicked
    @IBAction func countryCodePickerClicked(_ sender: Any) {
        // Confirm there is a view model
        guard let viewModel = viewModel else {
            return
        }
        // Inform the view model abput the click event
        viewModel.countryPickerClicked()
    }
    
}



extension CustomerShippingDataCollectionView {
    // Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
        headerView.headerType = .ShippingHeader
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // the border radius
        fieldsContainerView.tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        fieldsContainerView.layer.tap_theme_cornerRadious = ThemeCGFloatSelector.init(keyPath: "\(themePath).cornerRadius")
        // the shadow
        fieldsContainerView.layer.shadowRadius = CGFloat(TapThemeManager.numberValue(for: "\(themePath).shadow.radius")?.floatValue ?? 0)
        fieldsContainerView.layer.tap_theme_shadowColor = ThemeCgColorSelector.init(keyPath: "\(themePath).shadow.color")
        fieldsContainerView.layer.shadowOffset = CGSize(width: CGFloat(TapThemeManager.numberValue(for: "\(themePath).shadow.offsetWidth")?.floatValue ?? 0), height: CGFloat(TapThemeManager.numberValue(for: "\(themePath).shadow.offsetHeight")?.floatValue ?? 0))
        fieldsContainerView.layer.shadowOpacity = Float(TapThemeManager.numberValue(for: "\(themePath).shadow.opacity")?.floatValue ?? 0)
        //fieldsContainerView.clipsToBounds = true
        
        // The textfields
        textFields.forEach { textField in
            textField.tap_theme_font = .init(stringLiteral: "\(themePath).textfields.font")
            textField.tap_theme_textColor = .init(keyPath: "\(themePath).textfields.color")
            
            textField.setLeftPaddingPoints(12)
            textField.setRightPaddingPoints(12)
        }
        // The country name label
        countryNameLabel.tap_theme_font = .init(stringLiteral: "\(themePath).textfields.countryCodeLabelFont")
        countryNameLabel.tap_theme_textColor = .init(keyPath: "\(themePath).textfields.color")
        
        // country drop down arrow icon
        countryDropDownArrowImageView.tap_theme_tintColor = .init(keyPath: "\(themePath).textfields.color")
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}


extension CustomerShippingDataCollectionView:UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == flatTextField {
            additionalLineTextField.becomeFirstResponder()
        }else if textField == additionalLineTextField {
            cityTextField.becomeFirstResponder()
        }else if textField == cityTextField {
            cityTextField.resignFirstResponder()
        }
        return true
    }
}
