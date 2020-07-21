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
    @IBOutlet weak private var mainSwitchControl: TapSwitchControl!
    
    private var bottomCurvedSeparator: UIView?
    internal var tapBottomSheetRadiousCorners:CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    internal var tapBottomSheetControllerRadious:CGFloat = 8

    private var goPaySwitchControl: TapSwitchControl?
    private var merchantSwitchControl: TapSwitchControl?
    
    /// The view model that controls the data to be displayed and the events to be fired
    @objc public var viewModel:TapSwitchViewModel = .init(mainSwitch: TapSwitchModel(title: "Temp Title", subtitle: "Temp subtitle"), goPaySwitch: TapSwitchModel(title: "goPay Title", subtitle: "goPay subtitle"), merchantSwitch: TapSwitchModel(title: "merchant Title", subtitle: "merchant subtitle"))
    
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
            applyTheme()
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
        self.configureMainSwitch()
    }
    
    // MARK: Configure Switches
    internal func configureMainSwitch() {
        self.mainSwitchControl.configure(with: self.viewModel.mainSwitch)
        if self.mainSwitchControl.delegate == nil {
            self.mainSwitchControl.delegate = self
        }
    }
    
    internal func createMerchantSwitch() {
        if let merchantSwitch = viewModel.merchantSwitch {
            if self.merchantSwitchControl == nil {
                self.merchantSwitchControl = .init()
                applyTheme()
            }
            self.merchantSwitchControl!.configure(with: merchantSwitch)
            self.merchantSwitchControl?.delegate = self
            
            if self.merchantSwitchControl!.isHidden {
                self.merchantSwitchControl?.isHidden.toggle()
            } else {
                self.stackView.addArrangedSubview(self.merchantSwitchControl!)
            }
            self.merchantSwitchControl?.isOn = true
        }
    }
    
    internal func createGoPaySwitch() {
        if let goPaySwitch = viewModel.goPaySwitch {
            if self.goPaySwitchControl == nil {
                self.goPaySwitchControl = .init()
                applyTheme()
            }
            self.goPaySwitchControl!.configure(with: goPaySwitch)
            self.goPaySwitchControl?.delegate = self
            if self.goPaySwitchControl!.isHidden {
                self.goPaySwitchControl?.isHidden.toggle()
            } else {
                self.stackView.addArrangedSubview(self.goPaySwitchControl!)
            }
            self.goPaySwitchControl?.isOn = true
        }
    }
    
    // MARK: Bottom Curved View
    func createCurvedSeparatorView() {
        if self.bottomCurvedSeparator == nil {
            self.bottomCurvedSeparator = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 4))
            bottomCurvedSeparator!.translatesAutoresizingMaskIntoConstraints = false
            bottomCurvedSeparator!.heightAnchor.constraint(equalToConstant: 4).isActive = true
        }
        self.bottomCurvedSeparator?.tap_theme_backgroundColor = .init(keyPath: "\(themePath).CurvedSeparator.BackgroundColor")
        self.bottomCurvedSeparator?.tapRoundCorners(corners: tapBottomSheetRadiousCorners, radius: tapBottomSheetControllerRadious)
        if self.bottomCurvedSeparator!.isHidden {
            self.bottomCurvedSeparator?.isHidden.toggle()
        } else {
            self.stackView.addArrangedSubview(self.bottomCurvedSeparator!)
        }
    }
}

extension TapSwitchView: TapSwitchViewDelegate {
    func removeSubSwitches() {
        if let goPaySwitchControl = self.goPaySwitchControl {
            if self.stackView.arrangedSubviews.contains(goPaySwitchControl) {
                goPaySwitchControl.isHidden = true
            }
        }
        
        if let merchantSwitchControl = self.merchantSwitchControl {
            if self.stackView.arrangedSubviews.contains(merchantSwitchControl) {
                merchantSwitchControl.isHidden = true
            }
        }
            
               
        if let bottomCurvedSeparator = self.bottomCurvedSeparator {
            if self.stackView.arrangedSubviews.contains(bottomCurvedSeparator) {
                bottomCurvedSeparator.isHidden = true
            }
        }
        
        self.mainSwitchControl.isOn = false
    }
    
    func addSubSwitches() {
        self.createCurvedSeparatorView()
        self.createMerchantSwitch()
        self.createGoPaySwitch()
    }
    
    
}

extension TapSwitchView: TapSwitchControlDelegate {
    func switchDidChange(sender: TapSwitchControl, isOn: Bool) {
        switch sender {
        case self.mainSwitchControl:
            self.viewModel.updateMainSwitchState(isOn: isOn)
        case self.goPaySwitchControl:
            self.viewModel.updateGoPaySwitchState(isOn: isOn)
        case self.merchantSwitchControl:
            self.viewModel.updateMerchantSwitchState(isOn: isOn)
        default: break
        }
    }
}


// Mark:- Theme methods
extension TapSwitchView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        self.goPaySwitchControl?.switchOnColor = TapThemeManager.colorValue(for: "\(themePath).goPay.SwitchOnColor") ?? .blue
        self.merchantSwitchControl?.switchOnColor = TapThemeManager.colorValue(for: "\(themePath).merchant.SwitchOnColor") ?? .blue
        
        
        self.merchantSwitchControl?.titleFont = TapThemeManager.fontValue(for: "\(themePath).merchant.title.textFont") ?? .systemFont(ofSize: 12)
        
        self.merchantSwitchControl?.subtitleFont = TapThemeManager.fontValue(for: "\(themePath).merchant.subtitle.textFont") ?? .systemFont(ofSize: 12)
        
        self.goPaySwitchControl?.titleFont = TapThemeManager.fontValue(for: "\(themePath).goPay.title.textFont") ?? .systemFont(ofSize: 12)
        
        self.goPaySwitchControl?.subtitleFont = TapThemeManager.fontValue(for: "\(themePath).goPay.subtitle.textFont") ?? .systemFont(ofSize: 12)
        
//        let status: TapOTPStateEnum = viewModel.state
        
//        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        
//        timerLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).Timer.textColor")
//        timerLabel.tap_theme_font = .init(stringLiteral: "\(themePath).Timer.textFont",shouldLocalise:false)
//
//        self.messageLabel.tap_theme_font = .init(stringLiteral: "\(status.themePath()).Message.textFont",shouldLocalise:false)
//
//        self.otpController.bottomLineColor = TapThemeManager.colorValue(for: "\(themePath).OtpController.bottomLineColor") ?? .white
//        self.otpController.bottomLineActiveColor = TapThemeManager.colorValue(for: "\(themePath).OtpController.activeBottomColor") ?? .blue
//
//        self.otpController.textColor = TapThemeManager.colorValue(for: "\(themePath).OtpController.textColor") ?? .black
//        self.otpController.font = TapThemeManager.fontValue(for: "\(themePath).OtpController.textFont") ?? .systemFont(ofSize: 12)
    }
    
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
