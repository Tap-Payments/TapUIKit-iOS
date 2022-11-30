//
//  TapVerticalView+AddRemoveViews.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 8/7/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import LocalisationManagerKit_iOS
/// Extension to the bottom sheet that contains all the logic required for adding and removing views fromt the sheet controller
extension TapVerticalView {
    
    /**
     Removes an arranged subview from the vertical hierarchy
     - Parameter view: The view to be deleted
     - Parameter animation: The animation to be applied while doing the view removal. Default is nil
     */
    public func remove(view:UIView, with animation:TapSheetAnimation? = nil) {
        handleDeletion(for: view, with: animation)
    }
    
    
    /**
     Removes an arranged subview from the vertical hierarchy
     - Parameter view: The view to be deleted
     - Parameter animation: The animation to be applied while doing the view removal. Default is nil
     - Parameter deleteAfterViews: If true, all views below the mentioned view will be deleted
     - Parameter skipSelf: If true, then the mentioned view WILL not be deleted and all views below the mentioned view will be deleted
     */
    public func remove(viewType:AnyClass, with animation:TapSheetAnimation? = nil, and deleteAfterViews:Bool = false,skipSelf:Bool = false) {
        // This will declare if we need to remove the current view in the loop iteration
        var shallDeleteView:Bool = false
        // List of views to be deleted afterwards
        var toBeDeletedViews:[UIView] = []
        stackView.arrangedSubviews.forEach { arrangedView in
            // Check if the current view class type is the same as the required class
            if arrangedView.isKind(of: viewType) {
                if !skipSelf {
                    toBeDeletedViews.append(arrangedView)
                }
                // Check if the user wants o deleted the views below it
                if deleteAfterViews {
                    shallDeleteView = true
                }
            } else if shallDeleteView {
                toBeDeletedViews.append(arrangedView)
            }
        }
        // Time to remove all the grabbed views
        remove(views: toBeDeletedViews, with: animation)
    }
    
    /**
     Removes an arranged subview from the vertical hierarchy
     - Parameter index: The index of the view to be deleted
     - Parameter animation: The animation to be applied while doing the view removal. Default is nil
     */
    public func remove(at index:Int, with animation:TapSheetAnimation? = nil) {
        let subViews = stackView.arrangedSubviews
        guard subViews.count > index else { return }
        
        handleDeletion(for: subViews[index], with: animation)
    }
    
    /**
     Removes a list of arranged subview from the vertical hierarchy
     - Parameter view: The views to be deleted
     - Parameter animation: The animation to be applied while doing the view removal. Default is nil
     */
    public func remove(views:[UIView], with animation:TapSheetAnimation? = nil) {
        views.forEach{ handleDeletion(for: $0, with: animation) }
    }
    
    
    /**
     Handles all the logic needed to remove an arranged subview from the vertical hierarchy
     - Parameter view: The view to be deleted
     - Parameter animation: The animation to be applied while doing the view removal. Default is nil
     */
    internal func handleDeletion(for view:UIView, with animation:TapSheetAnimation? = nil) {
        
        // Check if there is an animation we need to do
        guard let animation:TapSheetAnimation = animation, animation.animation != .none  else {
            itemsBeingRemoved = false
            view.isHidden = true
            stackView.removeArrangedSubview(view)
            return
        }
        
        
        itemsBeingRemoved = true
        
        animation.applyAnimation(to: view) {self.removeFromStackView(view:view)}
    }
    
    
    /**
     Adds an arranged subview to the vertical hierarchy at a certain position
     - Parameter view: The view to be added
     - Parameter index: The index to add the view in, skip to add at the end of the vertical heirarchy
     - Parameter animation: The animation to be applied while doing the view addition. Default is nil
     - Parameter shouldFillHeight: If true, then this view will expand the available height from the previous view to fill in the screen
     */
    public func add(view:UIView, at index:Int? = nil, with animations:[TapSheetAnimation] = [], and animationSequence:TapAnimationSequence = .serial, shouldFillHeight:Bool = false) {
        handleAddition(of: view, at: index,with: animations,and: animationSequence,shouldFillHeight: shouldFillHeight)
    }
    
    
    /**
     Adds an arranged subview to the vertical hierarchy at a certain position
     - Parameter views: The list of views to be added
     - Parameter animation: The animation to be applied while doing the view addition. Default is nil
     */
    public func add(views:[UIView], with animations:[TapSheetAnimation] = [], and animationSequence:TapAnimationSequence = .serial, shouldScrollToBottom:Bool = false) {
        // Filter out the sections that shouldn't be visible
        views.filter{$0.shouldShowTapView()}.forEach{ handleAddition(of: $0, at: nil,with: animations,and: animationSequence,shouldFillHeight: false, shouldScrollToBottom: shouldScrollToBottom) }
    }
    
    
    /**
     Handles all the logic needed to add an arranged subview to the vertical hierarchy
     - Parameter view: The view to be added
     - Parameter index: The index to add the view in, skip to add at the end of the vertical heirarchy
     - Parameter animation: The animation to be applied while doing the view removal. Default is nil
     shouldFillHeight:Bool = false
     */
    private func handleAddition(of view:UIView, at index:Int? = nil, with animations:[TapSheetAnimation] = [], and animationSequence:TapAnimationSequence = .serial,shouldFillHeight:Bool = false, shouldScrollToBottom:Bool = false) {
        
        // Check if should fill in max height, then set its height to the maxium availble
        if shouldFillHeight {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: getMaxAvailableHeight()).isActive = true
            view.layoutIfNeeded()
        }
        
        if let horizontalList:TapChipHorizontalList = view as? TapChipHorizontalList, TapLocalisationManager.shared.localisationLocale ?? "en" == "ar" {
            let horizontalListViewModel = horizontalList.viewModel
            let delay:Int = 200//Int((self!.fadeInAnimationDuration - 0.5) * 1000)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {
                horizontalListViewModel.refreshLayout()
            }
        }
        
        itemsBeingAdded += 1
        
        // If the index is not defined, then we just add it to the end
        if let index = index {
            stackView.insertArrangedSubview(view, at: index)
            view.layoutIfNeeded()
        }else{
            stackView.addArrangedSubview(view)
        }
        
        DispatchQueue.main.async { [weak self] in
            
            
            // Make sure there are some animations passed
            guard animations.count > 0 else {
                self?.itemsBeingAdded -= 1
                return
            }
            // We need to apply the animations passed to the passed view with the required sequence
            view.alpha = 0
            // First case, we have only 1 animation then the sequence will not differ whether serial or parallel
            guard animations.count > 1 else {
                self?.animate(view: view, with: animations[0],and:{
                    self?.itemsBeingAdded -= 1
                })
                return
            }
            
            // Second case, we have more than 1 animation, hence we need to consider the sequence type
            self?.adjustAnimationList(view: view, for: animations, with: animationSequence,then: {
                self?.itemsBeingAdded -= 1
            })
        }
        
        if shouldScrollToBottom {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
                self?.scrollView.tap_scrollToBottom(animated: true)
            }
        }
        
    }
    
    /**
     Adds a list of arranged subview from the vertical hierarchy
     - Parameter view: The views to be added
     - Parameter animation: The animation to be applied while doing the view removal. Default is nil
     - Parameter delay: If requied a delay before starting adding the views
     */
    func add(subViews:[UIView], animationSequence:TapVerticalUpdatesAnimationSequence, delay:Int = 0) {
        // STart adding after the passed duration
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) { [weak self] in
            // For each view, add it first to the stack
            subViews.forEach{self?.stackView.addArrangedSubview($0)}
            // Make sure they are of the same order now!
            // Perform teh animation
            for (_, newView) in subViews.enumerated() {
                if animationSequence != .none {
                    newView.slideIn(from: .bottom)
                }
            }
        }
    }
}
