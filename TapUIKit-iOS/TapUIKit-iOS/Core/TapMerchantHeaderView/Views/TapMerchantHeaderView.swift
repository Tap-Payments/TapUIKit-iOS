//
//  TapMerchantHeaderView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import struct UIKit.CGFloat
import Nuke
import SimpleAnimation
import RxSwift
import TapThemeManager2020
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS

/// A view represents the merchant header section in the checkout UI
@objc public class TapMerchantHeaderView: UIView {

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
    
    private let disposeBag:DisposeBag = .init()
    
    @objc public var viewModel:TapMerchantHeaderViewModel? {
        didSet{
            createObservables()
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
    
    
    private func createObservables() {
        bindLabels()
        bindImages()
    }
    
    ///Updates all the labels with the corresponding values in the view model
    private func bindLabels() {
        guard let viewModel = viewModel else { return }
        
        // Bind the title label to the title observable
        viewModel.titleObservable
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(titleLabel.rx.text).disposed(by: disposeBag)
        
        // Bind the subtitle label and merchant initial label to the subtitle observable
        viewModel.subTitleObservable.map{ $0.uppercased() }
            .distinctUntilChanged()
            .map{($0,viewModel.merchantPlaceHolder)}
            .subscribe(onNext: { [weak self] (merchantName, merchantPlaceHolder) in
                self?.subtitleLabel.text = merchantName
                self?.merchantLogoPlaceHolderInitialLabel.text = merchantPlaceHolder
            }).disposed(by: disposeBag)
    }
    
    ///Updates all the labels with the corresponding values in the view model
    private func bindImages() {
        guard let viewModel = viewModel else { return }
        // Bind the icon image to the iconURL observable
        viewModel.iconObservable
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] iconURL in
                self?.loadMerchantLogo(with: iconURL)
            }).disposed(by: disposeBag)
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
        Nuke.loadImage(with: iconURL, into: merchantLogoImageView) { [weak self] _ in
            self?.merchantLogoImageView.fadeIn()
            self?.merchantLogoPlaceHolderView.fadeOut()
        }
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
        
        titleLabel.tap_theme_font = .init(stringLiteral: "\(themePath).titleLabelFont")
        titleLabel.tap_theme_textColor = .init(keyPath: "\(themePath).titleLabelColor")
        
        subtitleLabel.tap_theme_font = .init(stringLiteral: "\(themePath).subTitleLabelFont")
        subtitleLabel.tap_theme_textColor = .init(keyPath: "\(themePath).subTitleLabelColor")
        
        merchantLogoContainerView.layer.tap_theme_cornerRadious = .init(keyPath: "\(themePath).merchantLogoCorner")
        merchantLogoPlaceHolderView.tap_theme_backgroundColor = .init(keyPath: "\(themePath).merchantLogoPlaceHolderColor")
        merchantLogoPlaceHolderInitialLabel.tap_theme_font = .init(stringLiteral: "\(themePath).merchantLogoPlaceHolderFont")
        merchantLogoPlaceHolderInitialLabel.tap_theme_textColor = .init(keyPath: "\(themePath).merchantLogoPlaceHolderLabelColor")
        
        tap_theme_backgroundColor = .init(keyPath: "\(themePath).backgroundColor")
        
        // Push the title and the merchant header a bit if arabic is being used
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topSpaceBetweenMerchantNameAndTitleConstraint.constant += (TapLocalisationManager.shared.localisationLocale == "ar") ? 2 : 0
        
        layoutIfNeeded()
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        applyTheme()
    }
}
