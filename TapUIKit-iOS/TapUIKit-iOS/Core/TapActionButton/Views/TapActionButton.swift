//
//  TapActionButton.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/16/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020

/// Represents the Tap Action Button View
@objc public class TapActionButton: UIView {

    /// the main holder view
    @IBOutlet weak var contentView: UIView!
    /// The image used to show the laoder, success and failure animations
    @IBOutlet weak var loaderGif: UIImageView!
    /// The view holder for the uibutton
    @IBOutlet weak var viewHolder: UIView!
    /// The button itself
    @IBOutlet weak var payButton: UIButton!
    /// The width of the view holder to perform the expansion/collapsing animations when needed
    @IBOutlet weak var viewHolderWidth: NSLayoutConstraint!
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// The theme path to theme the TapGoPay cell in the login options bar
    private let themePath:String = "actionButton"
    /// The view model that controlls this view
    internal var viewModel:TapActionButtonViewModel? {
        didSet {
            reload()
        }
    }
    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setInitialWidth()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setInitialWidth()
    }
    
    /**
     Connects this tap action button view to the requied view model
     - Parameter viewModel: The tap action button view model that will handle all the UI and actions for this button view
     */
    @objc public func setup(with viewModel:TapActionButtonViewModel) {
        self.viewModel = viewModel
        self.viewModel?.viewDelegate = self
        
    }
    
    
    // MARK:- Private methods
    /// Adjusts the button to have the initil width relative to the superview width
    private func setInitialWidth() {
        // We need to wait a little bit until the view is renderd to calculate the correct needed width
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
            self?.viewHolderWidth.constant = (self?.contentView.frame.width ?? 0) - 32
            self?.viewHolder.updateConstraints()
            self?.layoutIfNeeded()
        }
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        reload()
    }
    
    /// Fetch the displayed title from the view model
    private func fetchData() {
        payButton.setTitle(viewModel?.buttonStatus.buttonTitle(), for: .normal)
    }
    
    /// Apply the needed logic to reload UI and localisations upon an order from the view model
    internal func reload() {
        applyTheme()
        fetchData()
    }
    
    /// Handles the logic from ui perspective when the button is clicked
    @IBAction func tapActionButtonClicked(_ sender: Any) {
        // inform the view model the button is clicked.. please do the needful
        viewModel?.didClickButton()
    }
    
}


extension TapActionButton:TapActionButtonViewDelegate {
    func startLoading(completion: () -> ()?) {
        
    }
    
    func endLoading(with success: Bool, completion: () -> ()?) {
        
    }
}



// Mark:- Theme methods
extension TapActionButton {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        let status:TapActionButtonStatusEnum = viewModel?.buttonStatus ?? .InvalidPayment
        
        contentView.backgroundColor = status.buttonViewBackGroundColor()
        viewHolder.backgroundColor = status.buttonBackGroundColor()
        
        payButton.tap_theme_setTitleColor(selector: ThemeUIColorSelector.init(stringLiteral: "\(themePath).Common.titleLabelColor"), forState: .normal)
        payButton.titleLabel?.tap_theme_font = .init(stringLiteral: "\(themePath).Common.titleLabelFont")
        
        viewHolder.layer.cornerRadius = 20
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


