//
//  TapVerticalView.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/7/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import SimpleAnimation
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
     Handles showing the GoPay sign in form by removing non required and adding required views
     - Parameter delegate: The delegate that will listen to the events fired from the GoPay sign in view/ viewmodel
     - Parameter goPayBarViewModel: The view model that will control the goPay sign view
     */
    public func showGoPaySignInForm(with delegate:TapGoPaySignInViewProtocol,and goPayBarViewModel:TapGoPayLoginBarViewModel) {
        // First declare the button state
        tapActionButton.viewModel?.buttonStatus = .InvalidNext
        
        // Create the GoPay sign in view and assign the delegate
        let signGoPayView:TapGoPaySignInView = .init()
        signGoPayView.delegate = delegate
        signGoPayView.backgroundColor = .clear
        
        // Attach the view model to th just created view
        signGoPayView.setup(with: goPayBarViewModel)
        
        // Inform the amount section that now we are showing the gopay view, hence it changes the title and the action of the amount's action button
        changeTapAmountSectionStatus(to: .GoPayView)
        
        endEditing(true)
        // Remove from the stack view all the non needed view to prepare for showing the goPay sign in view
        remove(viewType: TapChipHorizontalList.self, with: TapVerticalViewAnimationType.none, and: true)
        DispatchQueue.main.async{ [weak self] in
            // Lastly.. add the goPay sign in view
            self?.add(view: signGoPayView, with: [TapVerticalViewAnimationType.fadeIn()])
        }
    }
    
    /// Handles closing the GoPay sign in form by removing non required and adding required views
    public func closeGoPaySignInForm() {
        endEditing(true)
        // Inform the action button that now we will come back o the checkout reen hence, it will show invalid payment status
        tapActionButton.viewModel?.buttonStatus = .InvalidPayment
        // Once we finished the password/OTP views of goPay we have to make sure that the blur view is now invisible
        showBlur = false
        // Make sure we have a valid sign in form shown already.. Defensive coding
        let filteredViews = stackView.arrangedSubviews.filter{ $0.isKind(of: TapGoPaySignInView.self)}
        guard filteredViews.count > 0, let signGoPayView:TapGoPaySignInView = filteredViews[0] as? TapGoPaySignInView else { return }
        // Expire and invalidate any OTP running timers, so it won't fire even after closing the goPay OTP view
        signGoPayView.stopOTPTimers()
        // Remove the goPay sign in view
        remove(view: signGoPayView, with: TapVerticalViewAnimationType.none)
        // Tell the amount section that we are no in teh default view so it will change the action and the title of its button
        changeTapAmountSectionStatus(to: .DefaultView)
        // Remove any hints view that were visible because of the signIn view if any
        removeAllHintViews()
    }
    
    
    /**
     Handles showing the card scanner  by removing non required and adding required views
     - Parameter delegate: The delegate that will listen to the events fired from the scanner in view/ viewmodel
     */
    public func showScanner(with delegate:TapInlineScannerProtocl) {
        endEditing(true)
        // Remove all non needed views preparing for showing the scanner afterwards
        remove(viewType: TapChipHorizontalList.self, with: TapVerticalViewAnimationType.none, and: true)
        // Hide the action button as it is required to hide it nby the design for this scenario
        hideActionButton()
        // Create the hint view that shws the status of the scanner
        let hintViewModel:TapHintViewModel = .init(with: .ReadyToScan)
        let hintView:TapHintView = hintViewModel.createHintView()
        // Create the scanner view
        let tapCardScannerView:TapCardScannerView = .init()
        // And assign the delegate
        tapCardScannerView.delegate = delegate
        tapCardScannerView.configureScanner()
        // Inform the amount section that now we are showing the scanner view, hence it changes the title and the action of the amount's action button
        changeTapAmountSectionStatus(to: .ScannerView)
        
        DispatchQueue.main.async{ [weak self] in
            // Show the scanner hint view
            self?.attach(hintView: hintView, to: TapAmountSectionView.self,with: true)
            // Show the scanner view itself
            self?.add(view: tapCardScannerView, with: [TapVerticalViewAnimationType.fadeIn()],shouldFillHeight: true)
        }
    }
    
    /// Handles closing the scanner view by removing non required and adding required views
    public func closeScanner() {
        endEditing(true)
        
        // Make sure we have a valid scanner view already
        let filteredViews = stackView.arrangedSubviews.filter{ $0.isKind(of: TapCardScannerView.self)}
        guard filteredViews.count > 0, let scannerView:TapCardScannerView = filteredViews[0] as? TapCardScannerView else { return }
        
        // Kill the camera and garbage collect anything leaking from the scanner activity
        scannerView.killScanner()
        // Remove the scanner view
        remove(view: scannerView, with: TapVerticalViewAnimationType.none)
        // Inform the amount section that now we are showing the default view, hence it changes the title and the action of the amount's action button
        changeTapAmountSectionStatus(to: .DefaultView)
        // Remove any hints view that were visible because of the scanner view if any
        removeAllHintViews()
        // Reveal back the action button
        showActionButton()
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
    
    /// Call this method to remove all the shown hint views in the TAP bottom sheet
    @objc public func removeAllHintViews() {
        // Fetch all the hint views from the stack view first
        let hintViews:[TapHintView] = stackView.arrangedSubviews.filter{ $0.isKind(of: TapHintView.self) } as? [TapHintView] ?? []
        guard hintViews.count > 0 else { return }
        // For each one, apply the deletion method
        hintViews.forEach { hintView in
            remove(view: hintView, with: TapVerticalViewAnimationType.none)
        }
    }
    
    internal func adjustAnimationList(view:UIView, for animations:[TapVerticalViewAnimationType], with sequence:TapAnimationSequence, then completion:@escaping () -> () = {  }) {
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
    
    internal func animate(view:UIView,with animation:TapVerticalViewAnimationType,after delay:TimeInterval = 0, and completion:@escaping () -> () = {  }) {
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
