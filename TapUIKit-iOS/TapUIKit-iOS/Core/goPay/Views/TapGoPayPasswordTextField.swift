//
//  TapGoPayPasswordView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import CommonDataModelsKit_iOS
// import SimpleAnimation
import LocalisationManagerKit_iOS
/// External protocol to allow the TapGoPayPasswordTextField to pass back data and events to the parent UIViewController
@objc public protocol TapGoPayPasswordTextFieldProtocol {
    /**
     This method will be called whenever the password  changed. It is being called in a live manner
     - Parameter password: The new password after the last update done bu the user
     */
    @objc func passwordChanged(to password:String)
    /**
     This method will be called whenever the user hits return on the password text
     - Parameter password: The password text inside the password field at the time the user hit return
     */
    @objc func returnClicked(with password:String)
}

/// Represents the view that shows the password step in the TapGoPayPasswordTextField which is a customised text field
@objc public class TapGoPayPasswordTextField: UIView {

    /// The view that holds everything
    @IBOutlet var contentView: UIView!
    /// The Tap password text field
    @IBOutlet weak var passwordTextField: UITextField!
    /// The underline view which shows a bottom line under the text field
    @IBOutlet weak var underLineView: UIView!
    /// A button to change the secure text value of th password text field
    @IBOutlet weak var visibleButton: UIButton!
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// The theme path that has the theme values for the gopay password field
    private let themePath:String = "goPay.passwordField"
    /// External protocol to allow the TapGoPayPasswordTextField to pass back data and events to the parent UIViewController
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
     Fetch the password string entered til now
     - Returns: The current password string in the text field and empty as a fallback
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
        let sharedLocalisationManager:TapLocalisationManager = .shared
        passwordTextField.textAlignment = (sharedLocalisationManager.localisationLocale == "ar") ? .right : .left
        applyTheme()
        
    }
    
    /// Handles the logic to negate the secure text value of the password text field
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
        // Inform the delegate that the password changed
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


