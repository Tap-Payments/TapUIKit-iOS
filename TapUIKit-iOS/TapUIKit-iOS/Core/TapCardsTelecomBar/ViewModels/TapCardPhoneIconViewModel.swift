//
//  TapCardPhoneIconViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/28/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import RxCocoa

/// View model that controls the actions and the ui of the card/phone bar inner icon
public class TapCardPhoneIconViewModel {
    
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
            tapCardPhoneIconUrlObserver.accept("")
        }
    }
    
    /**
     - Parameter tapCardPhoneIconStatus: Represent the icon state
     - Parameter tapCardPhoneIconUrl: Represent the url for the image to be loaded inside this icon
     */
    public init(tapCardPhoneIconStatus: TapCardPhoneIconStatus = .selected, tapCardPhoneIconUrl: String = "") {
        defer{
            self.tapCardPhoneIconStatus = tapCardPhoneIconStatus
            self.tapCardPhoneIconUrl = tapCardPhoneIconUrl
        }
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
