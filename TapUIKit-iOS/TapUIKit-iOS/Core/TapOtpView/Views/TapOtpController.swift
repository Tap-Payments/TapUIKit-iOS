//
//  TapOtpController.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

protocol TapOtpControllerDelegate: class {
    /**
     This method being called on digits changed by user
     */
    func digitsDidChange(newDigits: String)
}

public class TapOtpController: UIView, MyTextFieldDelegate,UITextFieldDelegate {
    
    @IBOutlet weak private var textField1: BottomLineTextField!
    @IBOutlet private var untouchableTextField: [UnTouchableTextField]!
    
    /// Set text color of textField digits
    public var textColor: UIColor = .white {
        didSet {
            self.textField1.textColor = self.textColor
            self.untouchableTextField.forEach { $0.textColor = self.textColor }
        }
    }
    
    /// Set the bottom line width to be added to the digits textFields
    public var bottomLineWidth: CGFloat = 1
    /// Set the bottom line color to be added to the digits textFields
    public var bottomLineColor: UIColor = .white {
        didSet {
            self.textField1.bottomLine.backgroundColor = self.bottomLineColor.cgColor
            self.untouchableTextField.forEach { $0.bottomLine.backgroundColor = self.bottomLineColor.cgColor }
        }
    }
    
    /// Set the font of the textField digits
    public var font: UIFont = .systemFont(ofSize: 12) {
        didSet {
            self.textField1.font = self.font
            self.untouchableTextField.forEach { $0.font = self.font }
        }
    }
    /// Set the bottom line color when the textField is active
    public var bottomLineActiveColor: UIColor = .blue
    
    /// Delegate to fire events on otp digits change
    weak var delegate: TapOtpControllerDelegate? {
        didSet {
            self.moveKeyboardToFirstTextField()
        }
    }
    
    private var contentView: UIView?
    
    /// Holds the digits list as strings to be passed to the owner view
    private var digits: [String] = ["", "", "", "", "", ""]
    
    /// Set initial textfield enabled to user interaction, true to enable user interaction
    public var enabled: Bool = true {
        didSet {
            self.textField1.isUserInteractionEnabled = enabled
        }
    }
    
    public override func awakeFromNib() {
        superview?.awakeFromNib()
        self.configure()
    }
    
    // MARK:- Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }
    
    private func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TapOtpController", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    // MARK:- configure
    /// Configures the textfields properties to make the view ready for user interaction
    func configure() {
        
        setTextFieldsDelegate()
        
        self.textField1.textColor = self.textColor
        self.untouchableTextField.forEach { $0.textColor = self.textColor }
        
        self.textField1.addBottomLine(lineWidth: bottomLineWidth, color: bottomLineColor)
        self.untouchableTextField.forEach { $0.addBottomLine(lineWidth: bottomLineWidth, color: bottomLineColor) }
        
        self.untouchableTextField.forEach { $0.keyboardType = .numberPad }
        self.textField1.keyboardType = .numberPad
    }
    /// Set the textFields delegates
    fileprivate func setTextFieldsDelegate() {
        self.textField1.myDelegate = self
        self.textField1.delegate = self
        self.untouchableTextField.forEach {
            $0.myDelegate = self
            $0.delegate = self
        }
    }
    
    // MARK: UITextFieldDelegate
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if let textFieldObj = textField as? BottomLineTextField {
            textFieldObj.bottomLine.backgroundColor = self.bottomLineActiveColor.cgColor
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if let textFieldObj = textField as? BottomLineTextField {
            textFieldObj.bottomLine.backgroundColor = self.bottomLineColor.cgColor
        }
    }
    
    /**
     Update the digits list depending on textField value change
     - Parameter textField: the updated textField
     - Parameter index: index of textField to update digits array
     */
    private func updateDigits(_ textField: UITextField) {
        print("updateDigits: value: \(String(describing: textField.text))")
        let index = textField.tag - 1
        digits[index] = textField.text!
        /// Callback the delegate with the changed digits
        print("current digits: \(digits)")
        self.delegate?.digitsDidChange(newDigits: digits.joined())
    }
    
    
    func textFieldDidDelete(_ textField:UITextField) {
        moveToPreviousTextField(textField)
        textField.text = ""
        self.updateDigits(textField)
    }
    
    
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //        if let pasteValue = UIPasteboard.general.string {
        //
        //           print("paste: \(pasteValue)")
        //            self.paste(value: pasteValue)
        //            return false
        //        }
        
        print("string : \(string)")
        if textField.text!.count < 1 && string.count > 0 {
            moveToNextTextField(textField)
            textField.text = string
            self.updateDigits(textField)
            return false
        } else if textField.text!.count >= 1 && string.count == 0 {
            moveToPreviousTextField(textField)
            textField.text = ""
            self.updateDigits(textField)
            return false
            
        }
        else if textField.text!.count >= 1 {
            moveToNextTextField(textField)
            textField.text = string
            self.updateDigits(textField)
            return false
        }
        return true
    }
    
    
    // MARK: TextField Paste
    func paste(value: String) {
        for (index, char) in value.enumerated() {
            if index > 5 {
                self.resignAllTextFields()
                break
            }
            if index > 0 {
                self.untouchableTextField[index].text = "\(char)"
                self.updateDigits(self.untouchableTextField[index])
            } else {
                self.textField1.text = "\(char)"
                self.updateDigits(textField1)
            }
        }
    }
    
    // MARK: TextField Movements
    /**
     Decide the next textField to become active
     - Parameter textField: the current active textField
     */
    fileprivate func moveToNextTextField(_ textField: UITextField) {
        let currentTag = textField.tag
        
        if currentTag == self.untouchableTextField.count + 1 {
            textField.resignFirstResponder()
            return
        }
        let currentIndex = currentTag == 1 ? -1 : currentTag - 2
        
        self.untouchableTextField[currentIndex + 1].becomeFirstResponder()
    }
    
    /**
     Decide the previous textField to become active
     - Parameter textField: the current active textField
     */
    fileprivate func moveToPreviousTextField(_ textField: UITextField) {
        let currentTag = textField.tag
        if currentTag <= 2 {
            textField1.becomeFirstResponder()
            return
        }
        //textField.resignFirstResponder()
        self.untouchableTextField[currentTag - 3].becomeFirstResponder()
    }
    
    // MARK: - MoveToFirstTextField
    func moveKeyboardToFirstTextField() {
        self.textField1.becomeFirstResponder()
    }
    
    // MARK: ResetAllTextFields
    /**
     Resign all textField and dismiss keyboard
     */
    fileprivate func resignAllTextFields() {
        self.textField1.resignFirstResponder()
        self.untouchableTextField.forEach{ $0.resignFirstResponder() }
    }
    
    /**
     Reset All the digits and dismiss the keyboard
     */
    public func resetAll() {
        self.digits = ["", "", "", "", "", ""]
        self.textField1.text = ""
        self.untouchableTextField.forEach {
            $0.text = ""
        }
        resignAllTextFields()
    }
}




internal protocol MyTextFieldDelegate: AnyObject {
    func textFieldDidDelete(_ textField:UITextField)
}

internal class MyTextField: UITextField {
    
    weak var myDelegate: MyTextFieldDelegate?
    
    override func deleteBackward() {
        super.deleteBackward()
        myDelegate?.textFieldDidDelete(self)
    }
    
}
