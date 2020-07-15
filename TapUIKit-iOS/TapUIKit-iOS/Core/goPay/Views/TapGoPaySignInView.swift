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

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var goPayLoginOptionsView: GoPayLoginOptions! {
        didSet {
            goPayLoginOptionsView.delegate = self
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

}



extension TapGoPaySignInView: GoPayLoginOptionsPorotocl {
    
    func emailChanged(email: String, with validation: CrardInputTextFieldStatusEnum) {
        
    }
    
    func phoneChanged(phone: String, with validation: CrardInputTextFieldStatusEnum) {
        
    }
    
    
}
