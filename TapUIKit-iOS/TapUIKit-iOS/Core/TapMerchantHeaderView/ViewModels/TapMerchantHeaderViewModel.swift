//
//  TapMerchantHeaderViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import class LocalisationManagerKit_iOS.TapLocalisationManager
import class CommonDataModelsKit_iOS.TapCommonConstants
import SnapKit

/// The protocl that informs the subscriber of any events happened/fired from the HeaderView
@objc public protocol TapMerchantHeaderViewDelegate {
    /// The icon in the view is clicked by the user
    @objc optional func iconClicked()
    /// The section view in the view is clixked by the user
    @objc optional func merchantHeaderClicked()
    /// Will be fired once the close button is clicked
    @objc func closeButtonClicked()
}

/// The view model that controlls the data shown inside a TapMerchantHeaderView
@objc public class TapMerchantHeaderViewModel:NSObject {
    
    //MARK: - Internal CallBacks Observables
    /// The text to be displayed in the title label
    internal var titleObservable:((String?)->()) = { _ in } {
        didSet{
            titleObservable(title)
        }
    }
    /// The text to be displayed in the subtitle label
    internal var subTitleObservable:((String?)->()) = { _ in } {
        didSet{
            subTitleObservable(subTitle)
        }
    }
    
    /// The url to load the merchant's logo from
    internal var iconObservable:((String?)->()) = { _ in } {
        didSet{
            iconObservable(iconURL)
        }
    }
    
    /// Reference to the merchant header view itself as UI that will be rendered
    internal var merchantHeaderView:TapMerchantHeaderView?
    
    
    //MARK: - Public normal swift variables
    /// Defines the type of the separator at the bottom of the merchant header. Default is gapped
    @objc public var merchantViewBottomSeparatorType:MerchantHeaderSeparatorType = .Gapped {
        didSet{
            attachedView.separatorView.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(merchantViewBottomSeparatorType == .Gapped ? 19 : 0)
                make.trailing.equalToSuperview().offset(merchantViewBottomSeparatorType == .Gapped ? 19 : 0)
            }
            DispatchQueue.main.async {
                self.attachedView.separatorView.layoutIfNeeded()
            }
        }
    }
    
    /// Public reference to the merchant header view itself as UI that will be rendered
    @objc public var attachedView:TapMerchantHeaderView {
        return merchantHeaderView ?? .init()
    }
    
    /// The text to be displayed in the title label
    @objc public var title:String? {
        willSet{
            titleObservable(newValue)
        }
    }
    /// The text to be displayed in the subtitle label
    @objc public var subTitle:String? {
        willSet{
            subTitleObservable(newValue)
        }
    }
    /// The url to load the merchant's logo from
    @objc public var iconURL:String? {
        willSet{
            iconObservable(newValue)
        }
    }
    
    /// The text to be displayed in initials placeholder for merchant logo
    @objc public var merchantPlaceHolder:String  {
        get{
            getMerchantPlaceHolder()
        }
    }
    
    
    /// The delegate that listens to the callbacks from the merchant header
    @objc public var delegate:TapMerchantHeaderViewDelegate?
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
            self.merchantHeaderView = .init()
            self.merchantHeaderView?.changeViewModel(with: self)
        }
        
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
    
    
    //MARK: - Internal methods to let the view talks with the delegate
    
    /// Localisation kit keypath
    internal var localizationPath = "TapMerchantSection"
    /// Configure the localisation Manager
    internal let sharedLocalisationManager = TapLocalisationManager.shared
    
    /// A block to execute logic in view model when the icon in the view is clicked by the user
    internal func iconClicked() {
        delegate?.iconClicked?()
    }
    /// A block to execute logic in view model when the section view in the view is clixked by the user
    internal func merchantHeaderClicked() {
        delegate?.merchantHeaderClicked?()
    }
    
    /// Will be called when the close button is clicked
    internal func cancelButtonClicked() {
        delegate?.closeButtonClicked()
    }
    
}

/// Defines the type of the separator at the bottom of the merchant header
@objc public enum MerchantHeaderSeparatorType:Int {
    /// This means, the separator will have a width edge to edge
    case EdgeToEdge
    /// This means, the separator will have leading & trailing gaps
    case Gapped
}
