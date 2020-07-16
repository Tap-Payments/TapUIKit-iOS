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

/// External protocol to allow the GoPayLoginOptions to pass back data and events to the parent UIViewController
@objc public protocol TapGoPaySignInViewProtocol {
    
    /**
     Will be fired once the user make a selection to change the login option from the tab bar
     - Parameter viewModel: THe selected login option view model
     */
    @objc optional func loginOptionSelected(with viewModel: TapGoPayTitleViewModel)
    
    /// This method will be called whenever the user hits return on the email text
    @objc optional func emailReturned(with email:String)
    
    /// This method will be called whenever the user hits return on the phone text
    @objc optional func phoneReturned(with phon:String)
    
    /// This method will be called whenever the user clicked on the country code
    @objc optional func countryCodeClicked()
}
@objc public class TapGoPaySignInView: UIView {

    let animationDuration:Double = 0.5
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var goPayLoginOptionsView: GoPayLoginOptions! {
        didSet {
            goPayLoginOptionsView.delegate = self
        }
    }
    internal var originalHeight:CGFloat = 0
    
    @IBOutlet weak var goPayPasswordView: TapGoPayPasswordView! {
        didSet {
            goPayPasswordView.delegate = self
        }
    }
    
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
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
    
    @objc public var delegate:TapGoPaySignInViewProtocol?
    
    /**
     Seup the hint view according to the view model
     - Parameter viewModel: The new required view model to attach the view to
     - Parameter tapCountry: Represents the country that telecom options are being shown for, used to handle country code and correct phone length
     */
    @objc public func setup(with viewModel:TapGoPayLoginBarViewModel,and tapCountry:TapCountry) {
        goPayLoginOptionsView.tapGoPayLoginBarViewModel = viewModel
        goPayLoginOptionsView.tapCountry = tapCountry
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
    
    
    internal func showPasswordView(with email:String) {
        goPayPasswordView.setup(with: email)
        goPayPasswordView.fadeIn(duration: animationDuration)
        goPayPasswordView.slideIn(from: .bottom, x:0, y: 250, duration: animationDuration, delay: 0)
    }
    
    
    internal func showLoginOptions(focus field:GoPyLoginOption? = nil) {
        if let field = field {
            goPayLoginOptionsView.focus(field: field)
        }
        goPayLoginOptionsView.fadeIn(duration:animationDuration)
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
        delegate?.phoneReturned?(with: phon)
    }
    
    func countryCodeClicked() {
        //delegate?.countryCodeClicked?()
        showCountryPicker()
    }
    
    internal func showCountryPicker() {
        
        changeHeight(with: 250)
        // Show the picker just after the animation of height changed
        let data: [[String]] = [["Kevin", "Lauren", "Kibby", "Stella"]]
        let mcPicker = McPicker(data: data)
        
        
        
        mcPicker.backgroundColor = .gray
        mcPicker.backgroundColorAlpha = 0
        mcPicker.pickerBackgroundColor = .init(white: 1, alpha: 0.8)
        let fixedSpace = McPickerBarButtonItem.fixedSpace(width: 9.0)
        let flexibleSpace = McPickerBarButtonItem.flexibleSpace()
        let fireButton = McPickerBarButtonItem.done(mcPicker: mcPicker, title: "Done", barButtonSystemItem: .done) // Set custom Text
        let cancelButton = McPickerBarButtonItem.cancel(mcPicker: mcPicker, barButtonSystemItem: .cancel) // or system items
        // Set custom toolbar items
        mcPicker.setToolbarItems(items: [fixedSpace, cancelButton, flexibleSpace, fireButton, fixedSpace])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150)) {
            mcPicker.show(doneHandler: { [weak self] (Selection) in
                self?.changeHeight(with: -250)
                }, cancelHandler: { [weak self] in
                    self?.changeHeight(with: -250)
            }) { (Selections, Index) in
                
            }
        }
    }
    
    
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
}


extension TapGoPaySignInView: TapGoPayPasswordViewProtocol {
    
    public func changeEmailClicked() {
        // Show login opions view
        showLoginOptions(focus: .Email)
        goPayPasswordView.slideOut(to:.bottom,duration:animationDuration)
        goPayPasswordView.fadeOut(duration:animationDuration)
    }
    
}
