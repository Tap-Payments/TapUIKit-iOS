//
//  TapCardPhoneBarListViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/29/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import RxCocoa
import SnapKit


internal protocol TapCardPhoneBarListViewModelDelegate {
    func animateBar(to x:CGFloat,with width:CGFloat)
}


public class TapCardPhoneBarListViewModel {
    
    
    internal var dataSourceObserver:BehaviorRelay<[TapCardPhoneIconViewModel]> = .init(value: [])
    internal var viewDelegate:TapCardPhoneBarListViewModelDelegate?
    
    public var dataSource:[TapCardPhoneIconViewModel] = [] {
        didSet{
            dataSource.forEach{ $0.delegate = self }
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
        
        // we need to filter out only the icons with this specific segment
        let filteredViewModel:[TapCardPhoneIconViewModel] = dataSource.filter{ return $0.associatedCardBrand.brandSegmentIdentifier == segment }
        guard filteredViewModel.count > 0 else { return .zero }
        
        
        guard filteredViewModel.count > 1 else { return filteredViewModel[0].viewDelegate?.viewFrame() ?? .zero }
        
        var resultRect:CGRect = filteredViewModel[0].viewDelegate?.viewFrame() ?? .zero
        resultRect.size.width = (filteredViewModel.last?.viewDelegate?.viewFrame() ?? .zero).maxX - resultRect.minX
        
        return resultRect
        
    }
}

extension TapCardPhoneBarListViewModel:TapCardPhoneIconDelegate {
    func iconIsSelected(with viewModel: TapCardPhoneIconViewModel) {
        print(viewModel.tapCardPhoneIconUrl)
        //print(frame(for: viewModel.associatedCardBrand.brandSegmentIdentifier))
        let segmentFrame:CGRect = frame(for: viewModel.associatedCardBrand.brandSegmentIdentifier)
        viewDelegate?.animateBar(to: segmentFrame.origin.x, with: segmentFrame.width)
    }
}
