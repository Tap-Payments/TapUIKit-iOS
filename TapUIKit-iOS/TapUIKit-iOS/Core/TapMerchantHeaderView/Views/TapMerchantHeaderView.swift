//
//  TapMerchantHeaderView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import TapThemeManager2020
import struct UIKit.CGFloat
import MapleBacon
import SimpleAnimation
/// A view represents the merchant header section in the checkout UI
public class TapMerchantHeaderView: UIView {

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
    
    public var viewModel:TapMerchantHeaderViewModel? {
        didSet{
            reload()
        }
    }
    
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
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.containerView = setupXIB()
        //handlerImageView.translatesAutoresizingMaskIntoConstraints = false
        applyTheme()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
    
    public func changeViewModel(with viewModel:TapMerchantHeaderViewModel) {
        self.viewModel = viewModel
    }
    
    /// This will change the values of titles and images to match the latest values in the associated view model
    public func reload() {
        // First defensive coding, make sure we have a valid view model to load the data from
        guard let viewModel = viewModel else { return }
        setLabels(viewModel: viewModel)
        setImages(viewModel: viewModel)
    }
    
    /**
     Updates all the labels with the corresponding values in the view model
     - Parameter viewModel: The view model used to fetch the values from
     */
    private func setLabels(viewModel: TapMerchantHeaderViewModel) {
        
        // Handle title and subtitle labels
        titleLabel.text = viewModel.getTitle()
        subtitleLabel.text = viewModel.getSubTitle()
        merchantLogoPlaceHolderInitialLabel.text = viewModel.getMerchantPlaceHolder()
    }
    
    /**
     Updates all the image vuews with the corresponding values in the view model
     - Parameter viewModel: The view model used to fetch the values from
     */
    private func setImages(viewModel: TapMerchantHeaderViewModel) {
        // Merchant logo has a specific logic, as its placeholder is a full view not an image
        loadMerchantLogo(with: viewModel.getIconURL())
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
        merchantLogoImageView.setImage(with: iconURL, displayOptions: []) { downloadedImage in
            // Check the downloaded image is a proper image
            guard let downloadedImage = downloadedImage else { return }
            
            // Set the image and show it
            DispatchQueue.main.async { [weak self] in
                self?.merchantLogoImageView.image = downloadedImage
                self?.merchantLogoPlaceHolderView.fadeOut(completion:{ _ in
                    self?.merchantLogoImageView.fadeIn()
                })
            }
        }
        
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
        
        titleLabel.tap_theme_font = .init(stringLiteral: "\(themePath).titleLabelFont")
        titleLabel.tap_theme_textColor = .init(keyPath: "\(themePath).titleLabelColor")
        
        subtitleLabel.tap_theme_font = .init(stringLiteral: "\(themePath).subTitleLabelFont")
        subtitleLabel.tap_theme_textColor = .init(keyPath: "\(themePath).subTitleLabelColor")
        
        merchantLogoContainerView.layer.tap_theme_cornerRadious = .init(keyPath: "\(themePath).merchantLogoCorner")
        merchantLogoPlaceHolderView.tap_theme_backgroundColor = .init(keyPath: "\(themePath).merchantLogoPlaceHolderColor")
        merchantLogoPlaceHolderInitialLabel.tap_theme_font = .init(stringLiteral: "\(themePath).merchantLogoPlaceHolderFont")
        merchantLogoPlaceHolderInitialLabel.tap_theme_textColor = .init(keyPath: "\(themePath).merchantLogoPlaceHolderLabelColor")
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
