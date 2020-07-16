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

@objc public class TapGoPaySignInView: UIView {

    let animationDuration:Double = 0.5
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var goPayLoginOptionsView: GoPayLoginOptions! {
        didSet {
            goPayLoginOptionsView.delegate = self
        }
    }
    
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
    }
    
    func phoneReturned(with phon: String) {
        
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
