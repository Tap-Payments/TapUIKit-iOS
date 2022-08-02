//
//  TapCardPhoneIconView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/28/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import Nuke
// import SimpleAnimation

/// Represent the icon cell inside the horizontal bar of cards and telecom operators
@objc public class TapCardPhoneIconView: UIView {
    
    // MARK:- Outlets
    /// Represents the content view that holds all the subviews
    @IBOutlet var contentView: UIView!
    /// Represents the icon of the card/telecom operator image view
    @IBOutlet weak var iconImageView: UIImageView!
    
    // MARK:- Private variables
    /// Rerpesents the loaded full colored image for the icon, will be used to show colored and grayscale version
    internal var iconImage:UIImage? = nil
    /// Rerpesents the View model that controls the actions and the ui of the card/phone bar inner icon
    internal var viewModel:TapCardPhoneIconViewModel? {
        didSet{
            // Once assigned we declare ourself as the view delegate
            viewModel?.viewDelegate = self
            // We wire up the view model notifications
            bindObservables()
        }
    }
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// The path to look for theme entry in
    private let themePath = "cardPhoneList.icon"
    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    // MARK:- Private methods
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.contentView = setupXIB()
        applyTheme()
    }
    
    /// Used to bind all the needed reactive observables to its matching logic and functions
    private func bindObservables() {
        // Defensive coding to make sure there is a view model
        guard let viewModel = viewModel else { return }
        // Icon url change and Tab status change callbacks
        viewModel.tapCardPhoneIconStatusObserver = { [weak self] iconStatus in
            // once the icon is changed, we need to load the icon
            self?.loadIcon(from: viewModel.tapCardPhoneIconUrl, with: iconStatus)
            // once the status is changed we need to update the theme
            self?.applyTheme()
        }
        
        viewModel.tapCardPhoneIconUrlObserver = { [weak self] iconURL in
            // once the icon is changed, we need to load the icon
            self?.loadIcon(from: iconURL, with: viewModel.tapCardPhoneIconStatus)
            // once the status is changed we need to update the theme
            self?.applyTheme()
        }
    }
    
    /**
     Handles the logic for loading the icon from the URL with animation
     - Parameter url: The url to load the icon from
     - Parameter status: The current status that will affect the final look and feel for the loded icon
     */
    private func loadIcon(from url:String, with status:TapCardPhoneIconStatus) {
        // defensive coding to make sure it is a correct URL
        guard let iconURL = URL(string: url) else { return }
        
        let options = ImageLoadingOptions(
            transition: .fadeIn(duration: 0.2)
        )
        // Time to load the image iconf rom the given URL
        Nuke.loadImage(with: iconURL,options:options, into: iconImageView, completion:  { [weak self] _ in
            // Then based on the status we see, we will use teh icon as is or we will convert to black and white version
            if status == .otherIconIsSelectedVerified {
                // Another icon is specifically chosen, hence we need to show all others as grayscale
                self?.iconImageView.image = self?.iconImageView.image?.toGrayScale()
            }
        })
    }
    
    
    // MARK:- Public methods
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = bounds
    }
    
    /**
     Apply the needed setup and attach the passed view model
     - Parameter viewModel: The TapCardPhoneIconViewModel responsible for controlling this icon view
     */
    @objc public func setupView(with viewModel:TapCardPhoneIconViewModel) {
        self.viewModel = viewModel
    }
    
    /// Fired when the user clicks on the tab
    @IBAction private func iconClicked(_ sender: Any) {
        // Defensive coding to make sure there is a valid view model attached to the current view
        guard let viewModel = viewModel else { return }
        // Inform the viewmodel that this icon is selected
        viewModel.iconIsSelected()
    }
}



// Mark:- Theme methods
extension TapCardPhoneIconView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        let status:TapCardPhoneIconStatus = viewModel?.tapCardPhoneIconStatus ?? .selected
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).\(status.themePath()).backgroundColor")
        iconImageView.tap_theme_alpha = .init(keyPath: "\(themePath).\(status.themePath()).alpha")
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


extension TapCardPhoneIconView:TapCardPhoneIconViewDelegate {
    
    func viewFrame() -> CGRect {
        return  (self.superview?.convert(self.frame, to: nil)) ?? self.frame
    }
    
    
}

