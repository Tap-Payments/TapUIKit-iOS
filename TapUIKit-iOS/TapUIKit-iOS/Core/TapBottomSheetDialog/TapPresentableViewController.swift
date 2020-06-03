//
//  TapPresentableViewController.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/3/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import PullUpController
/// Inheric this class for any view controller you want to show as bottom dialog modal popup
@objc open class TapPresentableViewController: PullUpController {
    
    
    internal var tapBottomSheetStickingPoints:[CGFloat]?
    internal var minimumHeight:CGFloat = ConstantManager.TapBottomSheetMinimumHeight
    internal var initialHeight:CGFloat = 100
    internal var maxHeight:CGFloat = 500
    
    public override final var pullUpControllerMiddleStickyPoints: [CGFloat] {
        let stickyPoints = tapBottomSheetStickingPoints ?? generateDefaultStickyPoints()
        tapBottomSheetStickingPoints = stickyPoints
        return stickyPoints
    }
    
    /// The generated default sticking points, that will cover from the minimum height to the maximum height with a step value of 5
    private func generateDefaultStickyPoints() -> [CGFloat] {
        
        var minStickyPoint = minimumHeight
        var stickyPoints:[CGFloat] = [initialHeight]
        while minStickyPoint < maxHeight {
            stickyPoints.append(minStickyPoint)
            minStickyPoint += 50
        }
        return stickyPoints
    }
    
}
