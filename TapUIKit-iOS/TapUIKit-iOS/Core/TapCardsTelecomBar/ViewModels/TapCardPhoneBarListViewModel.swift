//
//  TapCardPhoneBarListViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/29/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import SnapKit
import enum TapCardVlidatorKit_iOS.CardBrand
import LocalisationManagerKit_iOS
/// Protocol to communicate between the view controlled by this view model ad the view model itself
internal protocol TapCardPhoneBarListViewModelDelegate {
    /**
     Asks the view to move the underline regarding the provided coordinates
     - Parameter x: The starting point of the new position
     - Parameter width: The width of the new position
     - Parameter shouldHide: If true the bar will be invisible and false otherwise
     */
    func animateBar(to x:CGFloat,with width:CGFloat, shouldHide:Bool)
    /**
     Asks the view to provide the dynamically calculated space between tabs
     - Returns: The actual computed width between tabs
     */
    func calculatedSpacing() -> CGFloat
}

/// View model that controls the actions and the ui of the card/phone tab bar
@objc public class TapCardPhoneBarListViewModel: NSObject {
    
    // MARK:- Private RX observables
    /// An observable to fire an event once the list of icon vire models to be rendered changed
    internal var dataSourceObserver:([TapCardPhoneIconViewModel])->() = { _ in } {
        didSet{
            dataSourceObserver(dataSource)
        }
    }
    /// An observable to fire an event once a sepcific icon inside a segment is selected
    internal var segmentSelectionObserver:([String:CardBrand?])->() = { _ in } {
        didSet{
            segmentSelectionObserver(segmentSelectionObserverValue)
        }
    }
    
    /// An observable to fire an event once a sepcific icon inside a segment is selected
    internal var segmentSelectionObserverValue:[String:CardBrand?] = [:] {
        didSet {
            guard oldValue != segmentSelectionObserverValue else { return }
            segmentSelectionObserver(segmentSelectionObserverValue)
            dataSource.forEach{ $0.computeSelectionLogic(for: segmentSelectionObserverValue, and: selectedSegmentObserverValue, with: selectedIconValidatedObserverValue) }
        }
    }
    
    /// An observable to fire an event once a new segment is selected
    internal var selectedSegmentObserver:(String)->() = { _ in } {
        didSet{
            selectedSegmentObserver(selectedSegmentObserverValue)
        }
    }
    
    /// An observable to fire an event once a new segment is selected
    internal var selectedSegmentObserverValue:String = "" {
        didSet{
            guard oldValue != selectedSegmentObserverValue else { return }
            selectedSegmentObserver(selectedSegmentObserverValue)
            dataSource.forEach{ $0.computeSelectionLogic(for: segmentSelectionObserverValue, and: selectedSegmentObserverValue, with: selectedIconValidatedObserverValue) }
        }
    }
    
    /// An observable to fire an event once the validity of the seleced tab changed
    internal var selectedIconValidatedObserver:(Bool)->() = { _ in } {
        didSet{
            selectedIconValidatedObserver(selectedIconValidatedObserverValue)
        }
    }
    
    /// An observable to fire an event once the validity of the seleced tab changed
    internal var selectedIconValidatedObserverValue:Bool = false {
        didSet{
            guard oldValue != selectedIconValidatedObserverValue else { return }
            selectedIconValidatedObserver(selectedIconValidatedObserverValue)
            dataSource.forEach{ $0.computeSelectionLogic(for: segmentSelectionObserverValue, and: selectedSegmentObserverValue, with: selectedIconValidatedObserverValue) }
        }
    }
    
    /// Delegate to communicate between the view controlled by this view model ad the view model itself
    internal var viewDelegate:TapCardPhoneBarListViewModelDelegate?
    
    // MARK:- Public normal swift variables
    /// The data source which is the list if tab view models that we need to render
    @objc public var dataSource:[TapCardPhoneIconViewModel] = [] {
        didSet{
            segmentSelectionObserverValue = [:]
            selectedSegmentObserverValue = ""
            selectedIconValidatedObserverValue = false
            // Once set, we need to wire up the observables with their subscribers
            configureDataSource()
            // We need to fire an event that a new data source is here
            dataSourceObserver(dataSource)
            dataSource.forEach{ $0.computeSelectionLogic(for: segmentSelectionObserverValue, and: selectedSegmentObserverValue, with: selectedIconValidatedObserverValue) }
        }
    }
    
    /**
     Creates a new instance of the TapCardPhoneBarListViewModel
     - Parameter dataSource: The data source which is the list if tab view models that we need to render
     */
    @objc public init(dataSource:[TapCardPhoneIconViewModel] = []) {
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
            tapCardPhoneIconView.snp.remakeConstraints {
                $0.width.equalTo(24)
                $0.height.equalTo(24)
            }
            return tapCardPhoneIconView
        }
    }
    
    /**
     Generates a list of urls for the defined card brands upon setup
     */
    public func generateBrandsWithIcons() -> [CardBrand.RawValue:String] {
        var result:[CardBrand.RawValue:String] = [:]
        dataSource.forEach{ result[$0.associatedCardBrand.rawValue] = $0.tapCardPhoneIconUrl }
        return result
    }
    
    /**
     Comutes the frame where the underline should go to, whether the whole frame of a segment or the frame of a specific tab inside the segment
     - Parameter segment: Defines the segment ID to get the correct underline frame regarding to
     - Returns: The frame of the underline that covers the whole segment if no tab is selected inside the segment or the frame of the specific tab inside the segment if any. Also, if we need to select the whole segment and there is no other segment, so we don;t have to highlight it we will return a false with the rect
     */
    internal func frame(for segment:String) -> (CGRect,Bool) {
        
        // now we need to move the segment to the selected segment, but first we need to know if we will move it to cover the whole segment or the previously selected icon inside this segment
        
        // Filter all view models that lies within the provided segment
        let filteredViewModel:[TapCardPhoneIconViewModel] = dataSource.filter{ return $0.associatedCardBrand.brandSegmentIdentifier == segment }
        // Defensive coding to make sure theere is at least 1 tab associated with the given segment id
        guard filteredViewModel.count > 0 else { return (.zero,false) }
        
        // Get the frame of the FIRST tab within the segment
        var resultRect:CGRect = filteredViewModel[0].viewDelegate?.viewFrame() ?? .zero
        
        // Now we need to decide shall we highlight the whole segment or there is an already selected tab within this segment
        guard let selectedBrand:CardBrand = segmentSelectionObserverValue[segment] as? CardBrand else {
            // Meaning, there is no selected icon inside this segment, hence we highlight the whole segment
            return (computeSegmentGroupRect(for: filteredViewModel, and: resultRect),false)
        }
        
        // Meaning there is a sepcic icon selected in this segment, we need to highlight it alone
        
        // Get the selected tab view model
        let selectedViewModel:TapCardPhoneIconViewModel = filteredViewModel.filter{ return $0.associatedCardBrand == selectedBrand }[0]
        
        // Get its frame
        resultRect = selectedViewModel.viewDelegate?.viewFrame() ?? .zero
        
        return (computeIconRect(for: selectedViewModel, within: filteredViewModel, and: resultRect),true)
    }
    
    /**
     Comutes the frame to cover a whole segment based on the current localisation. Will set the correct X and correct width
     - Parameter filteredViewModel: The view models that are covered within the required segment to get its frame
     - Parameter initialRect: The intial computed frame
     */
    internal func computeSegmentGroupRect(for filteredViewModel:[TapCardPhoneIconViewModel],and initialRect:CGRect) -> CGRect {
        let sharedLocalisationManager:TapLocalisationManager = .shared
        var resultRect = initialRect
        
        // if this is the only segment, then we don't need to highlight it
        guard dataSource.filter({ $0.associatedCardBrand.brandSegmentIdentifier != filteredViewModel.first?.associatedCardBrand.brandSegmentIdentifier }).count > 0 else {
            // This means no other options with a different segment id, hence it is only segment and we don't need to show a bar beneath.
            return resultRect
        }
        
        // If it is the first segment, we need to start from X = 0
        // If the last segment, hence we need the width to cover the whole screen till the end
        
        if sharedLocalisationManager.localisationLocale == "ar" {
            // RTL computations
            if dataSource.firstIndex(of: filteredViewModel[0]) == 0 {
                // if the first segment then we cover from the end of the screen till the end of the group
                resultRect.size.width = UIScreen.main.bounds.size.width - (filteredViewModel.last?.viewDelegate?.viewFrame() ?? .zero).minX
                resultRect.origin.x = UIScreen.main.bounds.size.width
            }else {
                if dataSource.firstIndex(of: filteredViewModel.last!) == dataSource.count - 1 {
                    resultRect.size.width = (filteredViewModel.first?.viewDelegate?.viewFrame() ?? .zero).maxX
                    resultRect.origin.x = resultRect.size.width
                }
            }
        }else {
            // LTR computations
            if dataSource.firstIndex(of: filteredViewModel[0]) == 0 {
                // if the first segment then we cover from the start of the screen till the end of the group
                resultRect.origin.x = 0
                resultRect.size.width = (filteredViewModel.last?.viewDelegate?.viewFrame() ?? .zero).maxX - resultRect.minX
            }else {
                if dataSource.firstIndex(of: filteredViewModel.last!) == dataSource.count - 1 {
                    resultRect.size.width = UIScreen.main.bounds.size.width - resultRect.origin.x + 10
                }
            }
        }
        
        return resultRect
    }
    
    
    
    /**
     Comutes the frame to cover a selected segment based on the current localisation. Will set the correct X and correct width
     - Parameter selectedViewModel: The view model we want to cover
     - Parameter filteredViewModel: The view models that are covered within the required segment to get its frame
     - Parameter initialRect: The intial computed frame
     */
    internal func computeIconRect(for selectedViewModel:TapCardPhoneIconViewModel, within filteredViewModel:[TapCardPhoneIconViewModel],and initialRect:CGRect) -> CGRect {
        let sharedLocalisationManager:TapLocalisationManager = .shared
        var resultRect = initialRect
        
        // If it is the first tab, we need to start from X = 0
        if sharedLocalisationManager.localisationLocale == "ar" {
            // RTL computations
            if dataSource.firstIndex(of: selectedViewModel) == 0 {
                // if the first segment then we cover from the end of the screen till the end of the selected icon
                resultRect.size.width += (UIScreen.main.bounds.size.width - resultRect.maxX)
                resultRect.origin.x = UIScreen.main.bounds.size.width
            }else if dataSource.firstIndex(of: selectedViewModel) == dataSource.count - 1 {
                // If the last tab, hence we need the width to cover the whole screen till the end
                //resultRect.size.width = resultRect.origin.x + resultRect.maxX
                resultRect.origin.x += resultRect.size.width
            }else {
                resultRect.origin.x += resultRect.size.width
            }
        }else {
            // LTR computations
            if dataSource.firstIndex(of: selectedViewModel) == 0 {
                // if the first segment then we cover from the start of the screen till the end of the selected icon
                resultRect.size.width += resultRect.origin.x
                resultRect.origin.x = 0
            }else if dataSource.firstIndex(of: selectedViewModel) == dataSource.count - 1 {
                // If the last tab, hence we need the width to cover the whole screen till the end
                //resultRect.size.width = UIScreen.main.bounds.size.width - resultRect.origin.x + 10
            }
        }
        
        return resultRect
    }
    
    /// Handles all the logic POST assigning a new data source
    internal func configureDataSource() {
        // Assign each viewmodel delegate to self
        dataSource.forEach{ $0.delegate = self }
        
        // Create an empty segment selection state
        segmentSelectionObserverValue = [:]
        
        // With new dataSource, we will not keep a segment selected
        selectedSegmentObserverValue = ""
        
        // No valid selection now
        selectedIconValidatedObserverValue = false
    }
    
    
    // MARK:- Public methods
    /**
     Handles the logic of selecting a new tab
     - Parameter cardBrand: The payment card brand associated the tab we need to select
     - Parameter validity: Indicates whether th selection is validated or not
     */
    @objc public func select(brand cardBrand:CardBrand, with validity:Bool) {
        // Fire a notification of a new selected segment
        selectedSegmentObserverValue = cardBrand.brandSegmentIdentifier
        // Fire a notification of a new selection validation
        selectedIconValidatedObserverValue = validity
        // Fire a notification of a new selected tab inside the segment
        var currentSelection = segmentSelectionObserverValue
        currentSelection[cardBrand.brandSegmentIdentifier] = cardBrand
        segmentSelectionObserverValue = currentSelection
        
        // After firing the required events, we need to move the bar to the selected tab associated to the brand
        let relatedModels:[TapCardPhoneIconViewModel] = dataSource.filter{ $0.associatedCardBrand == cardBrand}
        guard relatedModels.count > 0 else { return }
        iconIsSelected(with: relatedModels[0])
        
        
    }
    
    /**
     This method will select a certain segment as a group
     - Parameter segmentID: The id of the segment to be selcted
     */
    @objc public func select(segment segmentID:String) {
        // Fire a notification of a new selected segment
        selectedSegmentObserverValue = segmentID
        // Fire a notification of a new selection validation
        selectedIconValidatedObserverValue = false
        
        var currentSelection = segmentSelectionObserverValue
        currentSelection[segmentID] = nil
        segmentSelectionObserverValue = currentSelection
        
        // After firing the required events, we need to move the bar to the selected tab associated to the brand
        let relatedModels:[TapCardPhoneIconViewModel] = dataSource.filter{ $0.associatedCardBrand.brandSegmentIdentifier == segmentID}
        guard relatedModels.count > 0 else { return }
        iconIsSelected(with: relatedModels[0])
    }
    
    /**
     This method will deselct all selected segments if any
     */
    @objc public func resetCurrentSegment() {
        let currentSelectedSegment:String = selectedSegmentObserverValue
        guard currentSelectedSegment != "" else { return }
        
        selectedIconValidatedObserverValue = false
        
        var currentSelection = segmentSelectionObserverValue
        currentSelection[currentSelectedSegment] = nil
        segmentSelectionObserverValue = currentSelection
        
        // After firing the required events, we need to move the bar to the selected tab associated to the brand
        let relatedModels:[TapCardPhoneIconViewModel] = dataSource.filter{ $0.associatedCardBrand.brandSegmentIdentifier == currentSelectedSegment}
        guard relatedModels.count > 0 else { return }
        iconIsSelected(with: relatedModels[0])
    }
}

extension TapCardPhoneBarListViewModel:TapCardPhoneIconDelegate {
    
    func iconIsSelected(with viewModel: TapCardPhoneIconViewModel) {
        // Fetch the frame for the selected tab
        let (segmentFrame,hideBar) = frame(for: viewModel.associatedCardBrand.brandSegmentIdentifier)
        
        guard segmentFrame.width > 0 && segmentFrame.height > 0 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(550)) { [weak self] in
                self?.iconIsSelected(with: viewModel)
            }
            return
        }
        // Add half of the spacing to its width
        //segmentFrame.size.width += abs((viewDelegate?.calculatedSpacing() ?? 0))
        // Change the underline to the computed frame
        viewDelegate?.animateBar(to: segmentFrame.origin.x, with: segmentFrame.width,shouldHide: hideBar)
        selectedSegmentObserverValue = viewModel.associatedCardBrand.brandSegmentIdentifier
    }
}
