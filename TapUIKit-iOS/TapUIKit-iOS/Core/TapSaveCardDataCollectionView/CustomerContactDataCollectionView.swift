//
//  CustomerContactDataCollectionView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 02/11/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import UIKit
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS
import SnapKit
import TapThemeManager2020

/// Defines the View used to display the fields data collection for customer when saving a card for tap
@objc public class CustomerContactDataCollectionView: UIView {
    
    /// The main content view
    @IBOutlet var contentView: UIView!
    /// The contact details collection section header view
    @IBOutlet weak var headerView: TapHorizontalHeaderView!
    /// The view that holds the data fields to be collected from the user
    @IBOutlet weak var fieldsContainerView: UIStackView!
    /// The field responsible for collecting the email of the user
    @IBOutlet weak var emailTextField: UITextField!
    /// View that holds needed UI elements to collect the phone form the user
    @IBOutlet weak var phoneEntryContainerView: UIView!
    /// The field responsible for collecting the phone of the user
    @IBOutlet weak var phoneEmailSeparator: TapSeparatorView!
    /// The field responsible for collecting the phone of the user
    @IBOutlet weak var phoneNumberTextField: UITextField!
    /// Represents the label that displays the selected country code
    @IBOutlet weak var phoneCountryCodeLabel: UILabel!
    /// Holds all the textfields we will collect data with
    @IBOutlet var textFields: [UITextField]!
    /// Popup dialog to select the country code picker
    
    /// Holds the UIViews that needed to be RTL supported based on the selected locale
    @IBOutlet var toBeLocalizedViews: [UIView]!
    /// The theme pathe
    internal let themePath:String = "customerDataCollection"
    /// The view model
    internal var viewModel:CustomerContactDataCollectionViewModel?
    
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
    @objc public func setupView(with viewModel:CustomerContactDataCollectionViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Private methods
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        applyTheme()
        localize()
        updateHeight()
    }
    
    /// Used to set the height of the view based on the visibility of the fields to be collected
    internal func updateHeight() {
        guard let viewModel = viewModel else {
            return
        }
        
        // Height for fields
        let heightForFields:CGFloat = viewModel.requiredHeightForFieldsContainer()// + 8
        // Height for the view as a whole
        let heightForView:CGFloat = viewModel.requiredHeight()
        
        // If none of the fields to be displayed, then we will not show the whole section,
        // Othwerise, we will compute the needed height based on the above calculated values
        fieldsContainerView.snp.remakeConstraints { make in
            make.height.equalTo(heightForFields)
        }
        snp.remakeConstraints { make in
            make.height.equalTo(heightForView)
        }
        fieldsContainerView.layoutIfNeeded()
        layoutIfNeeded()
    }
    
    
    /// Used to reload the phone field data from the view model
    internal func reloadPhone() {
        guard let viewModel = viewModel,
        let countryCode = viewModel.selectedCountry.code else {
            return
        }

        phoneCountryCodeLabel.text = "+\(countryCode)"
        phoneNumberTextField.text = ""
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
        
        phoneNumberTextField.textAlignment = (TapLocalisationManager.shared.localisationLocale == "ar") ? .right : .left
        emailTextField.textAlignment = (TapLocalisationManager.shared.localisationLocale == "ar") ? .right : .left
    }
    
    /// Now time to set localized string representations for the corresponding views
    private func localizeTextualContent() {
        emailTextField.placeholder = TapLocalisationManager.shared.localisedValue(for: "Common.email", with: TapCommonConstants.pathForDefaultLocalisation()).capitalized
        phoneNumberTextField.placeholder = "50 000 000"
    }
    
    /// Adjusts the height for the text fields based on the data from the view model
    fileprivate func adjustFieldsHeight(_ viewModel: CustomerContactDataCollectionViewModel) {
        // Adjust the email text field height
        emailTextField.snp.remakeConstraints { make in
            make.height.equalTo(viewModel.toBeCollectedData.contains(.email) ? 48 : 0)
        }
        
        // Adjust the phone text field height
        phoneEntryContainerView.snp.remakeConstraints { make in
            make.height.equalTo(viewModel.toBeCollectedData.contains(.phone) ? 48 : 0)
        }
        
        emailTextField.layoutIfNeeded()
        phoneEntryContainerView.layoutIfNeeded()
    }
    
    /// Adjust the visbility of the fields to be collected
    fileprivate func UpdateViewsVisibility(_ viewModel: CustomerContactDataCollectionViewModel) {
        /*emailTextField.isHidden = !viewModel.toBeCollectedData.contains(.email)
        phoneEntryContainerView.isHidden = !viewModel.toBeCollectedData.contains(.phone)*/
        
        
        if !viewModel.toBeCollectedData.contains(.email) {
            fieldsContainerView.removeArrangedSubview(emailTextField)
            emailTextField.removeFromSuperview()
        }
        
        if !viewModel.toBeCollectedData.contains(.phone) {
            fieldsContainerView.removeArrangedSubview(phoneEntryContainerView)
            phoneEntryContainerView.removeFromSuperview()
        }
        
        // If phpne field is not visibile, hence we don't need the separator that splits the fields
        phoneEmailSeparator.isHidden = emailTextField.isHidden
    }
    
    /// To be called from the view model to update the visibilty of the text fields
    internal func showHideViews() {
        guard let viewModel = viewModel else { return }
        // Adjusts the height for the text fields based on the data from the view model
        adjustFieldsHeight(viewModel)
        // Adjust the visbility of the fields to be collected
        UpdateViewsVisibility(viewModel)
    }
    
}



extension CustomerContactDataCollectionView {
    // Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
        updateHeight()
        headerView.headerType = .ContactDetailsHeader
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
        }
        
        // Set textual insets and margins in the text fields
        emailTextField.setLeftPaddingPoints(12)
        emailTextField.setRightPaddingPoints(12)
        
        phoneNumberTextField.setLeftPaddingPoints(8)
        phoneNumberTextField.setRightPaddingPoints(12)
        
        // The phone country label
        phoneCountryCodeLabel.tap_theme_font = .init(stringLiteral: "\(themePath).textfields.countryCodeLabelFont")
        phoneCountryCodeLabel.tap_theme_textColor = .init(keyPath: "\(themePath).textfields.color")
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
