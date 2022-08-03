//
//  GoPayLoginOptions.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import TapCardInputKit_iOS
import CommonDataModelsKit_iOS
// import SimpleAnimation
import LocalisationManagerKit_iOS
/// External protocol to allow the GoPayLoginOptions to pass back data and events to the parent UIViewController
@objc internal protocol GoPayLoginOptionsPorotocl {
    /**
     This method will be called whenever the email  changed. It is being called in a live manner
     - Parameter email: The new email after the last update done bu the user
     - Parameter validation: Tells the validity of the detected brand, whether it is invalid, valid or still incomplete
     */
    func emailChanged(email:String,with validation:CrardInputTextFieldStatusEnum)
    
    /**
     This method will be called whenever the phone  changed. It is being called in a live manner
     - Parameter phone: The new phone after the last update done bu the user
     - Parameter validation: Tells the validity of the validity of the phone
     */
    func phoneChanged(phone:String, with validation:CrardInputTextFieldStatusEnum)
    
    /**
     Will be fired once the user make a selection to change the login option from the tab bar
     - Parameter viewModel: THe selected login option view model
     */
    @objc optional func loginOptionSelected(with viewModel: TapGoPayTitleViewModel)
    
    /**
     This method will be called whenever the user hits return on the email text
     - Parameter email: The email text inside the email field at the time the user hit return
     */
    @objc optional func emailReturned(with email:String)
    
    /**
     This method will be called whenever the user hits return on the phone text
     - Parameter phon: The phone text inside the phone field at the time the user hit return
     */
    @objc optional func phoneReturned(with phon:String)
    
    
    /// This method will be called whenever the user clicked on the country code
    @objc optional func countryCodeClicked()
}


/// Represents the viw which holds the GoPay login tab bar + the input fields
class GoPayLoginOptions: UIView {
    
    /// The view that holds everything
    @IBOutlet var contentView: UIView!
    /// The tab bar that holds the different login options
    @IBOutlet weak var loginOptionsTabBar: TapGoPayLoginBarView!
    /// The  view that holds the email input used by login with email
    @IBOutlet weak var emailInput: TapEmailInput! {
        didSet {
            emailInput.setup()
            emailInput.delegate = self
        }
    }
    /// The  view that holds the phone input used by login with phone
    @IBOutlet weak var phoneInput: TapPhoneInput! {
        didSet {
            phoneInput.delegate = self
        }
    }
    /// The  view that holds the label that shows a hint message below the input
    @IBOutlet weak var hintLabel: UILabel!
    
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    
    /// The delegate that wants to hear from the view on new data and events
    var delegate:GoPayLoginOptionsPorotocl?
    
    /// The view model that has the needed payment options and data source to display the payment view
    var tapGoPayLoginBarViewModel:TapGoPayLoginBarViewModel? {
        didSet {
            // On init, we need to:
            // Setup the bar view with the passed login options list
            guard let tapGoPayLoginBarViewModel = tapGoPayLoginBarViewModel else { return }
            loginOptionsTabBar.setup(with: tapGoPayLoginBarViewModel)
            tapGoPayLoginBarViewModel.delegate = self
            // Adjust the hint label
            hintLabel.text = tapGoPayLoginBarViewModel.hintLabelText
            // Define the default country to be the first one
            tapCountry = tapGoPayLoginBarViewModel.allowedCountries[0]
        }
    }
    
    /// Defines the validation status of the current selected tab
    var validationStatus:Bool = false {
        didSet{
            // When changed we need to re theme the underline bar
            tapGoPayLoginBarViewModel?.changeSelectionValidation(to: validationStatus)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetStatusNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetStatusNotification:(validationStatus) ? TapActionButtonStatusEnum.ValidNext : invalidButtonStatus] )
        }
    }
    
    /// Computes which invalid button shall we display based on the current scenario for showing OTP, goPay or Saved card
    var invalidButtonStatus: TapActionButtonStatusEnum {
        return tapGoPayLoginBarViewModel?.hintViewStatus == .SavedCardOTP ? .InvalidConfirm : .InvalidNext
    }
    
    /**
     Show the keboard and focus a text field
     - Parameter field: The field we need to focus
     */
    @objc public func focus(field:GoPyLoginOption) {
        switch field {
        case .Email:
            emailInput.focus()
            emailActionBlock()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetStatusNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetStatusNotification:invalidButtonStatus] )
        case .Phone:
            phoneInput.focus()
            phoneActionBlock()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetStatusNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetStatusNotification:invalidButtonStatus] )
        }
    }
    
    /// Represents the country that telecom options are being shown for, used to handle country code and correct phone length
    @objc public var tapCountry:TapCountry? {
        didSet {
            // Ons et, we need to setup the phont input view witht the new country details
            phoneInput.setup(with: tapCountry)
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = bounds
    }
    
    
    
    // MARK:- Private methods
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        hintLabel.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        applyTheme()
        
    }
    
    /**
     Decides which input field should be shown based on the selected segment id
     - Parameter segment: The id of the segment of payment options we need to show the associated input
     */
    private func showInputFor(for  segment:GoPyLoginOption) {
        switch segment {
        case .Email:
            handleEmailSelection()
        case .Phone:
            handlePhoneSelection()
        }
    }
    
    /// Handles the logic needed when the user selects the email input
    internal func handleEmailSelection() {
        // Show the email inpit
        emailInput.fadeIn()
        phoneInput.fadeOut()
        // Decide the needed validations and action for the global tap action button
        validationStatus = (emailInput.validationStatus() == .Valid) ? true : false
        emailActionBlock()
    }
    
    /// Addin the correct action block for email login field to the global tap action button
    internal func emailActionBlock() {
        // Define the needed block
        let actionButtonBlock:()->() = { [weak self] in
            self?.emailReturned(with: self?.emailInput.email() ?? "")
        }
        // Inform the button to update itself
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetBlockNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetBlockNotification:actionButtonBlock] )
    }
    
    /// Addin the correct action block for phone login field to the global tap action button
    internal func phoneActionBlock() {
        // Define the needed block
        let actionButtonBlock:()->() = { [weak self] in
            self?.phoneReturned(with: self?.phoneInput.phone() ?? "")
        }
        // Inform the button to update itself
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetBlockNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetBlockNotification:actionButtonBlock] )
    }
    
    /// Handles the logic needed when the user selects the phon input
    internal func handlePhoneSelection() {
        // Show the phone input
        emailInput.fadeOut()
        phoneInput.fadeIn()
        // Decide the needed validations and action for the global tap action button
        validationStatus = (phoneInput.validationStatus() == .Valid) ? true : false
        phoneActionBlock()
    }
}


extension GoPayLoginOptions: TapEmailInputProtocol {
    
    func emailChanged(email: String, with validation: CrardInputTextFieldStatusEnum) {
        delegate?.emailChanged(email: email, with: validation)
        validationStatus = (validation == .Valid) ? true : false
    }
    
    
    func emailReturned(with email: String) {
        validationStatus = (emailInput.validationStatus() == .Valid) ? true : false
        if validationStatus {
            // Instruct the parent caller that email is valid and user hit NEXT
            delegate?.emailReturned?(with: email)
        }
    }
    
}


extension GoPayLoginOptions: TapPhoneInputProtocol {
    
    func phoneNumberChanged(phoneNumber: String) {
        let validation:CrardInputTextFieldStatusEnum = (tapCountry?.phoneLength ?? -1 == phoneNumber.count) ? .Valid : .Invalid
        delegate?.phoneChanged(phone: phoneNumber, with: validation)
        validationStatus = (validation == .Valid) ? true : false
    }
    
    func phoneReturned(with phone: String) {
        validationStatus = (phoneInput.validationStatus() == .Valid) ? true : false
        if validationStatus {
            // Instruct the parent caller that email is valid and user hit NEXT
            delegate?.phoneReturned?(with: phone)
        }
    }
    
    func countryCodeClicked() {
        delegate?.countryCodeClicked?()
    }
}


extension GoPayLoginOptions: TapGoPayLoginBarViewModelDelegate {
    func loginOptionSelected(with viewModel: TapGoPayTitleViewModel) {
        showInputFor(for: viewModel.titleSegment)
        delegate?.loginOptionSelected?(with: viewModel)
    }
}




// Mark:- Theme methods
extension GoPayLoginOptions {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        hintLabel.tap_theme_font = .init(stringLiteral: "goPay.loginBar.hintLabel.textFont")
        hintLabel.tap_theme_textColor = .init(stringLiteral: "goPay.loginBar.hintLabel.textColor")
        
        tap_theme_backgroundColor = .init(keyPath: "goPay.loginBar.backgroundColor")
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

