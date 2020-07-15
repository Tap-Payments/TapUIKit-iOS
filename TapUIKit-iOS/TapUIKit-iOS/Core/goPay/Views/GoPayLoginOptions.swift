//
//  GoPayLoginOptions.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapCardInputKit_iOS
import CommonDataModelsKit_iOS
import SimpleAnimation
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
}



class GoPayLoginOptions: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var loginOptionsTabBar: TapGoPayLoginBarView!
    @IBOutlet weak var emailInput: TapEmailInput! {
        didSet {
            emailInput.setup()
            emailInput.delegate = self
        }
    }
    @IBOutlet weak var phoneInput: TapPhoneInput! {
        didSet {
            phoneInput.delegate = self
        }
    }
   
    
    /// The delegate that wants to hear from the view on new data and events
    var delegate:GoPayLoginOptionsPorotocl?
    
    /// The view model that has the needed payment options and data source to display the payment view
    var tapGoPayLoginBarViewModel:TapGoPayLoginBarViewModel = .init() {
        didSet {
            // On init, we need to:
            // Setup the bar view with the passed payment options list
            loginOptionsTabBar.setup(with: tapGoPayLoginBarViewModel)
            tapGoPayLoginBarViewModel.delegate = self
        }
    }
    
    var validationStatus:Bool = false {
        didSet{
            tapGoPayLoginBarViewModel.changeSelectionValidation(to: validationStatus)
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
    
    
    // MARK:- Private methods
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        showLoginView()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = bounds
    }
    
    
    internal func showLoginView() {
        loginOptionsTabBar.fadeIn()
        tap_theme_backgroundColor = .init(keyPath: "goPay.loginBar.backgroundColor")
    }
    
    /**
     Decides which input field should be shown based on the selected segment id
     - Parameter segment: The id of the segment of payment options we need to show the associated input
     */
    private func showInputFor(for  segment:GoPyLoginOption) {
        switch segment {
        case .Email:
            emailInput.fadeIn()
            phoneInput.fadeOut()
            validationStatus = (emailInput.validationStatus() == .Valid) ? true : false
        case .Phone:
            emailInput.fadeOut()
            phoneInput.fadeIn()
            validationStatus = (phoneInput.validationStatus() == .Valid) ? true : false
        }
    }
}


extension GoPayLoginOptions: TapEmailInputProtocol {
    
    func emailChanged(email: String, with validation: CrardInputTextFieldStatusEnum) {
        delegate?.emailChanged(email: email, with: validation)
        validationStatus = (validation == .Valid) ? true : false
    }
    
}


extension GoPayLoginOptions: TapPhoneInputProtocol {
    
    func phoneNumberChanged(phoneNumber: String) {
        let validation:CrardInputTextFieldStatusEnum = (tapCountry?.phoneLength ?? -1 == phoneNumber.count) ? .Valid : .Invalid
        delegate?.phoneChanged(phone: phoneNumber, with: validation)
        validationStatus = (validation == .Valid) ? true : false
    }
}


extension GoPayLoginOptions: TapGoPayLoginBarViewModelDelegate {
    
    func loginOptionSelected(with viewModel: TapGoPayTitleViewModel) {
        showInputFor(for: viewModel.titleSegment)
        delegate?.loginOptionSelected?(with: viewModel)
    }
}

