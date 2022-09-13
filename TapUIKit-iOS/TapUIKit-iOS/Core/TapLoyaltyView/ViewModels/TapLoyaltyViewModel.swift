//
//  TapLoyaltyViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 13/09/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import Foundation
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS

/// The view model that controlls the data shown inside a TapLoyaltyView
@objc public class TapLoyaltyViewModel: NSObject {
    
    // MARK:- Internal swift variables
    /// Reference to the  loyalty view itself as UI that will be rendered
    internal var tapLoyaltyView:TapLoyaltyView?
    /// Localisation kit keypath
    internal var localizationPath = "TapLoyaltyView"
    /// Configure the localisation Manager
    internal let sharedLocalisationManager = TapLocalisationManager.shared
    
    
    // MARK:- Public normal swift variables
    /// Public reference to the loyalty view itself as UI that will be rendered
    @objc public var attachedView:TapLoyaltyView {
        return tapLoyaltyView ?? .init()
    }
    
    /**
     Init method with the needed data
     - Parameter title: The text to be displayed in the title label
     - Parameter subTitle: The text to be displayed in the subtitle label, default is Merchant name
     - Parameter iconURL: The url to load the merchant's logo from, defailt is merchant icon url
     */
    @objc public init(schemeName:String? = nil ,pointsName:String? = nil, iconURL:String? = nil, currency:TapCurrencyCode? = nil, amount:Double = 0, ) {
        super.init()
        defer {
            self.title = title ?? sharedLocalisationManager.localisedValue(for: "\(localizationPath).paymentFor", with: TapCommonConstants.pathForDefaultLocalisation())
            self.subTitle = subTitle
            self.iconURL = iconURL
            self.merchantHeaderView = .init()
            self.merchantHeaderView?.changeViewModel(with: self)
        }
        
    }
    
    
}
