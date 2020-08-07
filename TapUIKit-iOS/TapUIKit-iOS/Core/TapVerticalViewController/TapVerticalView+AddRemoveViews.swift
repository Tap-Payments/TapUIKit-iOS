//
//  TapVerticalView+AddRemoveViews.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 8/7/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
/// Extension to the bottom sheet that contains all the logic required for adding and removing views fromt the sheet controller
extension TapVerticalView {
    
    /**
     Removes an arranged subview from the vertical hierarchy
     - Parameter view: The view to be deleted
     - Parameter animation: The animation to be applied while doing the view removal. Default is nil
     */
    public func remove(view:UIView, with animation:TapVerticalViewAnimationType? = nil) {
        handleDeletion(for: view, with: animation)
    }
    
    
    /**
     Removes an arranged subview from the vertical hierarchy
     - Parameter view: The view to be deleted
     - Parameter animation: The animation to be applied while doing the view removal. Default is nil
     - Parameter deleteAfterViews: If true, all views below the mentioned view will be deleted
     - Parameter skipSelf: If true, then the mentioned view WILL not be deleted and all views below the mentioned view will be deleted
     */
    public func remove(viewType:AnyClass, with animation:TapVerticalViewAnimationType? = nil, and deleteAfterViews:Bool = false,skipSelf:Bool = false) {
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
    public func remove(at index:Int, with animation:TapVerticalViewAnimationType? = nil) {
        let subViews = stackView.arrangedSubviews
        guard subViews.count > index else { return }
        
        handleDeletion(for: subViews[index], with: animation)
    }
    
    /**
     Removes a list of arranged subview from the vertical hierarchy
     - Parameter view: The views to be deleted
     - Parameter animation: The animation to be applied while doing the view removal. Default is nil
     */
    public func remove(views:[UIView], with animation:TapVerticalViewAnimationType? = nil) {
        views.forEach{ handleDeletion(for: $0, with: animation) }
    }
    
    
    /**
     Handles all the logic needed to remove an arranged subview from the vertical hierarchy
     - Parameter view: The view to be deleted
     - Parameter animation: The animation to be applied while doing the view removal. Default is nil
     */
    internal func handleDeletion(for view:UIView, with animation:TapVerticalViewAnimationType? = nil) {
        
        // Check if there is an animation we need to do
        guard let animation:TapVerticalViewAnimationType = animation, animation != .none  else {
            itemsBeingRemoved = false
            view.isHidden = true
            stackView.removeArrangedSubview(view)
            return
        }
        
        
        itemsBeingRemoved = true
        
        switch animation {
        case .bounceIn(let direction,_,_):
            view.bounceIn(from: direction.animationKitDirection(),completion: {_ in self.removeFromStackView(view:view)})
        case .bounceOut(let direction,_,_):
            view.bounceOut(to: direction.animationKitDirection(),completion: {_ in self.removeFromStackView(view:view)})
        case .fadeIn:
            view.fadeIn(completion: {_ in self.removeFromStackView(view:view)})
        case .fadeOut(let duration,_):
            view.fadeOut(duration:duration,completion: {_ in self.removeFromStackView(view:view)})
        case .slideIn(let direction,_,_):
            view.slideIn(from: direction.animationKitDirection(),completion: {_ in self.removeFromStackView(view:view)})
        case .slideOut(let direction,let duration,_):
            view.slideOut(to: direction.animationKitDirection(),duration:duration,completion: {_ in self.removeFromStackView(view:view)})
        case .popIn:
            view.popIn()
        case .popOut:
            view.popOut()
        case .none:
            break
        }
        
    }
    
    
    /**
     Adds an arranged subview to the vertical hierarchy at a certain position
     - Parameter view: The view to be added
     - Parameter index: The index to add the view in, skip to add at the end of the vertical heirarchy
     - Parameter animation: The animation to be applied while doing the view addition. Default is nil
     - Parameter shouldFillHeight: If true, then this view will expand the available height from the previous view to fill in the screen
     */
    public func add(view:UIView, at index:Int? = nil, with animations:[TapVerticalViewAnimationType] = [], and animationSequence:TapAnimationSequence = .serial, shouldFillHeight:Bool = false) {
        handleAddition(of: view, at: index,with: animations,and: animationSequence,shouldFillHeight: shouldFillHeight)
    }
    
    
    /**
     Adds an arranged subview to the vertical hierarchy at a certain position
     - Parameter views: The list of views to be added
     - Parameter animation: The animation to be applied while doing the view addition. Default is nil
     */
    public func add(views:[UIView], with animations:[TapVerticalViewAnimationType] = [], and animationSequence:TapAnimationSequence = .serial) {
        views.forEach{ handleAddition(of: $0, at: nil,with: animations,and: animationSequence,shouldFillHeight: false) }
    }
    
    
    /**
     Handles all the logic needed to add an arranged subview to the vertical hierarchy
     - Parameter view: The view to be added
     - Parameter index: The index to add the view in, skip to add at the end of the vertical heirarchy
     - Parameter animation: The animation to be applied while doing the view removal. Default is nil
     shouldFillHeight:Bool = false
     */
    private func handleAddition(of view:UIView, at index:Int? = nil, with animations:[TapVerticalViewAnimationType] = [], and animationSequence:TapAnimationSequence = .serial,shouldFillHeight:Bool = false) {
        
        // Check if should fill in max height, then set its height to the maxium availble
        if shouldFillHeight {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: getMaxAvailableHeight()).isActive = true
            view.layoutIfNeeded()
        }
        
        itemsBeingAdded += 1
        
        // If the index is not defined, then we just add it to the end
        if let index = index {
            stackView.insertArrangedSubview(view, at: index)
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
