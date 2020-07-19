//
//  TapGoPaySignInView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapCardInputKit_iOS
import CommonDataModelsKit_iOS
import McPicker

/// External protocol to allow the GoPaySignIn View to pass back data and events to the parent UIViewController
@objc public protocol TapGoPaySignInViewProtocol {
    
    /**
     Will be fired once the user make a selection to change the login option from the tab bar
     - Parameter viewModel: The selected login option view model
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
/// Represents the GoPaySignInView where all needed logic and transistions between GoPayViews are encapsulated
@objc public class TapGoPaySignInView: UIView {

    /// The animatin duration used to switch between different gopay views
    let animationDuration:Double = 0.5
    /// The content view where it holds all the sub views
    @IBOutlet var contentView: UIView!
    /// Represents the View that shows the login bar + login fields (email and phone)
    @IBOutlet weak var goPayLoginOptionsView: GoPayLoginOptions! {
        didSet {
            goPayLoginOptionsView.delegate = self
        }
    }
    /// Will be used to save the original height of the view, so we can get back to it when we dismiss the country picker
    internal var originalHeight:CGFloat = 0
    
    /// Represents the View that shows the password t=step after signing in with the email
    @IBOutlet weak var goPayPasswordView: TapGoPayPasswordView! {
        didSet {
            goPayPasswordView.delegate = self
        }
    }
    
    /// Represents the View that shows the otp t=step after signing in with the phone
    @IBOutlet weak var goPayOTPView: TapGoPayOTPView! {
        didSet {
            goPayOTPView.delegate = self
        }
    }
    
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// Theme path used to theme the go pay sign in view
    private let themePath:String = "goPay.signIn"
    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /// External protocol to allow the GoPaySignIn View to pass back data and events to the parent UIViewController
    @objc public var delegate:TapGoPaySignInViewProtocol?
    
    /**
     Seup the hint view according to the view model
     - Parameter viewModel: The new required view model to attach the view to
     */
    @objc public func setup(with viewModel:TapGoPayLoginBarViewModel) {
        goPayLoginOptionsView.tapGoPayLoginBarViewModel = viewModel
    }
    
    // MARK:- Private methods
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
    }
    
    /// Apply the needed logic to reload UI and localisations upon an order from the view model
    private func configureWithStatus() {
        //applyTheme()
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = bounds
    }
    
    /**
     Used to show the password view with the correct animation
     - Parameter email: The email the user used in the previous step
     */
    internal func showPasswordView(with email:String) {
        // Show the email in the hint view
        goPayPasswordView.setup(with: email)
        // Show the password view
        goPayPasswordView.fadeIn(duration: animationDuration)
        goPayPasswordView.slideIn(from: .bottom, x:0, y: 250, duration: animationDuration, delay: 0)
    }
    
    /**
     Used to show the otp view with the correct animation
     - Parameter phone: The phone the user used in the previous step
     */
    internal func showOtpView(with phone:String) {
        // Show the phone in the hint view
        goPayOTPView.setup(with: phone,expires: 20)
        // Show the phone view
        goPayOTPView.fadeIn(duration: animationDuration)
        goPayOTPView.slideIn(from: .bottom, x:0, y: 250, duration: animationDuration, delay: 0)
    }
    
    
    /**
     Used to show the default view which is the login tab bar + the input fields
     - Parameter field: Tells whether we need to show the keyboard for a given field after showing the login view
     */
    internal func showLoginOptions(focus field:GoPyLoginOption? = nil) {
        if let field = field {
            // of there is a field we need to focus, we do
            goPayLoginOptionsView.focus(field: field)
        }
        goPayLoginOptionsView.fadeIn(duration:animationDuration)
    }
    
    /**
     Used to animate the height of the current view
     - Parameter offset: The amount we need to change the current height with
     */
    internal func changeHeight(with offset:CGFloat) {
        DispatchQueue.main.async { [weak self] in
            self?.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height {
                    constraint.constant += offset
                    self?.layoutIfNeeded()
                    self?.superview?.layoutIfNeeded()
                    return
                }
            }
        }
    }
    
    /// Handles th logic to show the country picker below the GoPay login fields
    internal func showCountryPicker() {
        self.endEditing(true)
        // Check if we have more than one country to show
        guard let countries:[TapCountry] = goPayLoginOptionsView.tapGoPayLoginBarViewModel?.allowedCountries,
            countries.count > 1 else { return }
        
        // Show the picker just after the animation of height changed
        changeHeight(with: 250)
        // COnver the list of countris to the correct labels values
        let data: [[String]] = [countries.map{ "\($0.code ?? "") \($0.nameEN ?? "")" }]
        let mcPicker = McPicker(data: data)
        
        configureCountryPicker(for:mcPicker)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            mcPicker.show(doneHandler: { [weak self] (Selection) in
                self?.changeHeight(with: -250)
                let countryNameSelected:String = Selection[0] ?? ""
                self?.changePhoneCountry(with: countries[data[0].firstIndex(of:countryNameSelected) ?? 0])
                }, cancelHandler: { [weak self] in
                    self?.changeHeight(with: -250)
            }) { (Selections, Index) in
                
            }
        }
    }
    
    /**
     Apply the needed theming for the country picker
     - Parameter mcPicker: The picker we need to theme
     */
    internal func configureCountryPicker(for mcPicker:McPicker) {
        // BACKGROUND COLORS
        mcPicker.backgroundColor = .gray
        mcPicker.backgroundColorAlpha = 0
        mcPicker.pickerBackgroundColor = .init(white: 1, alpha: 0.8)
        // Tool bar spacing and buttons
        let fixedSpace = McPickerBarButtonItem.fixedSpace(width: 9.0)
        let flexibleSpace = McPickerBarButtonItem.flexibleSpace()
        let fireButton = McPickerBarButtonItem.done(mcPicker: mcPicker, title: "Done", barButtonSystemItem: .done) // Set custom Text
        let cancelButton = McPickerBarButtonItem.cancel(mcPicker: mcPicker, barButtonSystemItem: .cancel) // or system items
        // Set custom toolbar items
        mcPicker.setToolbarItems(items: [fixedSpace, cancelButton, flexibleSpace, fireButton, fixedSpace])
    }
    
    /**
     Apply a new country for the phone input
     - Parameter country: The new country we want to set
     */
    internal func changePhoneCountry(with country:TapCountry) {
        
        goPayLoginOptionsView.tapCountry = country
        
    }
}



extension TapGoPaySignInView: GoPayLoginOptionsPorotocl {
    
    func emailChanged(email: String, with validation: CrardInputTextFieldStatusEnum) {
        
    }
    
    func phoneChanged(phone: String, with validation: CrardInputTextFieldStatusEnum) {
        
    }
    
    func emailReturned(with email: String) {
        // Show password view
        goPayLoginOptionsView.fadeOut(duration:animationDuration)
        showPasswordView(with: email)
        delegate?.emailReturned?(with: email)
    }
    
    func phoneReturned(with phon: String) {
        // Show phone view
        goPayLoginOptionsView.fadeOut(duration:animationDuration)
        showOtpView(with: phon)
        delegate?.phoneReturned?(with: phon)
    }
    
    func countryCodeClicked() {
        //delegate?.countryCodeClicked?()
        showCountryPicker()
    }
}


extension TapGoPaySignInView: TapGoPayPasswordViewProtocol {
    
    public func changeEmailClicked() {
        // Show login opions view
        showLoginOptions(focus: .Email)
        goPayPasswordView.slideOut(to:.bottom,duration:animationDuration)
        goPayPasswordView.fadeOut(duration:animationDuration)
    }
    
}


extension TapGoPaySignInView: TapGoPayOTPViewProtocol {
    
    public func changePhoneClicked() {
        // Show login opions view
        showLoginOptions(focus: .Phone)
        goPayOTPView.slideOut(to:.bottom,duration:animationDuration)
        goPayOTPView.fadeOut(duration:animationDuration)
    }
    
    public func otpStateExpired() {
        changePhoneClicked()
    }
    
    public func validateOTP(with otp: String) {
        
    }
}
