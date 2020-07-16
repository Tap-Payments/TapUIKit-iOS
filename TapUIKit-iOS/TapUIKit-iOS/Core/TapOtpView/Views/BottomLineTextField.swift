//
//  BottomLineTextField.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/12/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

class UnTouchableTextField: BottomLineTextField {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}

class BottomLineTextField: UITextField {
    let bottomLine = CALayer()
    func addBottomLine(lineWidth: CGFloat, color: UIColor) {
        
//        bottomLine.borderColor = color.cgColor
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - lineWidth, width:  self.frame.size.width, height: lineWidth)
//        bottomLine.borderWidth = lineWidth
        bottomLine.backgroundColor = color.cgColor
        self.borderStyle = UITextField.BorderStyle.none

        self.layer.addSublayer(bottomLine)
        self.layer.masksToBounds = true
    }

}
