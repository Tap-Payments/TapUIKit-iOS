//
//  TapGoPayTitleView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/14/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020

/// Represent the title cell inside the horizontal bar of go pay login options
@objc public class TapGoPayTitleView: UIView {

    // MARK:- Outlets
    /// Represents the content view that holds all the subviews
    @IBOutlet var contentView: UIView!
    /// Represents the title to be displayed in this tab
    @IBOutlet weak var titleLabel: UILabel!
    /// The delegate that wants to hear from the view on new data and events
    @objc public var viewModel:TapGoPayTitleViewModel? {
        didSet{
            reload()
        }
    }
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// The theme path to theme the TapGoPay cell in the login options bar
    private let themePath:String = "goPay.loginBar"
    
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
    @objc public func setup(with viewModel:TapGoPayTitleViewModel) {
        self.viewModel = viewModel
        self.viewModel?.viewDelegate = self
    }
    
    // MARK:- Private methods
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        configureWithStatus()
    }
    
    /// Apply the needed logic to reload UI and localisations upon an order from the view model
    private func configureWithStatus() {
        applyTheme()
        fetchData()
    }
    
    /// Fetch the displayed title from the view model
    private func fetchData() {
        titleLabel.text = viewModel?.titleSegment.localisedTitle() ?? ""
    }
    
    /// Instruct the view model the user did select this title
    @IBAction func titleClicked(_ sender: Any) {
        viewModel?.titleIsSelected()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = bounds
    }
    
}


extension TapGoPayTitleView:TapGoPayTitleViewDelegate {
    func viewFrame() -> CGRect {
        return self.frame
    }
    
    func reload() {
        configureWithStatus()
    }
}

// Mark:- Theme methods
extension TapGoPayTitleView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        let status:TapCardPhoneIconStatus = viewModel?.titleStatus ?? .selected
        
        backgroundColor = .clear
        titleLabel.tap_theme_font = .init(stringLiteral: "\(themePath).title.\(status.themePath()).textFont")
        titleLabel.tap_theme_textColor = .init(stringLiteral: "\(themePath).title.\(status.themePath()).textColor")
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

