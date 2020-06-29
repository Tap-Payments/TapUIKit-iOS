//
//  TapCardPhoneIconViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/28/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import RxCocoa
import enum TapCardVlidatorKit_iOS.CardBrand

internal protocol TapCardPhoneIconDelegate {
    func iconIsSelected(with viewModel:TapCardPhoneIconViewModel)
}

internal protocol TapCardPhoneIconViewDelegate {
    func viewFrame() -> CGRect
}


/// View model that controls the actions and the ui of the card/phone bar inner icon
public class TapCardPhoneIconViewModel:Equatable {
   
    public static func == (lhs: TapCardPhoneIconViewModel, rhs: TapCardPhoneIconViewModel) -> Bool {
        return lhs.tapCardPhoneIconUrl == rhs.tapCardPhoneIconUrl
    }
    
    
    // MARK:- RX Internal Observables
    
    /// Represent the icon state
    internal var tapCardPhoneIconStatusObserver:BehaviorRelay<TapCardPhoneIconStatus> = .init(value: .selected)
    /// Represent the url for the image to be loaded inside this icon
    internal var tapCardPhoneIconUrlObserver:BehaviorRelay<String> = .init(value: "")
    
    // MARK:- Public normal swift variables
    /// Represent the icon state
    public var tapCardPhoneIconStatus:TapCardPhoneIconStatus = .selected {
        didSet{
            tapCardPhoneIconStatusObserver.accept(tapCardPhoneIconStatus)
        }
    }
    
    /// Represent the url for the image to be loaded inside this icon
    public var tapCardPhoneIconUrl:String = "" {
        didSet{
            tapCardPhoneIconUrlObserver.accept(tapCardPhoneIconUrl)
        }
    }
    
    /// Represent the associated payment brand this cell is linked to
    public var associatedCardBrand:CardBrand = .visa
    
    /**
     - Parameter tapCardPhoneIconStatus: Represent the icon state
     - Parameter associatedCardBrand: Represent the associated payment brand this cell is linked to
     - Parameter tapCardPhoneIconUrl: Represent the url for the image to be loaded inside
     this icon
     - Parameter tapCardPhoneIconSegmentID: Represent the id of the segment this icon is related to if any
     */
    public init(tapCardPhoneIconStatus: TapCardPhoneIconStatus = .selected, associatedCardBrand:CardBrand, tapCardPhoneIconUrl: String = "") {
        defer{
            self.tapCardPhoneIconStatus = tapCardPhoneIconStatus
            self.tapCardPhoneIconUrl = tapCardPhoneIconUrl
            self.associatedCardBrand = associatedCardBrand
        }
    }
    
    internal var delegate:TapCardPhoneIconDelegate?
    internal var viewDelegate:TapCardPhoneIconViewDelegate?
    
    internal func iconIsSelected() {
        delegate?.iconIsSelected(with: self)
    }
}



/// Represent the status of the card/phone icon in the bar
public enum TapCardPhoneIconStatus {
    /// Means, this is selected ot the whole segment is selected  or itself is the selected icon (shows in full opacity)
    case selected
    /// Means, another icon is selected (shows black & white)
    case otherIconIsSelected
    /// Means, another segment is generally selected (shows opacity 50%)
    case otherSegmentSelected
    
    /// Returns the corrent theme path related to the current state
    func themePath() -> String {
        switch self {
        case .selected:
            return "selected"
        case .otherSegmentSelected:
            return "otherSegmentSelected"
        case .otherIconIsSelected:
            return "unselected"
        }
    }
}
