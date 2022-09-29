//
//  TapVerticalView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/7/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

// import SimpleAnimation
import TapThemeManager2020
import TapCardScanner_iOS
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
    /// Displays the powered by tap footer
    @IBOutlet weak var powereByTapView: PoweredByTapView!
    /// Holds the last style theme applied
    private var lastUserInterfaceStyle:UIUserInterfaceStyle = .light
    /// This informs the sheet that we need to show bg as a blurring view
    @objc public var showBlur:Bool = false {
        didSet{
            applyTheme()
        }
    }
    private var newSizeTimer:Timer?
    /// Used to handle keyboard events and get the keyboard frame at run time
    private let keyboardHelper = KeyboardHelper()
    /// Used to hide show the action button
    @IBOutlet weak var tapActionButtonHeightConstraint: NSLayoutConstraint!
    /// Used to push and pull the whole views above the keybaod when it is shown or dimissed
    @IBOutlet weak var tapActionButtonBottomConstraint: NSLayoutConstraint!
    /// Reference to the tap action button
    @IBOutlet weak var tapActionButton: TapActionButton!
    /// Saves the current keyboard height when it is visible
    internal var keyboardPadding:CGFloat = 0
    /// Indicates if we need to wait until we perfom the change siz enotification so all views are correctly rendered, based on how old the device + how old the iOS.
    internal var delaySizeChange:Bool = true
    private var getGiftGestureRecognizer:UITapGestureRecognizer?
    
    /// Computes the needed bottom space margin including the button + the powered by tap view
    internal var neededBottomSpaceMargin:Double {
        return tapActionButtonHeightConstraint.constant + powereByTapView.frame.height
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    @objc private func scrollViewTouched() {
        endEditing(true)
        if let gesture = getGiftGestureRecognizer {
            scrollView.removeGestureRecognizer(gesture)
        }
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
        
        /// Adjust the stack view layout to fill in the super view
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
    /**
     Computes the needed size to show all the views inside the scroll view
     - Returns: The needed size to show all teh renered views + the action button size and keyboard padding if any
     */
    internal func neededSize() -> CGSize {
        var contentSize = scrollView.contentSize
        contentSize.height += neededBottomSpaceMargin
        return contentSize
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
            newSize.height += keyboardPadding + neededBottomSpaceMargin
            
            delegate?.innerSizeChanged?(to: newSize, with: frame)
        }
        
        delaySizeChange = true
        
        //publishNewContentSize(to: newSize, with: self.frame)
    }
    
    
    @objc private func publishNewContentSize(timer: Timer) {
        
        guard itemsBeingAdded == 0 else {
            
            // All good, time to animate the height :)
            newSizeTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(publishNewContentSize(timer:)), userInfo: timer.userInfo, repeats: false)
            return
            
        }
        
        guard let info:[String:Any] = timer.userInfo as? [String:Any],
              var newSize:CGSize = info["newSize"] as? CGSize,
              let frame:CGRect = info["newFrame"] as? CGRect else { return }
        
        newSize.height += keyboardPadding + neededBottomSpaceMargin
        
        delegate?.innerSizeChanged?(to: newSize, with: frame)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.frame = bounds
    }
    
    /**
     Use this method to tell the SDK if it needs to handle itself and deal with the keybord shown/dismissed events.
     - Parameter newStatus: If set, then SDK will deal with the keyboard events and pushes itself above the keyboard. If not set, then it is your responsibility to deal with this
     */
    @objc public func updateKeyBoardHandling(with newStatus:Bool = false) {
        if newStatus {
            // If we have to deal with it, then we listen to keboard shown and dismissed events and updates our UI accordingly
            keyboardHelper.onKeyboardWillBeShown = {[weak self] keyboardRect in
                // Add the tap gesture to the scroll view, so when the user clicks on the outside of the keyboard it will be dismissed
                self?.getGiftGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self?.scrollViewTouched))
                if let gesture = self?.getGiftGestureRecognizer {
                    self?.scrollView.removeGestureRecognizer(gesture)
                    self?.scrollView.addGestureRecognizer(gesture)
                }
                
                print("KEYBOARD SHOW : \(keyboardRect)")
                self?.addSpaceView(with: keyboardRect)
            }
            keyboardHelper.onKeyboardWillBeHidden = { [weak self] keyboardRect in
                // Remove the tap gesture
                if let gesture = self?.getGiftGestureRecognizer {
                    self?.scrollView.removeGestureRecognizer(gesture)
                }
                self?.removeAllHintViews()
                self?.removeSpaceView(with: keyboardRect)
            }
        }else{
            // If the user will deal with it. We deactivate listening to keyboard events
            // If we have to deal with it, then we listen to keboard shown and dismissed events and updates our UI accordingly
            keyboardHelper.onKeyboardWillBeShown = {[weak self] keyboardRect in
                // Add the tap gesture to the scroll view, so when the user clicks on the outside of the keyboard it will be dismissed
                self?.getGiftGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self?.scrollViewTouched))
                if let gesture = self?.getGiftGestureRecognizer {
                    self?.scrollView.removeGestureRecognizer(gesture)
                    self?.scrollView.addGestureRecognizer(gesture)
                }
            }
            keyboardHelper.onKeyboardWillBeHidden = { [weak self] keyboardRect in
                // Remove the tap gesture
                if let gesture = self?.getGiftGestureRecognizer {
                    self?.scrollView.removeGestureRecognizer(gesture)
                }
            }
        }
    }
    
    /**
     Internal helper method to change the amount section status
     - Parameter newStatus: The new amoutn section status to be assigned
     */
    func changeTapAmountSectionStatus(to newStatus:AmountSectionCurrentState) {
        // Make sure there is a valid Amount section rendered and visible on the screen..
        if let tapAmountSectionView:TapAmountSectionView = stackView.arrangedSubviews.filter({ $0.isKind(of: TapAmountSectionView.self) })[0] as? TapAmountSectionView {
            // If yes, then assign the new status to it
            tapAmountSectionView.viewModel?.screenChanged(to: newStatus)
        }
    }
    
    /**
     Calculates the max space that a view can be added in the sheet with respect to the current height of the views added + the maximum availble height given tor the sheet
     - Returns: The space that can be filled with respect to the crrent views heights + the maximum height the sheet can expand to
     */
    @objc public func getMaxAvailableHeight() -> CGFloat {
        // Calculate the current views' height firs
        var currentViewsHeight:CGFloat = 0
        stackView.arrangedSubviews.forEach{ currentViewsHeight += ($0.frame.height > 0) ? $0.frame.height : 45 }
        return TapConstantManager.maxAllowedHeight - currentViewsHeight
    }
    
    /**
     Deletes a certain view from with Fadeout animation from the stack view
     - Parameter view: The view to be deleted
     */
    internal func removeFromStackView(view:UIView) {
        view.fadeOut(duration:0)
        stackView.removeArrangedSubview(view)
        itemsBeingRemoved = false
    }
    
    internal func adjustAnimationList(view:UIView, for animations:[TapSheetAnimation], with sequence:TapAnimationSequence, then completion:@escaping () -> () = {  }) {
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
    
    internal func animate(view:UIView,with animation:TapSheetAnimation,after delay:TimeInterval = 0, and completion:@escaping () -> () = {  }) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(delay * 1000))) {
            animation.applyAnimation(to: view, with: completion)
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
}


/// Defines the type and the configuration of the needed animations
@objc public class TapSheetAnimation : NSObject {
    /// The duration required to performt the animation
    var duration:Double = TapConstantManager.TapAnimationDuration
    /// The delay before performing the animatijn
    var delay:Double = 0
    /// The direction to perform the animation from/to
    var direction:TapVerticalViewAnimationDirection = .bottom
    /// Which animation you want to perform
    var animation:TapVerticalViewAnimationType = .none
    
    /**
     Creates a new instance of tap sheet animation object
     - Parameter duration: The duration required to performt the animation, default is TapConstantManager.TapAnimationDuration
     - Parameter delay:  The delay before performing the animatijn, default is 0
     - Parameter direction: The direction to perform the animation from/to, default is bottom
     - Parameter animation: Which anumation you want to perform, default is none
     */
    @objc public init(for animation:TapVerticalViewAnimationType = .none, with duration:Double = TapConstantManager.TapAnimationDuration,and direction:TapVerticalViewAnimationDirection = .bottom, wait delay:Double = 0) {
        self.duration = duration
        self.direction = direction
        self.animation = animation
        self.delay = delay
    }
    
    /**
     An elegante way to get all the emebded info and data inside the Animation object
     - Returns: Tuble of (Animation direction, duration and delay)
     */
    internal func animationDetails() -> (TapVerticalViewAnimationDirection?,Double,Double) {
        return( (self.animation == .none) ? nil : self.direction,duration,delay)
    }
    
    /**
     Perfosm a correct animation with the needed attributes to the given the view
     - Parameter view: The UIView to perform the animation on
     - Parameter completion: The block to exeute after finishing the animation
     */
    internal func applyAnimation(to view:UIView, with completion:@escaping () -> () = {  }) {
        switch animation {
        case .bounceIn:
            view.bounceIn(from: direction.animationKitDirection(), duration:duration, delay:delay, completion: { _ in
                completion()
            })
        case .bounceOut:
            view.bounceOut(to: direction.animationKitDirection(), duration:duration, delay:delay, completion: { _ in
                completion()
            })
        case .fadeIn:
            view.fadeIn(duration:duration, delay:delay , completion: { _ in
                completion()
            })
        case .fadeOut:
            view.fadeOut(duration:duration, delay:delay , completion: { _ in
                completion()
            })
        case .slideIn:
            
            view.slideIn(from: direction.animationKitDirection(),x:0,y:400, duration:duration, delay:delay, completion: { _ in
                completion()
            })
        case .slideOut:
            view.slideOut(to: direction.animationKitDirection(), duration:duration, delay:delay, completion: { _ in
                completion()
            })
        case .popIn:
            view.popIn(duration:duration, delay:delay, completion: { _ in
                completion()
            })
        case .popOut:
            view.popOut(duration:duration, delay:delay, completion: { _ in
                completion()
            })
        case .none:
            completion()
            break
        }
    }
}

/// Defines the animation type
@objc public enum TapVerticalViewAnimationType: Int {
    case bounceIn = 1
    case bounceOut = 2
    case slideIn = 3
    case slideOut = 4
    case fadeIn = 5
    case fadeOut = 6
    case popIn = 7
    case popOut = 8
    case none = 9
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
