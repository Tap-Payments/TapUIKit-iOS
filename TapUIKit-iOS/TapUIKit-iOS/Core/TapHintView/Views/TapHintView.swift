//
//  TapHintView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/13/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import LocalisationManagerKit_iOS

/// The view  that renders a tap hint view
@objc public class TapHintView: UIView {

    // MARK:- Outlets
    /// Represents the content view that holds all the subviews
    @IBOutlet var contentView: UIView!
    /// Represents the tab bar that holds the list of segmented availble payment options
    @IBOutlet weak var hintLabel: UILabel!
    /// The delegate that wants to hear from the view on new data and events
    @objc public var viewModel:TapHintViewModel = .init() {
        didSet{
            reloadHintView()
        }
    }
    /// The view that will have the color of the hint
    @IBOutlet weak var actualBackgroundView: UIView!
    @IBOutlet weak var actionButton: UIButton!
    
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /**
     Seup the hint view according to the view model
     - Parameter viewModel: The new required view model to attach the view to
     */
    @objc public func setup(with viewModel:TapHintViewModel) {
        self.viewModel = viewModel
        self.viewModel.viewDelegate = self
    }
    
    // MARK:- Private methods
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        hintLabel.semanticContentAttribute = TapLocalisationManager.shared.localisationLocale == "ar" ? .forceRightToLeft : .forceLeftToRight
        configureWithStatus()
    }
    
    /// Apply the needed logic to reload UI and localisations upon an order from the view model
    private func configureWithStatus() {
        applyTheme()
        localise()
    }
    
    /// localise the hint text based on th enew current status
    private func localise() {
        hintLabel.text = viewModel.localizedTitle()
        actionButton.setTitle(viewModel.tapHintViewStatus.localizedActionButtonTitle(), for: .normal)
    }
    
    @IBAction func actionButtonClicked(_ sender: Any) {
        viewModel.hintViewClicked()
    }
}


extension TapHintView:TapHintViewDelegate {
    func reloadHintView() {
        configureWithStatus()
    }
}

// Mark:- Theme methods
extension TapHintView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        let status:TapHintViewStatusEnum = viewModel.tapHintViewStatus
        
        tap_theme_backgroundColor  = .init(keyPath: "horizontalList.backgroundColor")
        actualBackgroundView.tap_theme_backgroundColor = .init(keyPath: "\(status.themePath()).backgroundColor")
        hintLabel.tap_theme_font = .init(stringLiteral: "\(status.themePath()).textFont")
        hintLabel.tap_theme_textColor = .init(stringLiteral: "\(status.themePath()).textColor")
        actionButton.tap_theme_setTitleColor(selector: .init(keyPath: "\(status.themePath()).actionButtonTextColor"), forState: .normal)
        actionButton.titleLabel?.tap_theme_font = .init(stringLiteral: "\(status.themePath()).actionButtonTextFont")
        actionButton.isHidden = !status.shouldShowActionButton()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        
        guard lastUserInterfaceStyle != self.traitCollection.userInterfaceStyle else {
            return
        }
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        applyTheme()
    }
}

