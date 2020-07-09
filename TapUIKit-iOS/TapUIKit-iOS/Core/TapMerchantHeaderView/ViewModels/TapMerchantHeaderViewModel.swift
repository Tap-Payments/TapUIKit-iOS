//
//  TapMerchantHeaderViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class LocalisationManagerKit_iOS.TapLocalisationManager
import class CommonDataModelsKit_iOS.TapCommonConstants
import RxCocoa

/// The protocl that informs the subscriber of any events happened/fired from the HeaderView
@objc public protocol TapMerchantHeaderViewDelegate {
    /// The icon in the view is clicked by the user
    @objc optional func iconClicked()
    /// The section view in the view is clixked by the user
    @objc optional func merchantHeaderClicked()
}

/// The view model that controlls the data shown inside a TapMerchantHeaderView
@objc public class TapMerchantHeaderViewModel:NSObject {
    
    // MARK:- RX Internal Observables
    /// The text to be displayed in the title label
    internal var titleObservable:BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    /// The text to be displayed in the subtitle label
    internal var subTitleObservable:BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    /// The url to load the merchant's logo from
    internal var iconObservable:BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    
    // MARK:- Public normal swift variables
    /// The text to be displayed in the title label
    @objc public var title:String? {
        willSet{
            titleObservable.accept(newValue ?? "")
        }
    }
    /// The text to be displayed in the subtitle label
    @objc public var subTitle:String? {
        willSet{
            subTitleObservable.accept(newValue ?? "")
        }
    }
    /// The url to load the merchant's logo from
    @objc public var iconURL:String? {
        willSet{
            iconObservable.accept(newValue ?? "")
        }
    }
    
    /// The text to be displayed in initials placeholder for merchant logo
    @objc public var merchantPlaceHolder:String  {
        get{
            getMerchantPlaceHolder()
        }
    }
    
    
    @objc public var delegate:TapMerchantHeaderViewDelegate?
    
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
    @objc public init(title:String? = nil ,subTitle:String? = nil, iconURL:String? = nil) {
        super.init()
        defer {
            self.title = title ?? sharedLocalisationManager.localisedValue(for: "\(localizationPath).paymentFor", with: TapCommonConstants.pathForDefaultLocalisation())
            self.subTitle = subTitle
            self.iconURL = iconURL
        }
        
    }
    
    
    // MARK:- Internal methods to let the view talks with the delegate
    /// A block to execute logic in view model when the icon in the view is clicked by the user
    internal func iconClicked() {
        delegate?.iconClicked?()
    }
    /// A block to execute logic in view model when the section view in the view is clixked by the user
    internal func merchantHeaderClicked() {
        delegate?.merchantHeaderClicked?()
    }
    
    /**
     The text to be displayed in initials placeholder for merchant logo
     - Returns: Whether a predefined passed value from the parent or the default localization for Merchant Name
     */
    @objc public func getMerchantPlaceHolder() -> String {
        // Make sure we have a merchant name of length > 0
        guard let merchantName = subTitle,merchantName.count > 0 else { return "" }        
        return merchantName.prefix(1).uppercased()
    }
    
}
