//
//  TapOtpController.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

protocol BottomLineTextFieldProtocol {
    var bottomLine: CALayer { get set }
}

@IBDesignable
public class TapOtpController: UIView, UITextFieldDelegate {
    
    @IBOutlet private weak var textField1: BottomLineTextField!
    @IBOutlet private weak var textField2: BottomLineTextField!
    @IBOutlet private weak var textField3: BottomLineTextField!
    @IBOutlet private weak var textField4: BottomLineTextField!
    @IBOutlet private weak var textField5: BottomLineTextField!
    @IBOutlet private weak var textField6: BottomLineTextField!
    
    
    @IBInspectable public var pinCount: Int = 4
    @IBInspectable public var textColor: UIColor = .white
    @IBInspectable public var bottomLineWidth: Int = 2
    
    
    private var contentView: UIView?
    
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
        
        self.textField1.addBottomLine()
        self.textField2.addBottomLine()
        self.textField3.addBottomLine()
        self.textField4.addBottomLine()
        self.textField5.addBottomLine()
        self.textField6.addBottomLine()
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
            textFieldObj.bottomLine.borderColor = UIColor.blue.cgColor
        }
//        textField.
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if let textFieldObj = textField as? BottomLineTextField {
            textFieldObj.bottomLine.borderColor = textFieldObj.textColor?.cgColor
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.count < 1 && string.count > 0 {
            moveToNextTextField(textField)
            textField.text = string
            return false
        } else if textField.text!.count >= 1 && string.count == 0 {
            moveToPreviousTextField(textField)
            textField.text = ""
            return false
            
        }
        else if textField.text!.count >= 1 {
            textField.text = string
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
}
