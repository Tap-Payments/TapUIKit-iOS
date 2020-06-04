//
//  TapPresentableViewController.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/3/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import PullUpController

/// A delegate of events from the pull up controller
internal protocol TapPresentableViewControllerDelegate {
    
    /**
     Will be fired once the user changed the height of the presented control by dragging it
     - Parameter newHeight : Represents the new height of the controller after the drag operation
     */
    func tapBottomSheetHeightChanged(with newHeight:CGFloat)
    
}


/// Inheric this class for any view controller you want to show as bottom dialog modal popup
@objc open class TapPresentableViewController: PullUpController {
    
    
    internal var tapBottomSheetStickingPoints:[CGFloat]?
    internal var minimumHeight:CGFloat = ConstantManager.TapBottomSheetMinimumHeight
    internal var initialHeight:CGFloat = 100
    internal var maxHeight:CGFloat = 500
    internal var delegate:TapPresentableViewControllerDelegate?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override final var pullUpControllerMiddleStickyPoints: [CGFloat] {
        let stickyPoints = tapBottomSheetStickingPoints ?? generateDefaultStickyPoints()
        tapBottomSheetStickingPoints = stickyPoints
        return stickyPoints
    }
    
    /// The generated default sticking points, that will cover from the minimum height to the maximum height with a step value of 5
    private func generateDefaultStickyPoints() -> [CGFloat] {
        
        var minStickyPoint = minimumHeight
        var stickyPoints:[CGFloat] = [ConstantManager.TapBottomSheetMinimumYPoint,initialHeight]
        while minStickyPoint < maxHeight {
            stickyPoints.append(minStickyPoint)
            minStickyPoint += 50
        }
        return stickyPoints
    }
    
    
    ///Computes the point the view will be moved to, and calculates the auto dismissal logic
    public override final func pullUpControllerWillMove(to point: CGFloat) {
       // print("POINT WILL MOVE TO : \(point) - With Frame \(self.view.frame.origin.y)")
        // Check if the new point is lower than the dismiss Y threshold
        if point <= ConstantManager.TapBottomSheetMinimumYPoint {
            dismissView()
        }
    }
    
    /// Will use this override method to always make sure the view is not dragged up beyond a certain Y limit
    public override final func pullUpControllerDidMove(to point: CGFloat) {
         // check if the new dragged to point passes the minimum Y, then assign it back to the minimum Y
        if self.view.frame.origin.y < ConstantManager.TapBottomSheetMinimumYPoint {
            // If yes, then we need to move it back to the minimum allowed Y point
            self.pullUpControllerMoveToVisiblePoint(point-ConstantManager.TapBottomSheetMinimumYPoint, animated: true, completion: nil)
        }
        
        // check if we need to inform the delegate about the new position we are in now
        guard let delegate = delegate else { return }
        delegate.tapBottomSheetHeightChanged(with: point)
    }
    
    
    private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc public func dismissTheController() {
        dismissView()
    }
    
    @objc public func changeHeight(to newHeight:CGFloat) {
        guard newHeight > minimumHeight && newHeight < (pullUpControllerAllStickyPoints.last ?? maxHeight) else { return }
        pullUpControllerMoveToVisiblePoint(newHeight, animated: true, completion: nil)
    }
}
