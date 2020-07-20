//
//  TapSwitchView.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/19/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapThemeManager2020

@objc public class TapSwitchView: UIView {

    /// The container view that holds everything from the XIB
    @IBOutlet weak private var containerView: UIView!
    
    /// The stack view that holds all the switch views
    @IBOutlet weak private var stackView: UIStackView!
    
    ///
    @IBOutlet weak private var mainSwitch: TapSwitchControl!
    
    /// The view model that controls the data to be displayed and the events to be fired
    @objc public var viewModel:TapSwitchViewModel = .init()
    
    /// This contains the path of Tap Switch view theme in the theme manager
    private let themePath = "TapSwitchView"
    
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

    /**
     Seup the hint view according to the view model
     - Parameter viewModel: The new required view model to attach the view to
     */
    @objc public func setup(with viewModel: TapSwitchViewModel) {
        self.viewModel = viewModel
        self.viewModel.viewDelegate = self
    }
}

extension TapSwitchView: TapSwitchViewDelegate {
    
}
