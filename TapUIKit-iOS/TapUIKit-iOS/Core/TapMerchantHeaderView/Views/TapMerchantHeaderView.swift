//
//  TapMerchantHeaderView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import struct UIKit.CGFloat
import Nuke
// import SimpleAnimation
import TapThemeManager2020
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS

/// A view represents the merchant header section in the checkout UI
@objc public class TapMerchantHeaderView: UIView {

    /// The current close button display state
    private var closeButtonState:CheckoutCloseButtonEnum = .icon
    /// The container view that holds everything from the XIB
    @IBOutlet var containerView: UIView!
    /// The containter view for the area of merchant place holder and real icon image
    @IBOutlet weak var merchantLogoContainerView: UIView!
    /// The placeholder view we show until we load the logo image
    @IBOutlet weak var merchantLogoPlaceHolderView: UIView!
    /// The initials labels we show as a placeholder until we load the logo image
    @IBOutlet weak var merchantLogoPlaceHolderInitialLabel: UILabel!
    /// The imageview that rendersthe merchant logo
    @IBOutlet weak var merchantLogoImageView: UIImageView!
    /// The upper label
    @IBOutlet weak var titleLabel: UILabel!
    /// The lower label
    @IBOutlet weak var subtitleLabel: UILabel!
    /// Used to push the merchant name a bit in Arabic language
    @IBOutlet weak var topSpaceBetweenMerchantNameAndTitleConstraint: NSLayoutConstraint!
    
    @objc public var viewModel:TapMerchantHeaderViewModel? {
        didSet{
            createObservables()
        }
    }
    
    /// The button that will dismiss the whole TAP sheet
    @IBOutlet weak var cancelButton: UIButton!
    
    /// The path to look for theme entry in
    private let themePath = "merchantHeaderView"
    
    // Mark:- Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    private func createObservables() {
        bindLabels()
        bindImages()
    }
    
    ///Updates all the labels with the corresponding values in the view model
    private func bindLabels() {
        guard let viewModel = viewModel else { return }
        
        // Bind the title label to the title observable
        viewModel.titleObservable = { newTitle in
            self.titleLabel.text = newTitle
        }
        
        // Bind the subtitle label and merchant initial label to the subtitle observable
        
        viewModel.subTitleObservable = { subTitle in
            self.subtitleLabel.text = subTitle
            self.merchantLogoPlaceHolderInitialLabel.text = self.viewModel?.merchantPlaceHolder
        }
    }
    
    /// Will be called when the close button is clicked
    @IBAction func cancelButtonClicked(_ sender: Any) {
        viewModel?.cancelButtonClicked()
    }
    
    ///Updates all the labels with the corresponding values in the view model
    private func bindImages() {
        guard let viewModel = viewModel else { return }
        // Bind the icon image to the iconURL observable
        viewModel.iconObservable = { iconURL in
            guard let iconURL = iconURL else { return }
            self.loadMerchantLogo(with: iconURL)
        }
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.containerView = setupXIB()
        translatesAutoresizingMaskIntoConstraints = false
        //handlerImageView.translatesAutoresizingMaskIntoConstraints = false
        applyTheme()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
    
    @objc public func changeViewModel(with viewModel:TapMerchantHeaderViewModel) {
        self.viewModel = viewModel
    }
    
    /**
     Will change the display mode of the close button
     - Parameter to closeButtonState: The new state the button should change to
     */
    @objc public func changeCloseButton(to closeButtonState:CheckoutCloseButtonEnum) {
        if closeButtonState == .title {
            cancelButton.setTitle(TapLocalisationManager.shared.localisedValue(for: "Common.close", with: TapCommonConstants.pathForDefaultLocalisation()).uppercased(), for: .normal)
            cancelButton.setImage(nil, for: .normal)
        }else{
            cancelButton.setTitle("", for: .normal)
            cancelButton.setImage(TapThemeManager.imageValue(for: "merchantHeaderView.closeCheckoutIcon"), for: .normal)
        }
        self.closeButtonState = closeButtonState
    }
    
    /**
     Loads the merchant icon from a url and shows a place holder as per the design with view and intials label
     - Parameter remoteIconUrl: The url to load the logo from
     - Parameter labelInitial: The initial label to show in the palceholder
     */
    private func loadMerchantLogo(with remoteIconUrl:String) {
        // First we show the placeholder and hide the imageview until we load it from the internet
        merchantLogoPlaceHolderView.fadeIn()
        merchantLogoImageView.fadeOut()
        
        // Make sure we have a valid URL
        guard let iconURL:URL = URL(string: remoteIconUrl) else { return }
        
        // load the image from the URL
        //let options = ImageLoadingOptions(
        //  transition: .fadeIn(duration: 0.25)
        //)
        Nuke.loadImage(with: iconURL, into: merchantLogoImageView, completion:  { [weak self] _ in
            self?.merchantLogoImageView.fadeIn()
            self?.merchantLogoPlaceHolderView.fadeOut()
        })
    }
    
    /// Inform the viewmodel that the user clicked view
    @IBAction private func headerViewClicked(_ sender: Any) {
        viewModel?.merchantHeaderClicked()
    }
    
    /// Inform the viewmodel that the user clicked the icon view
    @IBAction func iconClicked(_ sender: Any) {
        viewModel?.iconClicked()
    }
}



// Mark:- Theme methods
extension TapMerchantHeaderView {
    /// Consolidated one point to apply all needed theme methods
    public func applyTheme() {
        matchThemeAttributes()
    }
    
    /// Match the UI attributes with the correct theming entries
    private func matchThemeAttributes() {
        
        changeCloseButton(to: closeButtonState)
        
        titleLabel.tap_theme_font = .init(stringLiteral: "\(themePath).titleLabelFont")
        titleLabel.tap_theme_textColor = .init(keyPath: "\(themePath).titleLabelColor")
        
        subtitleLabel.tap_theme_font = .init(stringLiteral: "\(themePath).subTitleLabelFont")
        subtitleLabel.tap_theme_textColor = .init(keyPath: "\(themePath).subTitleLabelColor")
        
        merchantLogoContainerView.layer.cornerRadius = merchantLogoContainerView.frame.width / 2
        merchantLogoPlaceHolderView.layer.shadowOpacity = 1
        merchantLogoContainerView.layer.tap_theme_shadowRadius = .init(keyPath: "\(themePath).merchantLogoShadowRadius")
        merchantLogoPlaceHolderView.layer.tap_theme_shadowColor = .init(keyPath: "\(themePath).merchantLogoShadowColor")
        merchantLogoPlaceHolderView.tap_theme_backgroundColor = .init(keyPath: "\(themePath).merchantLogoPlaceHolderColor")
        merchantLogoPlaceHolderInitialLabel.tap_theme_font = .init(stringLiteral: "\(themePath).merchantLogoPlaceHolderFont")
        merchantLogoPlaceHolderInitialLabel.tap_theme_textColor = .init(keyPath: "\(themePath).merchantLogoPlaceHolderLabelColor")
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        
        // Push the title and the merchant header a bit if arabic is being used
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topSpaceBetweenMerchantNameAndTitleConstraint.constant += (TapLocalisationManager.shared.localisationLocale == "ar") ? 2 : 0
        
        
        cancelButton.tap_theme_setTitleColor(selector: .init(keyPath: "\(themePath).cancelButton.titleLabelColor"), forState: .normal)
        cancelButton.tap_theme_tintColor = .init(keyPath: "\(themePath).cancelButton.titleLabelColor")
        cancelButton.titleLabel?.tap_theme_font = .init(stringLiteral: "\(themePath).cancelButton.titleLabelFont")
        cancelButton.layer.cornerRadius = 16
        cancelButton.tap_theme_backgroundColor = .init(keyPath: "\(themePath).cancelButton.backgroundColor")
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}


/// Defines the style of the checkout close button
@objc public enum CheckoutCloseButtonEnum:Int {
    /// Will show a close button icon only
    case icon = 1
    /// Will show the word "CLOSE" as a title only
    case title = 2
}
