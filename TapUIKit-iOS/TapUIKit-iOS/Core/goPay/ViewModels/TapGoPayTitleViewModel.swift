//
//  TapGoPayTitleViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/14/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import struct UIKit.CGRect
import LocalisationManagerKit_iOS
import class CommonDataModelsKit_iOS.TapCommonConstants


/// Protocol to communicate between the parenr viewmodel (The bar list view model) and this view model
internal protocol TapGoPayTitleViewModelDelegate {
    /**
     Inform the bar list view model that there is a title had been selected
     - Parameter viewModel: The TapGoPayTitleViewModel related to the selected title
     */
    func titleIsSelected(with viewModel:TapGoPayTitleViewModel)
}

/// Protocol to communicate between the view controlled by this view model ad the view model itself
internal protocol TapGoPayTitleViewDelegate {
    /**
     Asks the view to calclate its view bounds relative to its superview
     - Returns: A rect represents the boundries of the associated view
     */
    func viewFrame() -> CGRect
    /// Informs the attached view to reload itself to respond to certain changes in the view model
    func reload()
}


/// View model that controls the actions and the ui of the card/phone bar inner icon
@objc public class TapGoPayTitleViewModel:NSObject {
    
    // MARK:- Public normal swift variables
    /// Represent the title state
    @objc public var titleStatus:TapCardPhoneIconStatus = .selected {
        didSet{
            // Update the attached view to reload itself based on the new status
            viewDelegate?.reload()
        }
    }
    
    /// Represent the title of this segment
    internal var titleSegment:GoPyLoginOption = .Email {
        didSet{
            // Update the attached view to set its text
            viewDelegate?.reload()
        }
    }
    
    // MARK:- Private methods
    
    ///Delegate to communicate between the parenr viewmodel (The bar list view model) and this view model
    internal var delegate:TapGoPayTitleViewModelDelegate?
    
    
    
    /// Delegae to communicate between the view controlled by this view model ad the view model itself
    internal var viewDelegate:TapGoPayTitleViewDelegate?
    
    /// The attached view will call this method once it had been clicked by the user
    internal func titleIsSelected() {
        // We need to inform our view model delegate that a selection happened, so it can execute the needed logic
        delegate?.titleIsSelected(with: self)
    }
    
    /**
     Computes the frame of the associated tab view
      - Returns: The rect for the assocuated tab or .ZERO as a fall back
     */
    internal func viewFrame() -> CGRect {
        return viewDelegate?.viewFrame() ?? .zero
    }
    
    
    // MARK:- Public methods
    
    public static func == (lhs: TapGoPayTitleViewModel, rhs: TapGoPayTitleViewModel) -> Bool {
        return lhs.titleSegment == rhs.titleSegment
    }
    
    
    /**
     - Parameter tapCardPhoneIconStatus: Represent the icon state
     - Parameter associatedCardBrand: Represent the associated payment brand this cell is linked to
     - Parameter tapCardPhoneIconUrl: Represent the url for the image to be loaded inside
     this icon
     */
    @objc public init(titleStatus: TapCardPhoneIconStatus = .selected, titleSegment:GoPyLoginOption) {
        super.init()
        defer{
            self.titleStatus = titleStatus
            self.titleSegment = titleSegment
        }
    }
}

/// Represents the ossible cases to login to goPay
@objc public enum GoPyLoginOption: Int {
    /// Login to goPay using email and passwod
    case Email
    /// Login to goPay using phone and OTP
    case Phone
    
    /**
     The localized title to show regarding a certain GoPayLogin option
     - Returns: The localized title of the associated GoPayLogin
     */
    public func localisedTitle() -> String {
        // Used to fetch the localised titles for different options
        let sharedLocalisation:TapLocalisationManager = .shared
        
        switch self {
            
        case .Email:
            return sharedLocalisation.localisedValue(for: "Common.email", with: TapCommonConstants.pathForDefaultLocalisation()).uppercased()
        case .Phone:
            return sharedLocalisation.localisedValue(for: "Common.phone", with: TapCommonConstants.pathForDefaultLocalisation()).uppercased()
        }
    }
    
}
