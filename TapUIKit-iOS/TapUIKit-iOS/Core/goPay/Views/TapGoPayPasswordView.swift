//
//  TapGoPayPasswordView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
/// External protocol to allow the TapGoPayPasswordView to pass back data and events to the parent UIViewController
@objc public protocol TapGoPayPasswordViewProtocol {
    
    /// Will be fired once the user asks to change the email written in the previous step
    @objc func changeEmailClicked()
    
    /**
     This method will be called whenever the user hits return on the password text
     - Parameter password: The password text inside the password field at the time the user hit return
     */
    @objc func returnClicked(with password:String)
    
}

/// Represents the goay pssword view which will have the password text field + the upper hint + the change button
@objc public class TapGoPayPasswordView: UIView {

    /// The super view that holds everything
    @IBOutlet var contentView: UIView!
    /// The upper hint view that shows the email and the change button
    @IBOutlet weak var hintView: TapHintView!
    /// The password textfield correctly themable and customised
    @IBOutlet weak var passwordView: TapGoPayPasswordTextField! {
        didSet{
            passwordView.delegate = self
        }
    }
    /// The view model needed to create the upper hint view
    internal var hintViewModel:TapHintViewModel = .init(with: .GoPayPassword)
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// External protocol to allow the TapGoPayPasswordView to pass back data and events to the parent UIViewController
    @objc public var delegate:TapGoPayPasswordViewProtocol?
    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        hintViewModel.delegate = self
        hintView.setup(with: hintViewModel)
        applyTheme()
    }
    
    internal func passwordAction() {
        let actionButtonBlock:()->() = { [weak self] in
            self?.returnClicked(with: self?.passwordView.password() ?? "")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetBlockNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetBlockNotification:actionButtonBlock] )
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetStatusNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetStatusNotification:TapActionButtonStatusEnum.InvalidSignIn] )
    }
    
    /**
     Setup the view and show proper message
     - Parameter email: The email that was entered by the user in the previous step
     */
    @objc public func setup(with email:String) {
        hintViewModel.overrideTitle = email
    }
}




// Mark:- Theme methods
extension TapGoPayPasswordView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
       tap_theme_backgroundColor = .init(keyPath: "goPay.passwordView.backgroundColor")
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


extension TapGoPayPasswordView:TapGoPayPasswordTextFieldProtocol {
    public func passwordChanged(to password: String) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:  TapConstantManager.TapActionSheetStatusNotification), object: nil, userInfo: [TapConstantManager.TapActionSheetStatusNotification:(password == "") ? TapActionButtonStatusEnum.InvalidSignIn : TapActionButtonStatusEnum.ValidSignIn] )
    }
    
    public func returnClicked(with password: String) {
        delegate?.returnClicked(with: password)
    }
}


extension TapGoPayPasswordView:TapHintViewModelDelegate {
    public func hintViewClicked(with viewModel: TapHintViewModel) {
        delegate?.changeEmailClicked()
    }
    
    
}
