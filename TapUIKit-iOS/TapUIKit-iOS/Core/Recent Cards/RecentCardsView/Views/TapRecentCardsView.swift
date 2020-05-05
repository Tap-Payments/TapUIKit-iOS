//
//  TapRecentCardsView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 03/05/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//


import SnapKit
import TapThemeManager2020
import MOLH
import class CommonDataModelsKit_iOS.TapCommonConstants
import LocalisationManagerKit_iOS

/// Represents the Tap view that fully shows the recent cards view as per the design
@objc public class TapRecentCardsView: MOLHView {

    /// This is the button to represent the left button in the UI
    internal lazy var leftButton:UIButton = UIButton()
    /// This is the button to represent the right button in the UI
    internal lazy var rightButton:UIButton = UIButton()
    /// This is the view that will hold the buttons above the collection view
    internal lazy var headerView:UIView = UIView()
    /// This is the recent cards collection view
    internal lazy var recentCardsCollectionView:TapRecentCollectionView = TapRecentCollectionView()
    /// The view model that has the data to be shown inside the view and responsible for firing events
    internal var viewModel:TapCardsCollectionViewModel = .init() {
        didSet {
            setupViews()
        }
    }
    /// This defines in which path should we look into the theme based on the card input mode
    internal var themePath:String = "recentCards"
    /// Configure the localisation Manager
    internal let sharedLocalisationManager = TapLocalisationManager.shared
    
    /**
    Setup the view by passing in the viewModel
    - Parameter viewModel: The view model that has the needed info to be shown and rendered inside the view
    */
    @objc public func setup(with viewModel:TapCardsCollectionViewModel) {
        self.viewModel = viewModel
    }
    
   /// The method that is used to apply the logic of adding, arranging and setting up the constraints of the subviews
    internal func setupViews() {
        // Apply the theme and the theme attributes
        applyTheme()
        // We add the views now to our main container
        addViews()
        // We add the constraints needed to correctly layout the views
        addConstrains()
        recentCardsCollectionView.setup(with: viewModel)
        
        localize()
    }
    
    
    /// Method used to add and configure the subviews
    internal func addViews() {
        
        leftButton.setTitle("Recent", for: .normal)
        rightButton.setTitle("Edit", for: .normal)
        rightButton.addTarget(self, action: #selector(recentButtonClicked), for:.touchUpInside)
        headerView.addSubview(leftButton)
        headerView.addSubview(rightButton)
        
        self.addSubview(headerView)
        self.addSubview(recentCardsCollectionView)

        
    }
    
    
    /// Method used to setup the needed constraints that will aid to correctly render the sub views
    internal func addConstrains() {
        
        headerView.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(50)
        }
        
        leftButton.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(28)
            make.height.equalTo(30)
        }
        
        rightButton.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-28)
            make.height.equalTo(30)
        }
        
        recentCardsCollectionView.snp.remakeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-28)
            make.leading.equalToSuperview().offset(28)
        }
    }
    
    @objc public func localize(shouldFlip:Bool = false) {
        // The default localisation file location
        let defaultLocalisationFilePath:URL = TapCommonConstants.pathForDefaultLocalisation()
        // Assign the localisation values
        leftButton.setTitle(sharedLocalisationManager.localisedValue(for: "Common.recent", with: defaultLocalisationFilePath), for: .normal)
        rightButton.setTitle(sharedLocalisationManager.localisedValue(for: "Common.edit", with: defaultLocalisationFilePath), for: .normal)
        
        if shouldFlip {
            MOLH.setLanguageTo(sharedLocalisationManager.localisationLocale ?? "en")
        }
    }
    
    @objc internal func recentButtonClicked() {
        viewModel.handleEditCardClick()
    }
}

extension TapRecentCardsView {
    
     /// This method is responsible for applying the correct theme and setting and matching the theme attributes
       @objc public func applyTheme() {
           matchThemeAttribtes()
           
       }
    
    /// This method matches the correct ui elements to its theme path inside the theme object
    internal func matchThemeAttribtes() {
       // background color
        self.tap_theme_backgroundColor = ThemeUIColorSelector.init(keyPath: "\(themePath).backGroundColor")
        
        // The buttons background color
        leftButton.tap_theme_backgroundColor = ThemeUIColorSelector.init(keyPath: "\(themePath).headerView.buttons.backGroundColor")
        rightButton.tap_theme_backgroundColor = ThemeUIColorSelector.init(keyPath: "\(themePath).headerView.buttons.backGroundColor")
        
        // The buttons text color
        leftButton.tap_theme_setTitleColor(selector: ThemeUIColorSelector.init(keyPath: "\(themePath).headerView.buttons.textColor"), forState: .normal)
        rightButton.tap_theme_setTitleColor(selector: ThemeUIColorSelector.init(keyPath: "\(themePath).headerView.buttons.textColor"), forState: .normal)
        
        // The buttons fonts
        leftButton.titleLabel?.tap_theme_font = ThemeFontSelector.init(stringLiteral: "\(themePath).headerView.buttons.font")
        rightButton.titleLabel?.tap_theme_font = ThemeFontSelector.init(stringLiteral: "\(themePath).headerView.buttons.font")
        
        // Header view bg color
        headerView.tap_theme_backgroundColor = ThemeUIColorSelector.init(keyPath: "\(themePath).headerView.backGroundColor")
    }
}
