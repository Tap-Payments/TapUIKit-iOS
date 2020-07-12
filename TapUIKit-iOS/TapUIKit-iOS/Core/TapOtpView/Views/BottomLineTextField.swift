//
//  BottomLineTextField.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/12/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

class BottomLineTextField: UITextField {
    let bottomLine = CALayer()
    var bottomLineWidth = 1
    func addBottomLine() {
        
        let width = CGFloat(self.bottomLineWidth)
        bottomLine.borderColor = self.textColor?.cgColor
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        bottomLine.borderWidth = width
        self.layer.addSublayer(bottomLine)
        self.layer.masksToBounds = true
    }

}
