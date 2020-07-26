//
//  TapVerticalView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/7/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import SimpleAnimation
import TapThemeManager2020

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
@objc public class TapVerticalView: UIView {
    
    /// The stackview which is used as the backbone for laying out the views in a vertical fashion
    @IBOutlet internal var stackView: UIStackView!
    /// The scroll view which wraps the stackview to provide the scrollability whenever needed
    @IBOutlet internal weak var scrollView: UIScrollView!
    /// The main view loaded from the Xib
    @IBOutlet internal weak var containerView: UIView!
    /// Used to determine if we need to delay any coming view addition requests to wait until the items being removed to finish the animation first:)
    internal var itemsBeingRemoved:Bool = false
    internal var itemsBeingAdded:Int = 0
    /// This is the delegate variable you need to subscripe to whenver you want to listen to updates from this view
    @objc public var delegate:TapVerticalViewDelegate?
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// This informs the sheet that we need to show bg as a blurring view
    @objc public var showBlur:Bool = false {
        didSet{
            applyTheme()
        }
    }
    private var newSizeTimer:Timer?
    private let keyboardHelper = KeyboardHelper()
    @IBOutlet weak var tapActionButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tapActionButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tapActionButton: TapActionButton!
    
    internal var keyboardPadding:CGFloat = 0
    internal var delaySizeChange:Bool = true
    
    
    
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
        dismissKey()
        applyTheme()
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
    
    
    /**
     Setup the tap action button and attach it to the view model
     - Parameter viewModel: The tap action button view model that will control the tap action button
     */
    public func setupActionButton(with viewModel:TapActionButtonViewModel) {
        tapActionButton.setup(with: viewModel)
    }
    
    internal func neededSize() -> CGSize {
        var contentSize = scrollView.contentSize
        contentSize.height += tapActionButtonHeightConstraint.constant
        return contentSize
    }
    
    
    /// Shows the action button fade in + height increase
    public func showActionButton() {
        tapActionButton.fadeIn()
        tapActionButtonHeightConstraint.constant = 74
        tapActionButton.updateConstraints()
        layoutIfNeeded()
    }
    
    /// Hide the action button fade out + height decrease
    public func hideActionButton() {
        tapActionButtonHeightConstraint.constant = 0
        tapActionButton.updateConstraints()
        layoutIfNeeded()
    }
    
    
    
    
    /// It is overriden to listen to the change in size of the scroll view
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Make sure this is the notfication we want to listen to which is the contentSize of the scroll view
        guard let keyPath = keyPath, keyPath == "contentSize", object as? UIScrollView == scrollView, let _ = delegate else { return }
        // Make sure the new heigt is not 0
        guard scrollView.contentSize.height > 0 else { return }
        // Inform the delegate if any, that the view has new size
        // Take in consideration the safe margins :)
        /*var bottomPadding:CGFloat = 0.0
        if let window = UIApplication.shared.keyWindow {
            bottomPadding = window.safeAreaInsets.bottom
        }*/
        let contentSize = scrollView.contentSize
        var newSize = contentSize
        //newSize.height += bottomPadding
        //delegate.innerSizeChanged?(to: newSize, with: self.frame)
        if let timer = newSizeTimer {
            timer.invalidate()
        }
        // All good, time to animate the height :)
        if delaySizeChange {
            newSizeTimer = Timer.scheduledTimer(timeInterval: 0.1 , target: self, selector: #selector(publishNewContentSize(timer:)), userInfo: ["newSize":newSize,"newFrame":self.frame], repeats: false)
        }else {
            newSize.height += keyboardPadding + tapActionButtonHeightConstraint.constant
            
            delegate?.innerSizeChanged?(to: newSize, with: frame)
        }
        
        delaySizeChange = true
        
        //publishNewContentSize(to: newSize, with: self.frame)
    }
    
    
    @objc private func publishNewContentSize(timer: Timer) {//to newSize:CGSize, with frame:CGRect) {
        
        guard itemsBeingAdded == 0 else {
            
            // All good, time to animate the height :)
            newSizeTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(publishNewContentSize(timer:)), userInfo: timer.userInfo, repeats: false)
            return
            
        }
        
        guard let info:[String:Any] = timer.userInfo as? [String:Any],
              var newSize:CGSize = info["newSize"] as? CGSize,
              let frame:CGRect = info["newFrame"] as? CGRect else { return }
        
        newSize.height += keyboardPadding + tapActionButtonHeightConstraint.constant
        
        delegate?.innerSizeChanged?(to: newSize, with: frame)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
    
    
    @objc public func updateKeyBoardHandling(with newStatus:Bool = false) {
        if newStatus {
            keyboardHelper.onKeyboardWillBeShown = {[weak self] keyboardRect in
                print("KEYBOARD SHOW : \(keyboardRect)")
                self?.addKeyboardSpaceView(with: keyboardRect)
            }
            keyboardHelper.onKeyboardWillBeHidden = { [weak self] keyboardRect in
                self?.removeAllHintViews()
                self?.removeKeyboardSpaceView(with: keyboardRect)
            }
        }else{
            keyboardHelper.onKeyboardWillBeShown = nil
            keyboardHelper.onKeyboardWillBeHidden = nil
        }
    }
    
    internal func addKeyboardSpaceView(with keyboardRect:CGRect) {
        tapActionButtonBottomConstraint.constant = keyboardRect.height
       
        keyboardPadding = keyboardRect.height
        
        var currentContentSize = scrollView.contentSize
        currentContentSize.height -= 1
        
        
        UIView.animate(withDuration: 0.25, animations: {
            self.tapActionButton.updateConstraints()
            //scrollView.layoutIfNeeded()
            self.layoutIfNeeded()
        }) { _ in
            
        }
        
        self.delaySizeChange = false
        self.scrollView.contentSize = currentContentSize
    }
    
    internal func removeKeyboardSpaceView(with keyboardRect:CGRect) {
        
        
        tapActionButtonBottomConstraint.constant = 0
        
        keyboardPadding = 0
        
        var currentContentSize = scrollView.contentSize
        currentContentSize.height -= 1
        
        
        UIView.animate(withDuration: 0.25, animations: {
            self.tapActionButton.updateConstraints()
            //scrollView.layoutIfNeeded()
            self.layoutIfNeeded()
        }) { _ in
            
        }
        
        self.delaySizeChange = false
        self.scrollView.contentSize = currentContentSize
        
        
        
        /*DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            
            self.keyboardPadding = 0
            var currentContentSize = self.scrollView.contentSize
            currentContentSize.height += 1
            self.scrollView.contentSize = currentContentSize
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.tapActionButtonBottomConstraint.constant = 0
                self.tapActionButton.updateConstraints()
                self.scrollView.layoutIfNeeded()
            }
        }*/
       
    }
    
    internal func addSpaceView(with keyboardRect:CGRect) {
        removeSpaceViews()
        let space:SpaceView = .init()
        space.backgroundColor = .clear
        space.translatesAutoresizingMaskIntoConstraints = false
        space.heightAnchor.constraint(equalToConstant: keyboardRect.height).isActive = true
        add(view: space, with: [.none])
    }
    
    internal func removeSpaceViews() {
        let spaceViews:[SpaceView] = stackView.arrangedSubviews.filter{ $0.isKind(of: SpaceView.self) } as? [SpaceView] ?? []
        guard spaceViews.count > 0 else { return }
        spaceViews.forEach { spaceView in
            remove(view: spaceView, with: TapVerticalViewAnimationType.none)
        }
    }
    
    /**
     Removes an arranged subview from the vertical hierarchy
     - Parameter view: The view to be deleted
     - Parameter animation: The animation to be applied while doing the view removal. Default is nil
     */
    public func remove(view:UIView, with animation:TapVerticalViewAnimationType? = nil) {
        handleDeletion(for: view, with: animation)
    }
    
    @objc public func getMaxAvailableHeight() -> CGFloat {
        var currentViewsHeight:CGFloat = 0
        stackView.arrangedSubviews.forEach{ currentViewsHeight += ($0.frame.height > 0) ? $0.frame.height : 45 }
        return TapConstantManager.maxAllowedHeight - currentViewsHeight
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
    
    
    private func removeFromStackView(view:UIView) {
        view.fadeOut(duration:0)
        stackView.removeArrangedSubview(view)
        itemsBeingRemoved = false
    }
    
    
    /**
     Adds a hint view below a given view
     - Parameter hintView: The hint view to be added
     - Parameter to: The type of the view you want to show the hint below it
     - Parameter animations: A boolean to indicate whether you want to show the hint with animation or right away
     */
    
    @objc public func attach(hintView:TapHintView,to:AnyClass,with animations:Bool = false) {
        // First we remove all hints
        removeAllHintViews()
        // Then we check that there is already a view with the passed type
        let filteredViews:[UIView] = stackView.arrangedSubviews.filter{ $0.isKind(of: to) }
        guard  filteredViews.count > 0 else { return }
        
        // Fetch the index of the view we will attach the hint
        guard let attachToViewIndex:Int = stackView.arrangedSubviews.firstIndex(of: filteredViews[0]) else { return }
        // All good now we can add, but let us determine the animations first
        let requiredAnimations:[TapVerticalViewAnimationType] = animations ? [.fadeIn()] : []
        // Insert at the hint view at the correct index
        if attachToViewIndex == stackView.arrangedSubviews.count - 1 {
            // The attaching to view is already the last element, hence we add at the end normally as we usually do
            add(view: hintView, with: requiredAnimations)
        }else {
            add(view: hintView,at: (attachToViewIndex+1), with: requiredAnimations)
        }
    }
    
    
    @objc public func removeAllHintViews() {
        let hintViews:[TapHintView] = stackView.arrangedSubviews.filter{ $0.isKind(of: TapHintView.self) } as? [TapHintView] ?? []
        guard hintViews.count > 0 else { return }
        hintViews.forEach { hintView in
            remove(view: hintView, with: TapVerticalViewAnimationType.none)
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
    
    
    
    private func adjustAnimationList(view:UIView, for animations:[TapVerticalViewAnimationType], with sequence:TapAnimationSequence, then completion:@escaping () -> () = {  }) {
        // Create mutable instance of the animation list to be able to change the required values
        var delayUpToCurrentAnimation:Double = 0
        
        // We start from 1 as first animation will be executed at first regarldess the sequence type. Also, last one will be called separatly as it is the one that will fire the completion block whether in parallel or in serial
        animate(view: view, with: animations[0],after: 0)
        for i in 1..<animations.count {
            let animation = animations[i]
            let (_,previousDuration,previousDelay) = animations[i-1].animationDetails()
            // Update the delayed value for this current animation (will use it in case of sequence animation required)
            delayUpToCurrentAnimation += (previousDuration + previousDelay)
            // Determine we will pass the delay or not, we will only use the delaf IFF the sequence is serial, hence, the delay will make the current animation waits for the previous ones to finish first.
            let toBeUsedDelay = (sequence == .serial) ? delayUpToCurrentAnimation : 0
            // Only the last animation should fire the completion block, hence we need to check whether will fire it or not for this animation
            let completionBlock:() -> () = (animation == animations.last) ? completion : { }
            animate(view: view, with: animation,after: toBeUsedDelay, and: completionBlock)
        }
        
        
        // Now we will fire the last animation in the sequence and pass the completion block
        
    }
    
    private func animate(view:UIView,with animation:TapVerticalViewAnimationType,after delay:TimeInterval = 0, and completion:@escaping () -> () = {  }) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(delay * 1000))) {
            switch animation {
            case .bounceIn(let direction,let duration,let delay):
                view.bounceIn(from: direction.animationKitDirection(), duration:duration, delay:delay, completion: { _ in
                    completion()
                })
            case .bounceOut(let direction,let duration,let delay):
                view.bounceOut(to: direction.animationKitDirection(), duration:duration, delay:delay, completion: { _ in
                    completion()
                })
            case .fadeIn(let duration,let delay):
                view.fadeIn(duration:duration, delay:delay , completion: { _ in
                    completion()
                })
            case .fadeOut(let duration,let delay):
                view.fadeOut(duration:duration, delay:delay , completion: { _ in
                    completion()
                })
            case .slideIn(let direction,let duration,let delay):
                view.slideIn(from: direction.animationKitDirection(),x:0,y:400, duration:duration, delay:delay, completion: { _ in
                    completion()
                })
            case .slideOut(let direction,let duration,let delay):
                view.slideOut(to: direction.animationKitDirection(), duration:duration, delay:delay, completion: { _ in
                    completion()
                })
            case .popIn(let duration,let delay):
                view.popIn(duration:duration, delay:delay, completion: { _ in
                    completion()
                })
            case .popOut(let duration,let delay):
                view.popOut(duration:duration, delay:delay, completion: { _ in
                    completion()
                })
            case .none:
                completion()
                break
            }
        }
    }
    
    /**
     Updates the list of vertical arranged views and adjusts it to match a list of given views.
     - Parameter newView: The list of the new views to be shown in the vertical hierarchy
     - Parameter animationSequence: Determine what animation's sequence to apply for views removals and additions. Default is performing both in parallel
     */
    @objc public func updateSubViews(with newViews:[UIView],and animationSequence:TapVerticalUpdatesAnimationSequence = .parallel) {
        
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
        
        let delay:Double =  250 * Double((toBeAddedViews.count ))
        
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
            for (_, newView) in subViews.enumerated() {
                if animationSequence != .none {
                    newView.slideIn(from: .bottom)
                }
                /*let oldIndex = self?.stackView.arrangedSubviews.firstIndex(of: newView)
                if oldIndex != newIndex {
                    self?.stackView.removeArrangedSubview(newView)
                    self?.stackView.insertArrangedSubview(newView, at: newIndex)
                    if animationSequence != .none {
                        newView.bounceIn(from: .bottom)
                    }
                }*/
            }
        }
    }
}

/// Defines the type and the configuration of the needed animations
public enum TapVerticalViewAnimationType: Equatable {
    case bounceIn(TapVerticalViewAnimationDirection,duration:Double = TapConstantManager.TapAnimationDuration, delay:Double = 0)
    case bounceOut(TapVerticalViewAnimationDirection,duration:Double = TapConstantManager.TapAnimationDuration, delay:Double = 0)
    case slideIn(TapVerticalViewAnimationDirection,duration:Double = TapConstantManager.TapAnimationDuration, delay:Double = 0)
    case slideOut(TapVerticalViewAnimationDirection,duration:Double = TapConstantManager.TapAnimationDuration, delay:Double = 0)
    case fadeIn(duration:Double = TapConstantManager.TapAnimationDuration, delay:Double = 0)
    case fadeOut(duration:Double = TapConstantManager.TapAnimationDuration, delay:Double = 0)
    case popIn(duration:Double = TapConstantManager.TapAnimationDuration, delay:Double = 0)
    case popOut(duration:Double = TapConstantManager.TapAnimationDuration, delay:Double = 0)
    case none
    
    internal func animationDetails() -> (TapVerticalViewAnimationDirection?,Double,Double) {
        var detectedDirection:TapVerticalViewAnimationDirection? = nil
        var detectedDuration:Double = TapConstantManager.TapAnimationDuration
        var detectedDelay:Double = 0
        switch self {
        case .bounceIn(let direction,let duration,let delay), .bounceOut(let direction,let duration,let delay), .slideIn(let direction,let duration,let delay), .slideOut(let direction,let duration,let delay):
            detectedDirection = direction
            detectedDuration = duration
            detectedDelay = delay
        case .fadeIn(let duration,let delay), .fadeOut(let duration,let delay), .popIn(let duration,let delay), .popOut(let duration,let delay):
            detectedDirection = nil
            detectedDuration = duration
            detectedDelay = delay
        case .none:
            detectedDirection = nil
            detectedDuration = 0
            detectedDelay = 0
            break
        }
        return(detectedDirection,detectedDuration,detectedDelay)
    }
}



/// Defines the direction the animation will be applied to
@objc public enum TapVerticalViewAnimationDirection:Int {
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
@objc public enum TapVerticalUpdatesAnimationSequence:Int {
    /// Do nothing
    case none
    /// Animate removals and additions in parallel
    case parallel
    /// Animate removals first, then animate the additions
    case removeAllFirst
}



/// Defines what sequence to apply when removing and adding set of views to the vertical hierarchy
@objc public enum TapAnimationSequence:Int {
    /// Perform the animations one after another
    case serial
    /// Perofm the animations all togethe
    case parallel
}



extension TapVerticalView {
    func dismissKey()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard()
    {
        //endEditing(true)
    }
}

extension TapVerticalView {
    func applyTheme() {
        tap_theme_backgroundColor = .init(keyPath: "TapVerticalView.\(showBlur ? "blurBackgroundColor" : "defaultBackgroundColor")")
    }
    
    /// Listen to light/dark mde changes and apply the correct theme based on the new style
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TapThemeManager.changeThemeDisplay(for: self.traitCollection.userInterfaceStyle)
        
        guard lastUserInterfaceStyle != self.traitCollection.userInterfaceStyle else {
            return
        }
        lastUserInterfaceStyle = self.traitCollection.userInterfaceStyle
        applyTheme()
    }
}
