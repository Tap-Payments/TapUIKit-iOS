//
//  TapGoPayPasswordView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020

@objc public protocol TapGoPayPasswordViewProtocol {
    
    @objc func changeEmailClicked()
    
}

@objc public class TapGoPayPasswordView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var hintView: TapHintView!
    @IBOutlet weak var passwordView: TapGoPayPasswordTextField! {
        didSet{
            passwordView.delegate = self
        }
    }
    internal var hintViewModel:TapHintViewModel = .init(with: .GoPayPassword)
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    
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
        
    }
    
    public func returnClicked(with password: String) {
        
    }
}


extension TapGoPayPasswordView:TapHintViewModelDelegate {
    public func hintViewClicked(with viewModel: TapHintViewModel) {
        delegate?.changeEmailClicked()
    }
    
    
}
