//
//  TapCardPhoneIconViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/28/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//
import Foundation
import enum TapCardVlidatorKit_iOS.CardBrand

/// Protocol to communicate between the parenr viewmodel (The bar list view model) and this view model
internal protocol TapCardPhoneIconDelegate {
    /**
     Inform the bar list view model that there is an icon had been selected
     - Parameter viewModel: The TapCardPhoneIconViewModel related to the selected icon
     */
    func iconIsSelected(with viewModel:TapCardPhoneIconViewModel)
}

/// Protocol to communicate between the view controlled by this view model ad the view model itself
internal protocol TapCardPhoneIconViewDelegate {
    /**
     Asks the view to calclate its view bounds relative to its superview
     - Returns: A rect represents the boundries of the associated view
     */
    func viewFrame() -> CGRect
}


/// View model that controls the actions and the ui of the card/phone bar inner icon
@objc public class TapCardPhoneIconViewModel:NSObject {
    
    // MARK:- RX Internal Observables
    
    /// Represent the icon state
    internal var tapCardPhoneIconStatusObserver:(TapCardPhoneIconStatus)->() = { _ in } {
        didSet{
            tapCardPhoneIconStatusObserver(tapCardPhoneIconStatus)
        }
    }
    /// Represent the url for the image to be loaded inside this icon
    internal var tapCardPhoneIconUrlObserver:(String)->() = { _ in } {
        didSet{
            tapCardPhoneIconUrlObserver(logoUrl)
        }
    }
    
    // MARK:- Public normal swift variables
    /// Represent the icon state
    @objc public var tapCardPhoneIconStatus:TapCardPhoneIconStatus = .selected {
        didSet{
            // Update the observabe with the new state
            tapCardPhoneIconStatusObserver(tapCardPhoneIconStatus)
        }
    }
    
    /// Represent the icon state
    @objc public var isDisabled: Bool = true {
        didSet{
            tapCardPhoneIconUrlObserver(logoUrl)
        }
    }
    
    /// Represent the disabled icon url
    @objc public var tapCardDisabledPhoneIconUrl: String = "" {
        didSet{
            tapCardPhoneIconUrlObserver(logoUrl)
        }
    }
    
    /// Represent the url for the image to be loaded inside this icon
    @objc public var tapCardPhoneIconUrl:String = "" {
        didSet{
            // Update the observabe with the new url
            tapCardPhoneIconUrlObserver(logoUrl)
        }
    }
    
    /// Represent the associated payment brand this cell is linked to
    @objc public var associatedCardBrand:CardBrand = .visa
    
    /// Unique identifier for the object.
    @objc public var paymentOptionIdentifier: String = ""
    
    // MARK:- Private methods
    
    ///Delegate to communicate between the parenr viewmodel (The bar list view model) and this view model
    internal var delegate:TapCardPhoneIconDelegate?{
        didSet{
            // Once assigned, we need to register for the delegate provided observables
            bindObservables()
        }
    }
    
    /// Return the correct image url according to state
    internal var logoUrl:String {
        get{
            if (isDisabled) {
                return tapCardDisabledPhoneIconUrl
            } else{
                return tapCardPhoneIconUrl
            }
        }
    }
    
    
    /// Delegae to communicate between the view controlled by this view model ad the view model itself
    internal var viewDelegate:TapCardPhoneIconViewDelegate?
    
    /// The attached view will call this method once it had been clicked by the user
    internal func iconIsSelected() {
        // We need to inform our view model delegate that a selection happened, so it can execute the needed logic
        delegate?.iconIsSelected(with: self)
    }
    
    /// Used to bind all the needed reactive observables to its matching logic and functions
    internal func bindObservables() {
        // Defensive coding to check we have a proper delegate first
        /*guard let delegate = delegate else { return }
         // Fetch the observables from the delegate
         let (segmentSelection , selectedSegment, selectedValidated) = delegate.selectionObservers()
         
         // Listen to inner segment selection status coupled with selected segment value and the validty of the selection
         Observable.combineLatest(segmentSelection.distinctUntilChanged(), selectedSegment.distinctUntilChanged(), selectedValidated.distinctUntilChanged())
         .subscribe(onNext: { [weak self] (segmentsSelections:[String:CardBrand?], selectedSegment:String, selectedValidated:Bool) in
         // Everytime any of the observables changes, we need to recompite our selection lofic for this specific view model and its attached view
         self?.computeSelectionLogic(for: segmentsSelections, and: selectedSegment, with: selectedValidated )
         }).disposed(by: disposeBag)*/
    }
    
    /**
     Decides the theme should be applied to the associated view based on the rules of tabs selections and the provided inputs
     - Parameter segmentsSelections: Provides which tab is selected inside each segment if any
     - Parameter selectedSegment: Provides the segment identifier of the last selected segment
     - Parameter selectedValidated: Provides the validity of the selected tab if any
     */
    internal func computeSelectionLogic(for segmentsSelections:[String:CardBrand?], and selectedSegment:String, with selectedValidated:Bool ) {
        // First we check if there is any segment selected
        guard selectedSegment != "" else {
            // No segment is selected, then all icons should be shown normally
            tapCardPhoneIconStatus = .selected
            return
        }
        
        // Now there is a segment selected, then we need to know if there is a specific icon is selected inside this segment or the whole segment is selected in general
        guard let selectedCardBrand:CardBrand = segmentsSelections[selectedSegment] as? CardBrand else {
            // The segment has no specific icon selected, hence the segment is generally selected.
            // Then this icon will whether be full colored if in segment or opacity if it is in another segment
            tapCardPhoneIconStatus = ((associatedCardBrand.brandSegmentIdentifier == selectedSegment) ? .selected : .otherSegmentSelected )
            return
        }
        
        /* This means there is a segment selected and there is an inner icon inside is selected, then we follow these rules:
         1- If the selection is validated, then all icons will be black and white except the selected icon will be colored
         2- If the selection is invalid, then all icons will be opacity and the selected icon will be colored
         */
        tapCardPhoneIconStatus = ((associatedCardBrand == selectedCardBrand) ? .selected : (selectedValidated) ? .otherIconIsSelectedVerified : .otherIconIsSelectedUnVerified )
    }
    // MARK:- Public methods
    
    public static func == (lhs: TapCardPhoneIconViewModel, rhs: TapCardPhoneIconViewModel) -> Bool {
        return lhs.tapCardPhoneIconUrl == rhs.tapCardPhoneIconUrl
    }
    
    
    /**
     - Parameter tapCardPhoneIconStatus: Represent the icon state
     - Parameter associatedCardBrand: Represent the associated payment brand this cell is linked to
     - Parameter tapCardPhoneIconUrl: Represent the url for the image to be loaded inside
     this icon
     */
    @objc public init(tapCardPhoneIconStatus: TapCardPhoneIconStatus = .selected, associatedCardBrand:CardBrand, tapCardPhoneIconUrl: String = "", paymentOptionIdentifier:String = "", isDisabled: Bool = false, tapCardDisabledPhoneIconUrl: String = "") {
        super.init()
        defer{
            self.tapCardPhoneIconStatus      = tapCardPhoneIconStatus
            self.tapCardPhoneIconUrl         = tapCardPhoneIconUrl
            self.associatedCardBrand         = associatedCardBrand
            self.paymentOptionIdentifier     = paymentOptionIdentifier
            self.isDisabled                  = isDisabled
            self.tapCardDisabledPhoneIconUrl = tapCardDisabledPhoneIconUrl
        }
    }
}



/// Represent the status of the card/phone icon in the bar
@objc public enum TapCardPhoneIconStatus:Int {
    /// Means, this is selected ot the whole segment is selected  or itself is the selected icon (shows in full opacity)
    case selected = 0
    /// Means, another icon is selected and verified (shows black & white)
    case otherIconIsSelectedVerified = 1
    /// Means, another icon is selected  but yet unverified(shows opacity 50%)
    case otherIconIsSelectedUnVerified = 2
    /// Means, another segment is generally selected (shows opacity 50%)
    case otherSegmentSelected = 3
    
    /** Returns the corrent theme path related to the current state
     - Returns: The correct theme path based on the icon state
     */
    func themePath() -> String {
        switch self {
        case .selected:
            return "selected"
        case .otherSegmentSelected,.otherIconIsSelectedUnVerified:
            return "otherSegmentSelected"
        case .otherIconIsSelectedVerified:
            return "unselected"
        }
    }
}
