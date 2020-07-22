//
//  TapGoPayLoginBarView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import LocalisationManagerKit_iOS

/// Represents the view for go pay login options tab bar
@objc public class TapGoPayLoginBarView: UIView {

    // MARK:- Outlets
    /// Represents the content view that holds all the subviews
    @IBOutlet var contentView: UIView!
    /// Represents the under line view
    @IBOutlet weak var underLineBar: UIProgressView!{
        didSet{
            // We need to make it changable regardless of the constraint
            underLineBar.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    /// Represents the leading constraint for the under line view
    @IBOutlet weak var underLineBarLeadingConstraint: NSLayoutConstraint!
    /// Represents the width constraint for the under line view
    @IBOutlet weak var underLineBarWidthConstraint: NSLayoutConstraint!
    /// Represents the view for email login option
    @IBOutlet weak var goPayEmailLogin: TapGoPayTitleView!
    /// Represents the view for phone login option
    @IBOutlet weak var goPayPhoneLogin: TapGoPayTitleView!
    
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// Represents the theme path to theme the GoPay tab bar
    private let themePath:String = "goPay.loginBar"
    /// Represents the validation status for the current selected tab
    internal var validSelection:Bool = false {
        didSet {
            // When changed, we need to re color the underline based on the new validation status
            themeBar()
        }
    }
    
    
    /// The delegate that wants to hear from the view on new data and events
    @objc public var viewModel:TapGoPayLoginBarViewModel?{
        didSet {
            configureViewModel()
        }
    }
    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = bounds
    }
    
    
    // MARK:- Private methods
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        // Create the view models for each login option
        createGoPayLoginOptionsViewModels()
        applyTheme()
    }
    
    /// Create the view models for each login option
    internal func createGoPayLoginOptionsViewModels() {
        // Email login viewModel
        let emailViewModel:TapGoPayTitleViewModel = .init(titleSegment: .Email)
        goPayEmailLogin.setup(with: emailViewModel)
        
        // Phone login viewModel
        let phoneViewModel:TapGoPayTitleViewModel = .init(titleSegment: .Phone)
        goPayPhoneLogin.setup(with: phoneViewModel)
    }
    
    /// Configure the connections between this view and its view model
    internal func configureViewModel() {
        viewModel?.viewDelegate = self
        viewModel?.dataSource = [goPayEmailLogin.viewModel!,goPayPhoneLogin.viewModel!]
    }
    
    
    /**
     Seup the hint view according to the view model
     - Parameter viewModel: The new required view model to attach the view to
     */
    @objc public func setup(with viewModel:TapGoPayLoginBarViewModel) {
        self.viewModel = viewModel
    }

}


// Mark:- Theme methods
extension TapGoPayLoginBarView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        themeBar()
    }
    
    /// Applies the correct theme for the underline view
    private func themeBar() {
        let selectionThemePath:String = validSelection ? "selected" : "unselected"
        underLineBar.tap_theme_progressTintColor = .init(keyPath: "\(themePath).underline.\(selectionThemePath).backgroundColor")
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



extension TapGoPayLoginBarView: TapGoPayLoginBarViewDelegate {
    
    func animateBar(to x: CGFloat, with width: CGFloat) {
        
        let sharedLocalisationManager:TapLocalisationManager = .shared
        
        // Mov ethe bar to the required position
        underLineBar.layoutIfNeeded()
        underLineBar.updateConstraints()
        underLineBarLeadingConstraint.constant = (sharedLocalisationManager.localisationLocale == "ar") ? (frame.width - x - width) : x
        underLineBarWidthConstraint.constant = width
        
        UIView.animate(withDuration: 0.3, animations: {
            self.underLineBar.alpha = 1
            self.underLineBar.layoutIfNeeded()
            self.underLineBar.updateConstraints()
            self.layoutIfNeeded()
        }, completion: {_ in
            print(self.underLineBar.frame)
        })
    }
    
    func changeValidity(to validationState: Bool) {
        validSelection = validationState
    }
}

