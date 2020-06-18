//
//  ApplePayChipViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/18/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//
import class UIKit.UICollectionViewCell
import enum TapApplePayKit_iOS.TapApplePayButtonType
import enum TapApplePayKit_iOS.TapApplePayButtonStyleOutline
import enum TapApplePayKit_iOS.TapApplePayPaymentNetwork
import class TapApplePayKit_iOS.TapApplePayRequest
import enum CommonDataModelsKit_iOS.TapCountryCode
import enum CommonDataModelsKit_iOS.TapCurrencyCode

/// The view model that controlls the SavedCard cell
public class ApplePayChipViewCellModel: GenericTapChipViewModel {
    
    // MARK:- Variables
    
    /// The delegate that the associated cell needs to subscribe to know the events and actions it should do
    internal var cellDelegate:GenericChipViewModelDelegate?
    internal var applePayButtonStyle:TapApplePayButtonType = .PayWithApplePay
    internal var tapApplePayRequest:TapApplePayRequest = .init()
    
    // MARK:- Public methods
    public override func identefier() -> String {
        return "ApplePayChipCollectionViewCell"
    }
    
    public init(title: String? = nil, icon: String? = nil, tapApplePayRequest:TapApplePayRequest = .init()) {
        super.init(title: title, icon: icon)
        self.tapApplePayRequest = tapApplePayRequest
    }
    
    public func configureApplePayRequest(with countryCode:TapCountryCode = .KW , currencyCode:TapCurrencyCode = .KWD, paymentNetworks:[TapApplePayPaymentNetwork] = [TapApplePayPaymentNetwork.Amex,TapApplePayPaymentNetwork.MasterCard,TapApplePayPaymentNetwork.Visa], applePayButtonType:TapApplePayButtonType = .BuyWithApplePay, applePayButtonStyle:TapApplePayButtonStyleOutline = .Black ) {
        
        
        
    }
    
    
    public override func didSelectItem() {
        cellDelegate?.changeSelection(with: true)
    }
    
    public override func didDeselectItem() {
        cellDelegate?.changeSelection(with: false)
    }
    
    // MARK:- Internal methods
    internal override  func correctCellType(for cell:GenericTapChip) -> GenericTapChip {
        return cell as! ApplePayChipCollectionViewCell
    }
    
    internal func applePayRequest() -> TapApplePayRequest {
        return tapApplePayRequest
    }
}
