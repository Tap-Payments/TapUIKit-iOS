//
//  TapMerchantHeaderViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import LocalisationManagerKit_iOS
import class CommonDataModelsKit_iOS.TapCommonConstants
/// The view model that controlls the data shown inside a TapMerchantHeaderView
public struct TapMerchantHeaderViewModel {
    
    /// The text to be displayed in the title label
    public var title:String?
    /// The text to be displayed in the subtitle label
    internal var subTitle:String?
    /// The url to load the merchant's logo from
    internal var iconURL:String?
    
    /// Localisation kit keypath
    internal var localizationPath = "TapMerchantSection"
    /// Configure the localisation Manager
    internal let sharedLocalisationManager = TapLocalisationManager.shared
    /**
     Init method with the needed data
     - Parameter title: The text to be displayed in the title label, default is localized Payment For
     - Parameter subTitle: The text to be displayed in the subtitle label, default is Merchant name
     - Parameter iconURL: The url to load the merchant's logo from, defailt is merchant icon url
     */
    public init(title:String? = nil ,subTitle:String? = nil, iconURL:String? = nil) {
        self.title = title
        self.subTitle = subTitle
        self.iconURL = iconURL
    }
    /**
        The text to be displayed in the title label
     - Returns: Whether a predefined passed value from the parent or the default localization for "PAYMENT FOR"
     */
    public func getTitle() -> String {
        return title ?? sharedLocalisationManager.localisedValue(for: "\(localizationPath).paymentFor", with: TapCommonConstants.pathForDefaultLocalisation())
    }
    
    /**
     The text to be displayed in the subt title label
     - Returns: Whether a predefined passed value from the parent or the default localization for Merchant Name
     */
    public func getSubTitle() -> String {
        return subTitle ?? ""
    }
    
    /**
     The url to load the merchant's logo from
     - Returns: Whether a predefined passed value from the parent or the default stored merchant logo icon
     */
    public func getIconURL() -> String {
        return iconURL ?? ""
    }
    
    /**
     The text to be displayed in initials placeholder for merchant logo
     - Returns: Whether a predefined passed value from the parent or the default localization for Merchant Name
     */
    public func getMerchantPlaceHolder() -> String {
        // Make sure we have a merchant name of length > 0
        let merchantName = getSubTitle()
        guard merchantName.count > 0 else { return "" }
        
        return merchantName.prefix(1).uppercased()
    }
    
}
