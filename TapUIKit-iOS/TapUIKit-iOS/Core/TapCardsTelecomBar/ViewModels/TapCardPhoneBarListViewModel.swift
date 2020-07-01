//
//  TapCardPhoneBarListViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/29/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import SnapKit
import enum TapCardVlidatorKit_iOS.CardBrand

/// Protocol to communicate between the view controlled by this view model ad the view model itself
internal protocol TapCardPhoneBarListViewModelDelegate {
    /**
     Asks the view to move the underline regarding the provided coordinates
     - Parameter x: The starting point of the new position
     - Parameter width: The width of the new position
     */
    func animateBar(to x:CGFloat,with width:CGFloat)
    /**
        Asks the view to provide the dynamically calculated space between tabs
     - Returns: The actual computed width between tabs
     */
    func calculatedSpacing() -> CGFloat
}

/// View model that controls the actions and the ui of the card/phone tab bar
public class TapCardPhoneBarListViewModel {
    
    // MARK:- Private RX observables
    /// An observable to fire an event once the list of icon vire models to be rendered changed
    internal var dataSourceObserver:BehaviorRelay<[TapCardPhoneIconViewModel]> = .init(value: [])
    /// An observable to fire an event once a sepcific icon inside a segment is selected
    internal var segmentSelectionObserver:BehaviorRelay<[String:CardBrand?]> = .init(value: [:])
    /// An observable to fire an event once a new segment is selected
    internal var selectedSegmentObserver:BehaviorRelay<String> = .init(value:"")
    /// An observable to fire an event once the validity of the seleced tab changed
    internal var selectedIconValidatedObserver:BehaviorRelay<Bool> = .init(value:false)
    
    /// Delegate to communicate between the view controlled by this view model ad the view model itself
    internal var viewDelegate:TapCardPhoneBarListViewModelDelegate?
    
    // MARK:- Public normal swift variables
    /// The data source which is the list if tab view models that we need to render
    public var dataSource:[TapCardPhoneIconViewModel] = [] {
        didSet{
            // Once set, we need to wire up the observables with their subscribers
            configureDataSource()
            // We need to fire an event that a new data source is here
            dataSourceObserver.accept(dataSource)
        }
    }
    
    /**
     Creates a new instance of the TapCardPhoneBarListViewModel
     - Parameter dataSource: The data source which is the list if tab view models that we need to render
     */
    public init(dataSource:[TapCardPhoneIconViewModel] = []) {
        self.dataSource = dataSource
    }
    
    
    
    // MARK:- Private methods
    /**
        Generates the list if tab views from the list of tab view models
     - Parameter maxWidth: The tab layout will try to spread the tabs with full screen width but spacing will not go beyond the provided max width
     - Returns: List of TapCardPhoneIconView, where each view represents  tab view with its tab view model
     */
    internal func generateViews(with maxWidth:CGFloat = 50) -> [TapCardPhoneIconView] {
        // For each tab view model we generate a tab view from it
        return dataSource.map {
            // Empty tab view
            let tapCardPhoneIconView:TapCardPhoneIconView = .init()
            // Assing the view model
            tapCardPhoneIconView.setupView(with: $0)
            // Apply the max width constraint
            tapCardPhoneIconView.snp.remakeConstraints { $0.width.equalTo(maxWidth).priority(.medium) }
            return tapCardPhoneIconView
        }
    }
    
    /**
        Comutes the frame where the underline should go to, whether the whole frame of a segment or the frame of a specific tab inside the segment
     - Parameter segment: Defines the segment ID to get the correct underline frame regarding to
     - Returns: The frame of the underline that covers the whole segment if no tab is selected inside the segment or the frame of the specific tab inside the segment if any
     */
    internal func frame(for segment:String) -> CGRect {
        
        // now we need to move the segment to the selected segment, but first we need to know if we will move it to cover the whole segment or the previously selected icon inside this segment
        
        // Filter all view models that lies within the provided segment
        let filteredViewModel:[TapCardPhoneIconViewModel] = dataSource.filter{ return $0.associatedCardBrand.brandSegmentIdentifier == segment }
        // Defensive coding to make sure theere is at least 1 tab associated with the given segment id
        guard filteredViewModel.count > 0 else { return .zero }
        
        // Get the frame of the FIRST tab within the segment
        var resultRect:CGRect = filteredViewModel[0].viewDelegate?.viewFrame() ?? .zero
        
        // Now we need to decide shall we highlight the whole segment or there is an already selected tab within this segment
        guard let selectedBrand:CardBrand = segmentSelectionObserver.value[segment] as? CardBrand else {
            // Meaning, there is no selected icon inside this segment, hence we highlight the whole segment
            
            // If it is the first segment, we need to start from X = 0
            if dataSource.firstIndex(of: filteredViewModel[0]) == 0 {
                resultRect.origin.x = 0
                resultRect.size.width = (filteredViewModel.last?.viewDelegate?.viewFrame() ?? .zero).maxX - resultRect.minX
            }else {
                // If the last segment, hence we need the width to cover the whole screen till the end
                if dataSource.firstIndex(of: filteredViewModel.last!) == dataSource.count - 1 {
                    resultRect.size.width = UIScreen.main.bounds.size.width - resultRect.origin.x + 10
                }
            }
            return resultRect
        }
        
        // Meaning there is a sepcic icon selected in this segment, we need to highlight it alone
        
        // Get the selected tab view model
        let selectedViewModel:TapCardPhoneIconViewModel = filteredViewModel.filter{ return $0.associatedCardBrand == selectedBrand }[0]
        
        // Get its frame
        resultRect = selectedViewModel.viewDelegate?.viewFrame() ?? .zero
        
        // If it is the first tab, we need to start from X = 0
        if dataSource.firstIndex(of: selectedViewModel) == 0 {
            resultRect.size.width += resultRect.origin.x
            resultRect.origin.x = 0
        }else if dataSource.firstIndex(of: selectedViewModel) == dataSource.count - 1 {
            // If the last tab, hence we need the width to cover the whole screen till the end
            resultRect.size.width = UIScreen.main.bounds.size.width - resultRect.origin.x + 10
        }
        return resultRect
    }
    
    /// Handles all the logic POST assigning a new data source
    internal func configureDataSource() {
        // Assign each viewmodel delegate to self
        dataSource.forEach{ $0.delegate = self }
        
        // Create an empty segment selection state
        segmentSelectionObserver.accept([:])
        
        // With new dataSource, we will not keep a segment selected
        selectedSegmentObserver.accept("")
        
        // No valid selection now
        selectedIconValidatedObserver.accept(false)
    }
    
    
    // MARK:- Public methods
    /**
     Handles the logic of selecting a new tab
     - Parameter cardBrand: The payment card brand associated the tab we need to select
     - Parameter validity: Indicates whether th selection is validated or not
     */
    public func select(brand cardBrand:CardBrand, with validity:Bool) {
        // Fire a notification of a new selected segment
        selectedSegmentObserver.accept(cardBrand.brandSegmentIdentifier)
        // Fire a notification of a new selection validation
        selectedIconValidatedObserver.accept(validity)
        // Fire a notification of a new selected tab inside the segment
        var currentSelection = segmentSelectionObserver.value
        currentSelection[cardBrand.brandSegmentIdentifier] = cardBrand
        segmentSelectionObserver.accept(currentSelection)
        
        // After firing the required events, we need to move the bar to the selected tab associated to the brand
        let relatedModels:[TapCardPhoneIconViewModel] = dataSource.filter{ $0.associatedCardBrand == cardBrand}
        guard relatedModels.count > 0 else { return }
        iconIsSelected(with: relatedModels[0])
    }
}

extension TapCardPhoneBarListViewModel:TapCardPhoneIconDelegate {
    func selectionObservers() -> (Observable<[String : CardBrand?]>, Observable<String>, Observable<Bool>) {
        return (segmentSelectionObserver.share(),selectedSegmentObserver.share(), selectedIconValidatedObserver.share())
    }
    
    func iconIsSelected(with viewModel: TapCardPhoneIconViewModel) {
        // Fetch the frame for the selected tab
        var segmentFrame:CGRect = frame(for: viewModel.associatedCardBrand.brandSegmentIdentifier)
        // Add half of the spacing to its width
        segmentFrame.size.width += (viewDelegate?.calculatedSpacing() ?? 0)
        // Change the underline to the computed frame
        viewDelegate?.animateBar(to: segmentFrame.origin.x, with: segmentFrame.width)
        selectedSegmentObserver.accept(viewModel.associatedCardBrand.brandSegmentIdentifier)
    }
}
