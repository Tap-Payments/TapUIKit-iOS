//
//  TapCardPhoneIconViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/28/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import enum TapCardVlidatorKit_iOS.CardBrand

internal protocol TapCardPhoneIconDelegate {
    func iconIsSelected(with viewModel:TapCardPhoneIconViewModel)
    func selectionObservers() -> (Observable<[String : CardBrand?]>, Observable<String>, Observable<Bool>)
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
    internal let disposeBag:DisposeBag = .init()
    
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
    
    internal var delegate:TapCardPhoneIconDelegate?{
        didSet{
            bindObservables()
        }
    }
    internal var viewDelegate:TapCardPhoneIconViewDelegate?
    
    internal func iconIsSelected() {
        delegate?.iconIsSelected(with: self)
    }
    
    
    internal func bindObservables() {
        guard let delegate = delegate else { return }
        let (segmentSelection , selectedSegment, selectedValidated) = delegate.selectionObservers()
        
        // Listen to inner segment selection status coupled with selected segment value
        Observable.combineLatest(segmentSelection.distinctUntilChanged(), selectedSegment.distinctUntilChanged(), selectedValidated.distinctUntilChanged())
            .subscribe(onNext: { [weak self] (segmentsSelections:[String:CardBrand?], selectedSegment:String, selectedValidated:Bool) in
                self?.computeSelectionLogic(for: segmentsSelections, and: selectedSegment, with: selectedValidated )
            }).disposed(by: disposeBag)
    }
    
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
            // Then this icon will whether be clear if in segment or opacity if in another
            tapCardPhoneIconStatus = ((associatedCardBrand.brandSegmentIdentifier == selectedSegment) ? .selected : .otherSegmentSelected )
            return
        }
        
        // This means there is a segment selected and there is an inner icon inside is selected, hence the current icon will colored or blackwhite based if it is the same icon selected and then see it is validated or not
        tapCardPhoneIconStatus = ((associatedCardBrand == selectedCardBrand) ? .selected : (selectedValidated) ? .otherIconIsSelectedVerified : .otherIconIsSelectedUnVerified )
    }
}



/// Represent the status of the card/phone icon in the bar
public enum TapCardPhoneIconStatus {
    /// Means, this is selected ot the whole segment is selected  or itself is the selected icon (shows in full opacity)
    case selected
    /// Means, another icon is selected and verified (shows black & white)
    case otherIconIsSelectedVerified
    /// Means, another icon is selected  but yet unverified(shows opacity 50%)
    case otherIconIsSelectedUnVerified
    /// Means, another segment is generally selected (shows opacity 50%)
    case otherSegmentSelected
    
    /// Returns the corrent theme path related to the current state
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
