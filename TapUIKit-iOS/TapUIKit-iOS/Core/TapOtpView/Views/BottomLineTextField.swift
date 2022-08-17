//
//  BottomLineTextField.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/12/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

/**
 Custom TexitField with disabling touch event
 */
class UnTouchableTextField: BottomLineTextField {
    
}

/**
 Custom TexitField with ability to add a bottom line to the field
 */
class BottomLineTextField: MyTextField {
    /// This hold the bottom line to give the ability to update the line attributes
    let bottomLine = CALayer()
    /**
     This function adding bottom line to the textfield
     - Parameter lineWidth: width of the line need to draw
     - Parameter color: color of the line need to draw
     */
    func addBottomLine(lineWidth: CGFloat, color: UIColor) {
        
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - lineWidth, width:  self.frame.size.width, height: lineWidth)
        bottomLine.backgroundColor = color.cgColor
        self.borderStyle = UITextField.BorderStyle.none
        
        self.layer.addSublayer(bottomLine)
        self.layer.masksToBounds = true
    }
    
}
