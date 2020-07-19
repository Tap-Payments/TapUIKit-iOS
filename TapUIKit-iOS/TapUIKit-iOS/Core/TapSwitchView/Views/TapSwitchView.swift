//
//  TapSwitchView.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/19/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit

class TapSwitchView: UIView {

    /// The container view that holds everything from the XIB
    @IBOutlet weak private var containerView: UIView!
    
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
            self.containerView = setupXIB()
            //handlerImageView.translatesAutoresizingMaskIntoConstraints = false
    //        applyTheme()
        }
        
        /// Updates the container view frame to the parent view bounds
        public override func layoutSubviews() {
            super.layoutSubviews()
            self.containerView.frame = bounds
        }

}
