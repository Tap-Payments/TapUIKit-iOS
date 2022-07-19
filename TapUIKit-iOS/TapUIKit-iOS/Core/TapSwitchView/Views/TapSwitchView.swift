//
//  TapSwitchView.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/19/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//
import UIKit
import TapThemeManager2020

/// Represents the Tap Switch View
@objc public class TapSwitchView: UIView {
    
    /// The container view that holds everything from the XIB
    @IBOutlet weak private var containerView: UIView!
    /// The stack view that holds all the switch views
    @IBOutlet weak private var stackView: UIStackView!
    /// Represents the main switch control that controls the enabling / disabling goPay and merchant switches
    @IBOutlet weak private var mainSwitchControl: TapSwitchControl!
    /// Represents the bottom corners round masks
    internal var tapBottomSheetRadiousCorners:CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    /// Represents the corner radius value
    internal var tapBottomSheetControllerRadious:CGFloat = 8
    /// Represents goPay switch control view
    private var goPaySwitchControl: TapSwitchControl?
    /// Represents merchant switch control view
    private var merchantSwitchControl: TapSwitchControl?
    /// The view model that controls the data to be displayed and the events to be fired
    @objc public var viewModel:TapSwitchViewModel = .init(with: .invalidCard, merchant: "jazeera airways",whichSwitchesToShow: .all)
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
    @objc public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
    
    /**
     Seup the hint view according to the view model
     - Parameter viewModel: The new required view model to attach the view to
     - Parameter adjustConstraints: Tells the view if it needs to handle itself regarding dynamic height for the main switch and the sub switches, default is false meaning the super view will takecare about it
     */
    @objc public func setup(with viewModel: TapSwitchViewModel, adjustConstraints:Bool = false) {
        self.viewModel = viewModel
        self.viewModel.viewDelegate = self
        self.configureMainSwitch()
        if adjustConstraints {
            self.adjustConstraints()
        }
    }
    
    @objc override func shouldShowTapView() -> Bool {
        return viewModel.shouldShow
    }
    
    /// Tells the view if it needs to handle itself regarding dynamic height for the main switch and the sub switches. hence, will set the requied constraints to automaically enlarge the height to match the added switches
    internal func adjustConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        
        let originalHeightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 63)
        originalHeightConstraint.priority = .defaultHigh
        
        let acceptedHeightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 63)
        
        originalHeightConstraint.isActive = true
        acceptedHeightConstraint.isActive = true
        
        addConstraints([originalHeightConstraint,acceptedHeightConstraint])
    }
    
    // MARK: Configure Switches
    /// Configures the mains swtich view and set delegate if not set yet
    internal func configureMainSwitch() {
        self.mainSwitchControl.configure(with: self.viewModel.mainSwitch)
        if self.mainSwitchControl.delegate == nil {
            self.mainSwitchControl.delegate = self
        }
    }
    
    /// Configure the merchant switch view and display it on the view
    internal func showMerchantSwitch() {
        if let merchantSwitch = viewModel.merchantSwitch, let _ = viewModel.goPaySwitch {
            if self.merchantSwitchControl == nil {
                self.merchantSwitchControl = .init()
                applyTheme()
                self.merchantSwitchControl?.showSeparator = viewModel.goPaySwitch != nil
            }
            self.merchantSwitchControl!.configure(with: merchantSwitch)
            self.merchantSwitchControl?.delegate = self
            
            if self.merchantSwitchControl!.isHidden {
                self.merchantSwitchControl?.isHidden.toggle()
            } else {
                self.merchantSwitchControl?.translatesAutoresizingMaskIntoConstraints = false
                self.merchantSwitchControl?.heightAnchor.constraint(greaterThanOrEqualToConstant: 63).isActive = true
                self.stackView.addArrangedSubview(self.merchantSwitchControl!)
            }
            self.merchantSwitchControl?.isOn = true
        }
    }
    /// Configure the go pay switch view and display it on the view
    internal func showGoPaySwitch() {
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
                self.goPaySwitchControl?.translatesAutoresizingMaskIntoConstraints = false
                self.goPaySwitchControl?.heightAnchor.constraint(equalToConstant: 120).isActive = true
                self.stackView.addArrangedSubview(self.goPaySwitchControl!)
            }
            self.goPaySwitchControl?.isOn = true
        }
    }
    
    // MARK: Bottom Curved View
    /// Configure the main switch view to have a curved bottom corners
    func showCurvedSeparatorView() {
        self.mainSwitchControl.tapRoundCorners(corners: tapBottomSheetRadiousCorners, radius: tapBottomSheetControllerRadious)
    }
}

extension TapSwitchView: TapSwitchViewDelegate {
    func hideMainSwitch() {
        self.mainSwitchControl.hideSwitch = true
    }
    
    func showMainSwitch() {
        self.mainSwitchControl.hideSwitch = false
    }
    
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
        
        self.mainSwitchControl.layer.cornerRadius = CGFloat(0)
        self.mainSwitchControl.clipsToBounds = false
        self.mainSwitchControl.isOn = false
    }
    
    func addSubSwitches() {
        self.showCurvedSeparatorView()
        self.showMerchantSwitch()
        self.showGoPaySwitch()
    }
    
    func reloadUI() {
        self.configureMainSwitch()
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
    @objc public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        
        
        // main
        self.mainSwitchControl?.titleFont = TapThemeManager.fontValue(for: "\(themePath).main.title.textFont") ?? .systemFont(ofSize: 12)
        
        self.mainSwitchControl?.subtitleFont = TapThemeManager.fontValue(for: "\(themePath).main.subtitle.textFont") ?? .systemFont(ofSize: 12)
        
        self.mainSwitchControl.titleTextColor = TapThemeManager.colorValue(for: "\(themePath).main.title.textColor") ?? .black
        
        self.mainSwitchControl.subtitleTextColor = TapThemeManager.colorValue(for: "\(themePath).main.subtitle.textColor") ?? .black
        
        self.mainSwitchControl.tap_theme_backgroundColor = .init(keyPath: "\(themePath).main.backgroundColor")
        
        // merchant
        self.merchantSwitchControl?.switchOnColor = TapThemeManager.colorValue(for: "\(themePath).merchant.SwitchOnColor") ?? .blue
        
        self.merchantSwitchControl?.titleFont = TapThemeManager.fontValue(for: "\(themePath).merchant.title.textFont") ?? .systemFont(ofSize: 12)
        
        self.merchantSwitchControl?.subtitleFont = TapThemeManager.fontValue(for: "\(themePath).merchant.subtitle.textFont") ?? .systemFont(ofSize: 12)
        
        
        self.merchantSwitchControl?.titleTextColor = TapThemeManager.colorValue(for: "\(themePath).merchant.title.textColor") ?? .black
        
        self.merchantSwitchControl?.subtitleTextColor = TapThemeManager.colorValue(for: "\(themePath).merchant.subtitle.textColor") ?? .black
        
        self.merchantSwitchControl?.tap_theme_backgroundColor = .init(keyPath: "\(themePath).merchant.backgroundColor")
        
        // goPay
        self.goPaySwitchControl?.switchOnColor = TapThemeManager.colorValue(for: "\(themePath).goPay.SwitchOnColor") ?? .blue
        
        self.goPaySwitchControl?.titleFont = TapThemeManager.fontValue(for: "\(themePath).goPay.title.textFont") ?? .systemFont(ofSize: 12)
        
        self.goPaySwitchControl?.subtitleFont = TapThemeManager.fontValue(for: "\(themePath).goPay.subtitle.textFont") ?? .systemFont(ofSize: 12)
        
        self.goPaySwitchControl?.notesFont = TapThemeManager.fontValue(for: "\(themePath).goPay.notes.textFont") ?? .systemFont(ofSize: 12)
        
        
        self.goPaySwitchControl?.titleTextColor = TapThemeManager.colorValue(for: "\(themePath).goPay.title.textColor") ?? .black
        
        self.goPaySwitchControl?.subtitleTextColor = TapThemeManager.colorValue(for: "\(themePath).goPay.subtitle.textColor") ?? .black
        
        self.goPaySwitchControl?.notesTextColor = TapThemeManager.colorValue(for: "\(themePath).goPay.notes.textColor") ?? .black
        
        self.goPaySwitchControl?.tap_theme_backgroundColor = .init(keyPath: "\(themePath).goPay.backgroundColor")
        
    }
    
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    @objc override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
