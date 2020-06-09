//
//  TapVerticalView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/7/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import SimpleAnimation

/// The protocol for the delegates and notifications fired from the TapVerticalView
@objc public protocol TapVerticalViewDelegate {
    /**
     Fired when the inner content size of the scroll view size has been changed due to adding and/or removing subviews
     - Parameter newSize: The new size after the sub views updates
     - Parameter frame: The frame of the TapVerticalView with respect to its superview
     */
    @objc optional func innerSizeChanged(to newSize:CGSize, with frame:CGRect)
}

/// The Tap wrapper view for having a dynamic height sizing scrollable vertical subview
public class TapVerticalView: UIView {
    
    /// The stackview which is used as the backbone for laying out the views in a vertical fashion
    @IBOutlet internal var stackView: UIStackView!
    /// The scroll view which wraps the stackview to provide the scrollability whenever needed
    @IBOutlet internal weak var scrollView: UIScrollView!
    /// The main view loaded from the Xib
    @IBOutlet internal weak var containerView: UIView!
    
    /// This is the delegate variable you need to subscripe to whenver you want to listen to updates from this view
    public var delegate:TapVerticalViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        self.containerView = setupXIB()
        setupStackScrollView()
    }
    
    
    /// Configure the scroll view and stack view constraints and attach the scrolling view inner content to the stack view
    private func setupStackScrollView() {
        // Add the observer to listen to changes in the content size of the scroll view, this will be affected by updating the subviews of the stackview
        scrollView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        scrollView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    /// It is overriden to listen to the change in size of the scroll view
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Make sure this is the notfication we want to listen to which is the contentSize of the scroll view
        guard let keyPath = keyPath, keyPath == "contentSize", object as? UIScrollView == scrollView, let delegate = delegate else { return }
        // Make sure the new heigt is not 0
        guard scrollView.contentSize.height > 0 else { return }
        // Inform the delegate if any, that the view has new size
        delegate.innerSizeChanged?(to: scrollView.contentSize, with: self.frame)
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
    
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
     - Parameter index: The index of the view to be deleted
     - Parameter animation: The animation to be applied while doing the view removal. Default is nil
     */
    public func remove(at index:Int, with animation:TapVerticalViewAnimationType? = nil) {
        let subViews = stackView.arrangedSubviews
        guard subViews.count > index else { return }
        
        handleDeletion(for: subViews[index], with: animation)
    }
    
    /**
     Handles all the logic needed to remove an arranged subview from the vertical hierarchy
     - Parameter view: The view to be deleted
     - Parameter animation: The animation to be applied while doing the view removal. Default is nil
     */
    private func handleDeletion(for view:UIView, with animation:TapVerticalViewAnimationType? = nil) {
        
        // Check if there is an animation we need to do
        guard let animation = animation else {
            stackView.removeArrangedSubview(view)
            return
        }
        
        switch animation {
        case .bounceIn(let direction,_,_):
            view.bounceIn(from: direction.animationKitDirection(),completion: {_ in self.stackView.removeArrangedSubview(view)})
        case .bounceOut(let direction,_,_):
            view.bounceOut(to: direction.animationKitDirection(),completion: {_ in self.stackView.removeArrangedSubview(view)})
        case .fadeIn:
            view.fadeIn(completion: {_ in self.stackView.removeArrangedSubview(view)})
        case .fadeOut:
            view.fadeOut(completion: {_ in self.stackView.removeArrangedSubview(view)})
        case .slideIn(let direction,_,_):
            view.slideIn(from: direction.animationKitDirection(),completion: {_ in self.stackView.removeArrangedSubview(view)})
        case .slideOut(let direction,_,_):
            view.slideOut(to: direction.animationKitDirection(),completion: {_ in self.stackView.removeArrangedSubview(view)})
        case .popIn:
            view.popIn()
        case .popOut:
            view.popOut()
        }
        
    }
    
    /**
     Adds an arranged subview to the vertical hierarchy at a certain position
     - Parameter view: The view to be added
     - Parameter index: The index to add the view in, skip to add at the end of the vertical heirarchy
     - Parameter animation: The animation to be applied while doing the view addition. Default is nil
     */
    public func add(view:UIView, at index:Int? = nil, with animation:TapVerticalViewAnimationType? = nil) {
        handleAddition(of: view, at: index,with: animation)
    }
    /**
     Handles all the logic needed to add an arranged subview to the vertical hierarchy
     - Parameter view: The view to be added
     - Parameter index: The index to add the view in, skip to add at the end of the vertical heirarchy
     - Parameter animation: The animation to be applied while doing the view removal. Default is nil
     */
    private func handleAddition(of view:UIView, at index:Int? = nil, with animation:TapVerticalViewAnimationType? = nil) {
        // If the index is not defined, then we just add it to the end
        if let index = index {
            stackView.insertArrangedSubview(view, at: index)
        }else{
            stackView.addArrangedSubview(view)
        }
        
        // Check if there is an animation we need to do
        guard let animation = animation else { return }
        
        switch animation {
            case .bounceIn(let direction,_,_):
                view.bounceIn(from: direction.animationKitDirection())
            case .bounceOut(let direction,_,_):
                view.bounceOut(to: direction.animationKitDirection())
            case .fadeIn:
                view.fadeIn()
            case .fadeOut:
                view.fadeOut()
            case .slideIn(let direction,_,_):
                view.slideIn(from: direction.animationKitDirection())
            case .slideOut(let direction,_,_):
                view.slideOut(to: direction.animationKitDirection())
            case .popIn:
                view.popIn()
            case .popOut:
                view.popOut()
        }
    }
    
    /**
     Updates the list of vertical arranged views and adjusts it to match a list of given views.
     - Parameter newView: The list of the new views to be shown in the vertical hierarchy
     - Parameter animationSequence: Determine what animation's sequence to apply for views removals and additions. Default is performing both in parallel
     */
    public func updateSubViews(with newViews:[UIView],and animationSequence:TapVerticalUpdatesAnimationSequence = .parallel) {
        
        var toBeRemovedViews:[UIView] = []
        var toBeAddedViews:[UIView] = []
        
        // Check which views we will delete, which doesn't exist in the new views list
        stackView.arrangedSubviews.forEach { currentSubview in
            if !newViews.contains(currentSubview) {
                toBeRemovedViews.append(currentSubview)
            }
        }
        
        // Check which views we will add, which exists only in the new views list
        newViews.forEach { newSubview in
            if !stackView.arrangedSubviews.contains(newSubview) {
                toBeAddedViews.append(newSubview)
            }
        }
        
        // Delete and add the calculated views
        remove(subViews: toBeRemovedViews, animationSequence: animationSequence)
        
        let delay:Double =  500
        
        // Add and sort the new views to be added
        add(subViews: toBeAddedViews, animationSequence: animationSequence, delay: Int((animationSequence == .none || animationSequence == .parallel) ? 0 : delay))
    }
    
    private func remove(subViews:[UIView], animationSequence:TapVerticalUpdatesAnimationSequence) {
        if animationSequence == .none {
            subViews.forEach{stackView.removeArrangedSubview($0)}
        }else {
            subViews.forEach{ subView in
                subView.fadeOut{ [weak self] _ in
                    self?.stackView.removeArrangedSubview(subView)
                }
            }
        }
    }
    
    private func add(subViews:[UIView], animationSequence:TapVerticalUpdatesAnimationSequence, delay:Int = 0) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) { [weak self] in
            subViews.forEach{self?.stackView.addArrangedSubview($0)}
            // Make sure they are of the same order now!
            for (newIndex, newView) in subViews.enumerated() {
                
                let oldIndex = self?.stackView.arrangedSubviews.firstIndex(of: newView)
                if oldIndex != newIndex {
                    self?.stackView.removeArrangedSubview(newView)
                    self?.stackView.insertArrangedSubview(newView, at: newIndex)
                    if animationSequence != .none {
                        newView.bounceIn(from: .bottom)
                    }
                }
            }
        }
    }
}

/// Defines the type and the configuration of the needed animations
public enum TapVerticalViewAnimationType {
    case bounceIn(TapVerticalViewAnimationDirection,duration:Double?,delay:Double?)
    case bounceOut(TapVerticalViewAnimationDirection,duration:Double?,delay:Double?)
    case slideIn(TapVerticalViewAnimationDirection,duration:Double?,delay:Double?)
    case slideOut(TapVerticalViewAnimationDirection,duration:Double?,delay:Double?)
    case fadeIn(duration:Double?,delay:Double?)
    case fadeOut(duration:Double?,delay:Double?)
    case popIn(duration:Double?,delay:Double?)
    case popOut(duration:Double?,delay:Double?)
}

/// Defines the direction the animation will be applied to
public enum TapVerticalViewAnimationDirection {
    case left
    case right
    case bottom
    case top
    
    
    internal func animationKitDirection() -> SimpleAnimationEdge {
        switch self {
        case .left:
            return .left
        case .right:
            return .right
        case .bottom:
            return .bottom
        case .top:
            return .top
        }
    }
}

/// Defines what sequence to apply when removing and adding set of views to the vertical hierarchy
public enum TapVerticalUpdatesAnimationSequence {
    /// Do nothing
    case none
    /// Animate removals and additions in parallel
    case parallel
    /// Animate removals first, then animate the additions
    case removeAllFirst
}


