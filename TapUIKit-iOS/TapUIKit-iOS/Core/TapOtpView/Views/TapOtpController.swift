//
//  TapOtpController.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

protocol TapOtpControllerDelegate: class {
    func digitsDidChange(newDigits: String)
}

public class TapOtpController: UIView, UITextFieldDelegate {
    
    @IBOutlet weak private var textField1: BottomLineTextField!
    @IBOutlet weak private var textField2: UnTouchableTextField!
    @IBOutlet weak private var textField3: UnTouchableTextField!
    @IBOutlet weak private var textField4: UnTouchableTextField!
    @IBOutlet weak private var textField5: UnTouchableTextField!
    @IBOutlet weak private var textField6: UnTouchableTextField!
    
    
    public var pinCount: Int = 4
    public var textColor: UIColor = .white {
        didSet {
            self.textField1.textColor = self.textColor
            self.textField2.textColor = self.textColor
            self.textField3.textColor = self.textColor
            self.textField4.textColor = self.textColor
            self.textField5.textColor = self.textColor
            self.textField6.textColor = self.textColor
        }
    }

    public var bottomLineWidth: CGFloat = 1
    public var bottomLineColor: UIColor = .white {
        didSet {
            self.textField1.bottomLine.backgroundColor = self.bottomLineColor.cgColor
            self.textField2.bottomLine.backgroundColor = self.bottomLineColor.cgColor
            self.textField3.bottomLine.backgroundColor = self.bottomLineColor.cgColor
            self.textField4.bottomLine.backgroundColor = self.bottomLineColor.cgColor
            self.textField5.bottomLine.backgroundColor = self.bottomLineColor.cgColor
            self.textField6.bottomLine.backgroundColor = self.bottomLineColor.cgColor
        }
    }
    
    public var font: UIFont = .systemFont(ofSize: 12) {
        didSet {
            self.textField1.font = self.font
            self.textField2.font = self.font
            self.textField3.font = self.font
            self.textField4.font = self.font
            self.textField5.font = self.font
            self.textField6.font = self.font
        }
    }
    public var bottomLineActiveColor: UIColor = .blue

    weak var delegate: TapOtpControllerDelegate?
    
    private var contentView: UIView?
        
    private var digits: [String] = ["", "", "", "", "", ""]
    
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
    func configure() {
        
        setTextFieldsDelegate()
        
        
        self.textField1.textColor = self.textColor
        self.textField2.textColor = self.textColor
        self.textField3.textColor = self.textColor
        self.textField4.textColor = self.textColor
        self.textField5.textColor = self.textColor
        self.textField6.textColor = self.textColor
        
        self.textField1.addBottomLine(lineWidth: bottomLineWidth, color: bottomLineColor)
        self.textField2.addBottomLine(lineWidth: bottomLineWidth, color: bottomLineColor)
        self.textField3.addBottomLine(lineWidth: bottomLineWidth, color: bottomLineColor)
        self.textField4.addBottomLine(lineWidth: bottomLineWidth, color: bottomLineColor)
        self.textField5.addBottomLine(lineWidth: bottomLineWidth, color: bottomLineColor)
        self.textField6.addBottomLine(lineWidth: bottomLineWidth, color: bottomLineColor)
        
        self.textField1.keyboardType = .asciiCapableNumberPad
        self.textField2.keyboardType = .asciiCapableNumberPad
        self.textField3.keyboardType = .asciiCapableNumberPad
        self.textField4.keyboardType = .asciiCapableNumberPad
        self.textField5.keyboardType = .asciiCapableNumberPad
        self.textField6.keyboardType = .asciiCapableNumberPad
        
    }
    
    fileprivate func setTextFieldsDelegate() {
        self.textField1.delegate = self
        self.textField2.delegate = self
        self.textField3.delegate = self
        self.textField4.delegate = self
        self.textField5.delegate = self
        self.textField6.delegate = self
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
    
    private func updateDigits(_ textField: UITextField) {
        print("updateDigits: value: \(String(describing: textField.text))")
        switch textField {
        case textField1:
            digits[0] = textField.text!
        case textField2:
            digits[1] = textField.text!
        case textField3:
            digits[2] = textField.text!
        case textField4:
            digits[3] = textField.text!
        case textField5:
            digits[4] = textField.text!
        case textField6:
            digits[5] = textField.text!
                
        default: break
        }
        self.delegate?.digitsDidChange(newDigits: digits.joined())
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
    
    
    
    // MARK: TextField Movements
    fileprivate func moveToNextTextField(_ textField: UITextField) {
        if textField == textField1 {
            textField2.becomeFirstResponder()
        }
        
        if textField == textField2 {
            textField3.becomeFirstResponder()
        }
        
        if textField == textField3 {
            textField4.becomeFirstResponder()
        }
        
        if textField == textField4 {
            textField5.becomeFirstResponder()
        }
        
        if textField == textField5 {
            textField6.becomeFirstResponder()
        }
        
        if textField == textField6 {
            textField6.resignFirstResponder()
        }
    }
    
    fileprivate func moveToPreviousTextField(_ textField: UITextField) {
        if textField == textField6 {
            textField5.becomeFirstResponder()
        }
        
        if textField == textField5 {
            textField4.becomeFirstResponder()
        }
        
        if textField == textField4 {
            textField3.becomeFirstResponder()
        }
        
        if textField == textField3 {
            textField2.becomeFirstResponder()
        }
        
        if textField == textField2 {
            textField1.becomeFirstResponder()
        }
    }
    
    // MARK: ResetAllTextFields
    public func resetAll() {
        self.digits = ["", "", "", "", "", ""]
        self.textField1.text = ""
        self.textField2.text = ""
        self.textField3.text = ""
        self.textField4.text = ""
        self.textField5.text = ""
        self.textField6.text = ""
        
        self.textField1.resignFirstResponder()
        self.textField2.resignFirstResponder()
        self.textField3.resignFirstResponder()
        self.textField4.resignFirstResponder()
        self.textField5.resignFirstResponder()
        self.textField6.resignFirstResponder()
    }
}
