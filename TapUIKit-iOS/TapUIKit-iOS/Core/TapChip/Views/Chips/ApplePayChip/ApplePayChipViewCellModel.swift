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
    /// Rerpesents the style of the apple pay button
    internal var applePayButtonType:TapApplePayButtonType = .PayWithApplePay {
        didSet{
            onApplePayButtonUIChanged?()
        }
    }
    /// Rerpesents the style of the apple pay button
    internal var applePayButtonStyle:TapApplePayButtonStyleOutline = .Black {
        didSet{
            onApplePayButtonUIChanged?()
        }
    }
    /// Rerpesents the style of the apple pay request itself
    internal var tapApplePayRequest:TapApplePayRequest = .init()
    let tapApplePay:TapApplePay = .init()
    /// a callback to do whenver we need to update the look & feel of the apple pay button
    internal var onApplePayButtonUIChanged:(()->())? = nil
    
    // MARK:- Public methods
    public override func identefier() -> String {
        return "ApplePayChipCollectionViewCell"
    }
    
    /**
     Creates a new apple pay chip
     - Parameter title: The title to be stated on the apple pay button
     - Parameter icon: The icon to be used inside the apple pay button
     - Parameter tapApplePayRequest: The Tap Apple pay request to pass to the PassKit apple pay library
     */
    @objc public init(title: String? = nil, icon: String? = nil, tapApplePayRequest:TapApplePayRequest = .init(), paymentOptionIdentifier:String = "") {
        super.init(title: title, icon: icon, paymentOptionIdentifier: paymentOptionIdentifier)
        self.tapApplePayRequest = tapApplePayRequest
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    /**
     Configure the apple pay request attached to the apple pay chip, wil be used to pass it to the PassKit when clicked
     - Parameter currencyCode: The currency the transaction will be using
     - Parameter paymentNetworks: The list of allowed networks can be used bby the user to perform the transaction
     - Parameter applePayButtonType: The type of the pay button (Chekout, pay, book, etc)
     - Parameter applePayBuapplePayButtonStylettonType: The style of the pay button
     - Parameter paymentItems: The PassKit items to be passed to the Apple Pay controller
     - Parameter amount: The total amoint to be passed to the Apple Pay controller
     - Parameter merchantID: The Apple pay merchant id to be used inside the apple pay kit
     - Parameter recurringPaymentRequest: Defines the recurring payment request Please check [Apple Pay docs](https://developer.apple.com/documentation/passkit/pkrecurringpaymentrequest). NOTE: This will only be availble for iOS 16+ and subscripion parameter is on.
     */
    @objc public func configureApplePayRequest(currencyCode:TapCurrencyCode = .KWD, paymentNetworks:[TapApplePayPaymentNetwork.RawValue] = [TapApplePayPaymentNetwork.Amex.rawValue,TapApplePayPaymentNetwork.MasterCard.rawValue,TapApplePayPaymentNetwork.Visa.rawValue], applePayButtonType:TapApplePayButtonType = .AppleLogoOnly, applePayButtonStyle:TapApplePayButtonStyleOutline = .Black, paymentItems:[PKPaymentSummaryItem] = [], amount:Double = 10, merchantID:String = "merchant.tap.gosell", recurringPaymentRequest:Any? = nil) {
        
        tapApplePayRequest.build(paymentNetworks: paymentNetworks.map{ TapApplePayPaymentNetwork.init(rawValue: $0)! }, paymentItems: paymentItems, paymentAmount: amount, currencyCode: currencyCode, merchantID: merchantID, recurringPaymentRequest: recurringPaymentRequest)
        
        self.applePayButtonType = applePayButtonType
        self.applePayButtonStyle = applePayButtonStyle
        
    }
    
    
    public override func didSelectItem() {
        cellDelegate?.changeSelection(with: true)
        startPayment()
    }
    
    /// Start the Apple pay payment by passing the request to the PassKit system of the iOS
    internal func startPayment() {
        tapApplePay.authorizePayment(in: .init(), for: tapApplePayRequest) { [weak self] (token) in
            guard let nonNullSelf = self else { return }
            nonNullSelf.viewModelDelegate?.applePayAuthoized(for: nonNullSelf, with: token)
        } onErrorOccured: { _ in }
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
    
    /**
     - Returns: The apple pay request currently holded inside the chip
     */
    internal func applePayRequest() -> TapApplePayRequest {
        return tapApplePayRequest
    }
}
