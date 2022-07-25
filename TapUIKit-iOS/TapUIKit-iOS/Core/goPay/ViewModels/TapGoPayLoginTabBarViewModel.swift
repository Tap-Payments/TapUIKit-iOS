//
//  TapGoPayLoginTabBarViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/14/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import SnapKit
import LocalisationManagerKit_iOS
import CommonDataModelsKit_iOS

/// Protocol to communicate between the view controlled by this view model ad the view model itself
internal protocol TapGoPayLoginBarViewDelegate {
    /**
     Asks the view to move the underline regarding the provided coordinates
     - Parameter x: The starting point of the new position
     - Parameter width: The width of the new position
     */
    func animateBar(to x:CGFloat,with width:CGFloat)
    
    /**
     Asks the view to change its validation state of the selected tab
     - Parameter validationState: The new validation state
     */
    func changeValidity(to validationState:Bool)
}

/// Porotocl to communicate with the outer parent to inform him about events
@objc public protocol TapGoPayLoginBarViewModelDelegate {
    /**
     Will be fired once the user make a selection to change the login option from the tab bar
     - Parameter viewModel: THe selected login option view model
     */
    @objc func loginOptionSelected(with viewModel:TapGoPayTitleViewModel)
}

/// View model that controls the actions and the ui of the go pay login options tab bar
@objc public class TapGoPayLoginBarViewModel: NSObject {
    
    /// Delegate to communicate between the view controlled by this view model ad the view model itself
    internal var viewDelegate:TapGoPayLoginBarViewDelegate?
    /// The data source which is the list if tab view models that we need to render
    internal var dataSource:[TapGoPayTitleViewModel] = [] {
        didSet{
            // Once set, we need to configure the inner view models
            configureDataSource()
        }
    }
    
    /// Tells which OTP we are in, goPay or saved card
    internal var hintViewStatus:TapHintViewStatusEnum = .GoPayOtp
    
    /// The countries which the user is allowed to login with it, should have at least 1 country
    internal var allowedCountries:[TapCountry] = [] {
        didSet {
            configureLoginCountries()
        }
    }
    
    // MARK:- Public normal swift variables
    /// Porotocl to communicate with the outer parent to inform him about events
    @objc public var delegate:TapGoPayLoginBarViewModelDelegate?
    /// The hint label to be shown above the OTP view
    @objc public var hintLabelText:String {
        return TapLocalisationManager.shared.localisedValue(for: "GoPay.HintLabel", with: TapCommonConstants.pathForDefaultLocalisation())
    }
    /// Represents the phone the otp has been sent to, will be used in the case where the otp is sent from the backend not through the phone the user enetred while logging in to goPay
    @objc public var otpSentToNumber:String = ""
    
    /**
     Creates a new instance of the TapGoPayLoginBarViewModel
     - Parameter delegate: The delegate which listenes to our events
     - Parameter countries: The countries which the user is allowed to login with it, should have at least 1 country
     - Parameter otpSentToNumber : Represents the phone the otp has been sent to, will be used in the case where the otp is sent from the backend not through the phone the user enetred while logging in to goPay
     */
    @objc public init(delegate:TapGoPayLoginBarViewModelDelegate? = nil,countries:[TapCountry], otpSentToNumber:String = "") {
        super.init()
        self.delegate = delegate
        self.otpSentToNumber = otpSentToNumber
        guard countries.count > 0 else {
            fatalError("The countries the user can login with should have at least 1 country")
        }
        defer {
            self.allowedCountries = countries
        }
    }
    
    /// Handles all the logic POST assigning a new data source
    internal func configureDataSource() {
        // Assign each viewmodel delegate to self
        dataSource.forEach{ $0.delegate = self }
        // On load, select the first option :)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
            // Give it a little time to render the labels (so if an option has LONG title, then bar will fit nicely)
            self?.select(option: self!.dataSource[0].titleSegment, with: false)
        }
        
    }
    
    /// Method to adjust the phone input with the default country once they are set
    internal func configureLoginCountries() {
        
    }
    
    /**
     Informs all options to deselct themselves except the selected one
     - Parameter optionViewModel: The selected view model, other viewmodels will be deselected
     */
    internal func deselectOptions(except optionViewModel:TapGoPayTitleViewModel) {
        dataSource.forEach{ $0.titleStatus = (optionViewModel == $0) ? .selected : .otherIconIsSelectedUnVerified }
    }
    
    
    // MARK:- Public methods
    /**
     Handles the logic of selecting a new tab
     - Parameter loginOption: The login option to be selected
     - Parameter validation: Is the selected option is a valid or invalid one
     */
    @objc public func select(option loginOption:GoPyLoginOption,with validation:Bool = false) {
        
        // After firing the required events, we need to move the bar to the selected tab associated to the brand
        let relatedModels:[TapGoPayTitleViewModel] = dataSource.filter{ $0.titleSegment == loginOption}
        guard relatedModels.count > 0 else { return }
        // Perform logic needed for selecting an option
        titleIsSelected(with: relatedModels[0])
        // Apply the theme based on the validation status provided
        changeSelectionValidation(to: validation)
    }
    
    /**
     Asks the view to change its validation state of the selected tab
     - Parameter newValidationState: The new validation state
     */
    @objc public func changeSelectionValidation(to newValidationState:Bool) {
        viewDelegate?.changeValidity(to: newValidationState)
    }
}

extension TapGoPayLoginBarViewModel:TapGoPayTitleViewModelDelegate {
    
    func titleIsSelected(with viewModel: TapGoPayTitleViewModel) {
        // First thing, deselct others
        deselectOptions(except:viewModel)
        // Set validty to false, until the parent instructs other info
        changeSelectionValidation(to: false)
        // Fetch the frame for the selected tab
        let segmentFrame:CGRect = viewModel.viewFrame()
        // Change the underline to the computed frame
        viewDelegate?.animateBar(to: segmentFrame.origin.x, with: segmentFrame.width)
        // Inform the delegate that an option has beens selected
        delegate?.loginOptionSelected(with: viewModel)
    }
}
