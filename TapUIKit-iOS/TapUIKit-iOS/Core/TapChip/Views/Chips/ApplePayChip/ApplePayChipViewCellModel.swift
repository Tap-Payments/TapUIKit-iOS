//
//  ApplePayChipViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/18/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//
import class UIKit.UICollectionViewCell
import class PassKit.PKPaymentSummaryItem
import enum TapApplePayKit_iOS.TapApplePayButtonType
import class TapApplePayKit_iOS.TapApplePayToken
import enum TapApplePayKit_iOS.TapApplePayButtonStyleOutline
import enum TapApplePayKit_iOS.TapApplePayPaymentNetwork
import class TapApplePayKit_iOS.TapApplePayRequest
import class TapApplePayKit_iOS.TapApplePay
import enum CommonDataModelsKit_iOS.TapCountryCode
import enum CommonDataModelsKit_iOS.TapCurrencyCode




/// The view model that controlls the SavedCard cell
@objc public class ApplePayChipViewCellModel: GenericTapChipViewModel {
    
    // MARK:- Variables
    
    /// The delegate that the associated cell needs to subscribe to know the events and actions it should do
    internal var cellDelegate:GenericCellChipViewModelDelegate?
    internal var applePayButtonType:TapApplePayButtonType = .PayWithApplePay
    internal var applePayButtonStyle:TapApplePayButtonStyleOutline = .Black
    internal var tapApplePayRequest:TapApplePayRequest = .init()
    let tapApplePay:TapApplePay = .init()
    
    // MARK:- Public methods
    public override func identefier() -> String {
        return "ApplePayChipCollectionViewCell"
    }
    
    @objc public init(title: String? = nil, icon: String? = nil, tapApplePayRequest:TapApplePayRequest = .init()) {
        super.init(title: title, icon: icon)
        self.tapApplePayRequest = tapApplePayRequest
    }
    
    @objc public func configureApplePayRequest(with countryCode:TapCountryCode = .KW , currencyCode:TapCurrencyCode = .KWD, paymentNetworks:[TapApplePayPaymentNetwork.RawValue] = [TapApplePayPaymentNetwork.Amex.rawValue,TapApplePayPaymentNetwork.MasterCard.rawValue,TapApplePayPaymentNetwork.Visa.rawValue], applePayButtonType:TapApplePayButtonType = .AppleLogoOnly, applePayButtonStyle:TapApplePayButtonStyleOutline = .Black, paymentItems:[PKPaymentSummaryItem] = [], amount:Double = 10, merchantID:String = "merchant.tap.gosell" ) {
        
        tapApplePayRequest.build(with: countryCode, paymentNetworks: paymentNetworks.map{ TapApplePayPaymentNetwork.init(rawValue: $0)! }, paymentItems: paymentItems, paymentAmount: amount, currencyCode: currencyCode, merchantID: merchantID)
        
        self.applePayButtonType = applePayButtonType
        self.applePayButtonStyle = applePayButtonStyle
        
    }
    
    
    public override func didSelectItem() {
        cellDelegate?.changeSelection(with: true)
        startPayment()
    }
    
    
    internal func startPayment() {
        tapApplePay.authorizePayment(in: .init(), for: tapApplePayRequest) { [weak self] (token) in
            guard let nonNullSelf = self else { return }
            nonNullSelf.viewModelDelegate?.applePayAuthoized(for: nonNullSelf, with: token)
        }
    }
    
    public override func didDeselectItem() {
        cellDelegate?.changeSelection(with: false)
    }
    
    public override func changedEditMode(to: Bool) {
        // When the view model get notified about the new editing mode status
        cellDelegate?.changedEditMode(to: to)
    }
    
    // MARK:- Internal methods
    internal override  func correctCellType(for cell:GenericTapChip) -> GenericTapChip {
        return cell as! ApplePayChipCollectionViewCell
    }
    
    internal func applePayRequest() -> TapApplePayRequest {
        return tapApplePayRequest
    }
}
