//
//  TapGoPayPasswordView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import CommonDataModelsKit_iOS
import SimpleAnimation
import LocalisationManagerKit_iOS

@objc public protocol TapGoPayPasswordTextFieldProtocol {
    @objc func passwordChanged(to password:String)
    @objc func returnClicked(with password:String)
}

@objc public class TapGoPayPasswordTextField: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var underLineView: UIView!
    @IBOutlet weak var visibleButton: UIButton!
    
    
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    private let themePath:String = "goPay.passwordField"
    
    @objc public var delegate:TapGoPayPasswordTextFieldProtocol?
    
    
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
     */
    @objc public func password() -> String {
        return passwordTextField.text ?? ""
    }
    
    /// The method will show the keyboard on the psasword field
    @objc public func focus() {
        passwordTextField.becomeFirstResponder()
        themeUnderLine()
    }
    
    
    // MARK:- Private methods
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        configurePasswordField()
    }
    
    /// Apply the needed logic to reload UI and localisations upon an order from the view model
    private func configurePasswordField() {
        
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        // Listen to the event of text change
        passwordTextField.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
        applyTheme()
        
    }
    
    @IBAction func visibleButtonClicked(_ sender: Any) {
        // Flip the security attribute of the field
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
    }
    
    
    /**
     This method does the logic required when a text change event is fired for the text field
     - Parameter textField: The text field that has its text changed
     */
    @objc func didChangeText(textField:UITextField) {
        guard passwordTextField == textField else { return }
        delegate?.passwordChanged(to: passwordTextField.text ?? "")
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = bounds
    }
    
}


extension TapGoPayPasswordTextField:UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        themeUnderLine()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        themeUnderLine()
    }
    
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.returnClicked(with: textField.text ?? "")
        textField.resignFirstResponder()
        return true
    }
}


// Mark:- Theme methods
extension TapGoPayPasswordTextField {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        let sharedLocalisationManager:TapLocalisationManager = .shared
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        passwordTextField.tap_theme_font = .init(stringLiteral: "\(themePath).textFont")
        passwordTextField.tap_theme_textColor = .init(stringLiteral: "\(themePath).textColor")
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: sharedLocalisationManager.localisedValue(for: "Common.password", with: TapCommonConstants.pathForDefaultLocalisation()), attributes: [NSAttributedString.Key.foregroundColor: TapThemeManager.colorValue(for: "\(themePath).placeHolderColor") ?? .black])
        
        themeShowPasswordButton()
        themeUnderLine()
        
    }
    
    private func themeShowPasswordButton() {
        visibleButton.tap_theme_setImage(selector: .init(keyPath: "\(themePath).showPasswordIcon"), forState: .normal)
    }
    
    private func themeUnderLine() {
        let underLineStatusThemePath:String = passwordTextField.isEditing ? "underline.filled" : "underline.empty"
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.underLineView.tap_theme_backgroundColor = .init(stringLiteral: "\(self?.themePath ?? "").\(underLineStatusThemePath).backgroundColor")
        })
        
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


