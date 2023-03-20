//
//  TapAsyncViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 19/01/2023.
//

import Foundation
import CommonDataModelsKit_iOS
import TapThemeManager2020
import LocalisationManagerKit_iOS

/// The view model that controlls the data shown inside a TapAsyncView
@objc public class TapAsyncViewModel:NSObject {
    
    /// Reference to the tap async view itself as UI that will be rendered
    internal var tapAsyncView:TapAsyncView?
    
    // MARK:- Public normal swift variables
    /// Public reference to the tap async view itself as UI that will be rendered
    @objc public var attachedView:TapAsyncView {
        return tapAsyncView ?? .init()
    }
    
    /// Localisation kit keypath
    internal var localizationPath = "TapAsyncSection"
    /// Configure the localisation Manager
    internal let sharedLocalisationManager = TapLocalisationManager.shared
    /// The merchant data
    internal var merchantModel:TapMerchantHeaderViewModel?
    /// The charge data
    internal var chargeModel:Charge?
    /// The charge data
    internal var paymentOption:PaymentOption?
    
    /// Content displayed in the paymentProgressLabel
    internal var paymentProgressLabel:String {
        return TapLocalisationManager.shared.localisedValue(for: "\(localizationPath).paymentProgressLabel",with: TapCommonConstants.pathForDefaultLocalisation())
    }
    
    
    /// Content displayed in the paymentRecieptLabel
    internal var paymentRecieptLabel:String {
        // decide which mean did the charge use for sending the receipt
        var communicationMean:String = ""
        
        // Check if it is email
        if chargeModel?.receiptSettings?.email ?? false,
           let _ = chargeModel?.customer.emailAddress?.value {
            communicationMean = TapLocalisationManager.shared.localisedValue(for: "\(localizationPath).paymentRecieptEmail",with: TapCommonConstants.pathForDefaultLocalisation())
        }else // Check if it is sms
        if chargeModel?.receiptSettings?.sms ?? false,
           let _ = chargeModel?.customer.phoneNumber?.phoneNumber {
            communicationMean = TapLocalisationManager.shared.localisedValue(for: "\(localizationPath).paymentRecieptSms",with: TapCommonConstants.pathForDefaultLocalisation())
        }
        
        return String(format: TapLocalisationManager.shared.localisedValue(for: "\(localizationPath).paymentRecieptLabel",with: TapCommonConstants.pathForDefaultLocalisation()), communicationMean)
    }
    
    /// Content displayed in the paymentContactDetailsLabel
    internal var paymentContactDetailsLabel:String {
        // Check if it is email
        if chargeModel?.receiptSettings?.email ?? false,
           let emailAddres = chargeModel?.customer.emailAddress?.value {
            return emailAddres
        }else // Check if it is sms
        if chargeModel?.receiptSettings?.sms ?? false,
           let phoneNumber = chargeModel?.customer.phoneNumber?.phoneNumber,
           let isdNumber = chargeModel?.customer.phoneNumber?.isdNumber {
            return "\(isdNumber)\(phoneNumber)"
        }
        return ""
    }
    
    /// Content displayed in the paymentReferenceTitleLabel
    internal var paymentReferenceTitleLabel:String {
        return String(format: TapLocalisationManager.shared.localisedValue(for: "\(localizationPath).paymentReferenceTitleLabel",with: TapCommonConstants.pathForDefaultLocalisation()), paymentOption?.title ?? "")
    }
    
    
    /// Content displayed in the paymentCodeTitleLabel
    internal var paymentCodeTitleLabel:String {
        return TapLocalisationManager.shared.localisedValue(for: "\(localizationPath).paymentCodeTitleLabel",with: TapCommonConstants.pathForDefaultLocalisation())
    }
    
    /// Content displayed in the paymentCodeTitleLabel
    internal var paymentCodeLabel:String {
        return chargeModel?.transactionDetails.order?.reference ?? ""
    }
    
    /// Content displayed in the paymentCodeTitleLabel
    internal var paymentExpiryTitleLabel:String {
        return TapLocalisationManager.shared.localisedValue(for: "\(localizationPath).paymentExpiryTitleLabel",with: TapCommonConstants.pathForDefaultLocalisation())
    }
    
    /// Content displayed in the paymentExpiryLabel
    internal var paymentExpiryLabel:String {
        // Add the expiration duration to the current date
        var expirationDate = Date()
        if let expiry = chargeModel?.transactionDetails.expiry,
           let expirationDateType = expiry.toCalendarComponent() {
            let calendar = Calendar.current
            expirationDate = calendar.date(byAdding: expirationDateType, value: expiry.period, to: expirationDate) ?? Date()
        }
        
        // create the date formatter
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY @ hh:mm a"
        return formatter.string(from: expirationDate)
    }
    
    
    /// Content displayed in the paymentVisitBranchesLabel
    internal var paymentVisitBranchesLabel:String {
        return String(format: TapLocalisationManager.shared.localisedValue(for: "\(localizationPath).paymentVisitBranchesLabel",with: TapCommonConstants.pathForDefaultLocalisation()), paymentOption?.title ?? "")
    }
    
    /// Content displayed in the storesURL button
    internal var storesURL:URL? {
        return URL(string: chargeModel?.transactionDetails.order?.storeUrl ?? "")
    }
    
    /// Handles navigating to the store's locations
    internal func visitStoresClicked() {
        if let storesURL = storesURL,
           UIApplication.shared.canOpenURL(storesURL) {
            UIApplication.shared.open(storesURL)
        }
    }
    
    /**
     Init method with the needed data
     - Parameter merchantModel: The merchant data
     - Parameter chargeModel: The charge data
     */
    public init(merchantModel:TapMerchantHeaderViewModel, chargeModel:Charge, paymentOption:PaymentOption) {
        super.init()
        defer {
            self.merchantModel = merchantModel
            self.chargeModel = chargeModel
            self.paymentOption = paymentOption
            self.tapAsyncView = .init()
            self.tapAsyncView?.changeViewModel(with: self)
        }
    }
    
}
