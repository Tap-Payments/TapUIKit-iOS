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

internal protocol TapCardPhoneBarListViewModelDelegate {
    func animateBar(to x:CGFloat,with width:CGFloat)
    func calculatedSpacing() -> CGFloat
}


public class TapCardPhoneBarListViewModel {
    
    
    internal var dataSourceObserver:BehaviorRelay<[TapCardPhoneIconViewModel]> = .init(value: [])
    internal var viewDelegate:TapCardPhoneBarListViewModelDelegate?
    internal var segmentSelectionObserver:BehaviorRelay<[String:CardBrand?]> = .init(value: [:])
    internal var selectedSegmentObserver:BehaviorRelay<String> = .init(value:"")
    internal var selectedIconValidatedObserver:BehaviorRelay<Bool> = .init(value:false)
    
    public var dataSource:[TapCardPhoneIconViewModel] = [] {
        didSet{
            configureDataSource()
            dataSourceObserver.accept(dataSource)
        }
    }
    
    public init(dataSource:[TapCardPhoneIconViewModel] = []) {
        self.dataSource = dataSource
    }
    
    internal func generateViews(with maxWidth:CGFloat = 50) -> [TapCardPhoneIconView] {
        
        return dataSource.map {
            let tapCardPhoneIconView:TapCardPhoneIconView = .init()
            tapCardPhoneIconView.setupView(with: $0)
            tapCardPhoneIconView.snp.remakeConstraints { $0.width.equalTo(maxWidth).priority(.medium) }
            return tapCardPhoneIconView
        }
    }
    
    internal func frame(for segment:String) -> CGRect {
        
        // now we need to move the segment to the selected segment, but first we need to know if we will move it to cover the whole segment or the previously selected icon inside this segment
        let filteredViewModel:[TapCardPhoneIconViewModel] = dataSource.filter{ return $0.associatedCardBrand.brandSegmentIdentifier == segment }
        guard filteredViewModel.count > 0 else { return .zero }
        
        var resultRect:CGRect = filteredViewModel[0].viewDelegate?.viewFrame() ?? .zero
        
        
        
        // Now we need to decide shall we highlight the whole segment or there is an already selected tab within this segment
        guard let selectedBrand:CardBrand = segmentSelectionObserver.value[segment] as? CardBrand else {
            // Meaning, there is no selected icon inside this segment, hence we highlight the whole segment
            
            // If the first item, we need to start from X = 0
            if dataSource.firstIndex(of: filteredViewModel[0]) == 0 {
                resultRect.origin.x = 0
                resultRect.size.width = (filteredViewModel.last?.viewDelegate?.viewFrame() ?? .zero).maxX - resultRect.minX
            }else {
                // If the second segment, hence we need the width to cover the whole screen till the end
                if dataSource.firstIndex(of: filteredViewModel.last!) == dataSource.count - 1 {
                    resultRect.size.width = UIScreen.main.bounds.size.width - resultRect.origin.x + 10
                }
            }
            
            
            return resultRect
        }
        
        // Meaning there is a sepcic icon selected in this segment, we need to highlight it alone
        let selectedViewModel:TapCardPhoneIconViewModel = filteredViewModel.filter{ return $0.associatedCardBrand == selectedBrand }[0]
        resultRect = selectedViewModel.viewDelegate?.viewFrame() ?? .zero
        return resultRect
    }
    
    
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
    
    
    
    public func select(brand cardBrand:CardBrand, with validity:Bool) {
        selectedSegmentObserver.accept(cardBrand.brandSegmentIdentifier)
        selectedIconValidatedObserver.accept(validity)
        var currentSelection = segmentSelectionObserver.value
        currentSelection[cardBrand.brandSegmentIdentifier] = cardBrand
        segmentSelectionObserver.accept(currentSelection)
        
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
        print(viewModel.tapCardPhoneIconUrl)
        //print(frame(for: viewModel.associatedCardBrand.brandSegmentIdentifier))
        var segmentFrame:CGRect = frame(for: viewModel.associatedCardBrand.brandSegmentIdentifier)
        //segmentFrame.origin.x -= (viewDelegate?.calculatedSpacing() ?? 0) / 2
        segmentFrame.size.width += (viewDelegate?.calculatedSpacing() ?? 0)
        viewDelegate?.animateBar(to: segmentFrame.origin.x, with: segmentFrame.width)
        selectedSegmentObserver.accept(viewModel.associatedCardBrand.brandSegmentIdentifier)
    }
}
