//
//  TapBottomSheetDialogViewController.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/3/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import PullUpController
import GestureRecognizerClosures

/// The data source needed to configure the data of the TAP sheet controller
@objc public protocol TapBottomSheetDialogDataSource {
    /**
     Defines the background color for the not filled part of the bottom sheet view controller
     - Returns: UIColor that defines the not filled part color. Default is clear with alpha of 0.5
     */
    @objc func tapBottomSheetBackGroundColor() -> UIColor
    
    /**
    Defines the blur visual effect if required
    - Returns: The UIBlurEffect needed to be applied. Optional and default is none
    */
    @objc optional func tapBottomSheetBlurEffect() -> UIBlurEffect?
    
    /**
    Defines the actual controller you want to display as a popup modal
    - Returns: The Viewcontroller to modally present. Optional and default is nil
    */
    @objc optional func tapBottomSheetViewControllerToPresent() -> TapPresentableViewController?
    
    /**
    Defines the radious value for the .topLeft and .topRight corners for the modal controller
    - Returns: The radious value for the .topLeft and .topRight corners for the modal controller
    */
    @objc optional func tapBottomSheetControllerRadious() -> CGFloat
    
    /**
     Defines the initial height to show the modal controller default is 100
    - Returns: The height value initialy set the controller to
    */
    @objc optional func tapBottomSheetInitialHeight() -> CGFloat
    
    /**
     Defines the point when the view is dragged and reached a height threshold
     - Returns: The height threshold we shall dismiss after it
     */
    @objc optional func tapBottomSheetDismissBelowHeight() -> CGFloat
    
    /**
    Defines the corners you want to apply the radius value to
    - Returns: The corners sides you want to apply the radius values to
    */
    @objc optional func tapBottomSheetRadiousCorners() -> UIRectCorner
    
    /**
     Defines if the popup should dismiss itself if the user clicked outside the presented controller
     - Returns: true to dismiss and false to ignore the clicks
    */
    @objc optional func tapBottomSheetShouldAutoDismiss() -> Bool
    
    /**
     Defines the points where you want the modal controller to jump to based on where the user dragged the controller
     - Returns: list of heights the controller will be adjusted to the nearest one based on user dragging end. Default all skipping points by 5 from 0 to the initial height
     */
    @objc optional func tapBottomSheetStickingPoints() -> [CGFloat]
    
    
}

/// The data source needed to configure the data of the TAP sheet controller
@objc public protocol TapBottomSheetDialogDelegate {
    
    /**
     Will be fired just before the sheet is dismissed
     */
    @objc optional func tapBottomSheetWillDismiss()
    
    /**
     Will be fired if the user clicks in the dimmed area non filled by the presented controller
     */
    @objc optional func tapBottomSheetDidTapOutside()
    
    /**
     Will be fired once the user changed the height of the presented control by dragging it
     - Parameter newHeight : Represents the new height of the controller after the drag operation
     */
    @objc optional func tapBottomSheetHeightChanged(with newHeight:CGFloat)
    
    /**
     Will be fired once the controller is presented
     */
    @objc optional func tapBottomSheetPresented()
}

/// This class represents the bottom sheet popup with all of its configuration
@objc public class TapBottomSheetDialogViewController: UIViewController {

    // MARK: Variables and attributes
    
    
    /// The data source object to provide the configurations needed to customise the bottom sheet controller
    @objc public var dataSource:TapBottomSheetDialogDataSource?
    
    /// The  delegate object to listen for events from the bottom sheet controller
    @objc public var delegate:TapBottomSheetDialogDelegate?
    
    /// Holds a reference to the last/currenty displayed modal view controller
    private var addedPullUpController:TapPresentableViewController?
    
    /// The button that will fill the un filled area, will be used to listen to clicking outside the modal view to dismiss it if the caller asked for this
    private var dismissButton:UIButton = .init()
    
    // MARK: Default values for needed variables
    
    ///Defines the background color for the not filled part of the bottom sheet view controller default is .init(white: 0, alpha: 0.5)
    private var tapBottomSheetBackgroundColor:UIColor {
        guard let dataSource = dataSource else { return .init(white: 0, alpha: 0.5) }
        return dataSource.tapBottomSheetBackGroundColor()
    }
    
    ///Defines the blur visual effect if required default none
    private var tapBottomSheetBlurEffect:UIBlurEffect? {
        guard let dataSource = dataSource, let blurEffect = dataSource.tapBottomSheetBlurEffect?() else { return nil }
        return blurEffect
    }
    
    ///Defines the point when the view is dragged and reached a height threshold, should be lower than 20
    private var tapBottomSheetDismissBelowHeight:CGFloat {
        guard let dataSource = dataSource, let tapBottomSheetDismissBelowHeight = dataSource.tapBottomSheetDismissBelowHeight?(), tapBottomSheetDismissBelowHeight < ConstantManager.TapBottomSheetMinimumYPoint else { return ConstantManager.TapBottomSheetMinimumYPoint }
        return tapBottomSheetDismissBelowHeight
    }
    
    ///Defines the actual controller you want to display as a popup modal default none
    private var tapBottomSheetViewControllerToPresent:TapPresentableViewController? {
        guard let dataSource = dataSource, let presentController = dataSource.tapBottomSheetViewControllerToPresent?() else { return nil }
        return presentController
    }
    
    ///Defines the radious value for the .topLeft and .topRight corners for the modal controller default is 0
    private var tapBottomSheetControllerRadious:CGFloat {
        guard let dataSource = dataSource, let radius = dataSource.tapBottomSheetControllerRadious?() else { return 0 }
        return radius
    }
    
    ///Defines the initial height to show the modal controller default is 100
    private var tapBottomSheetInitialHeight:CGFloat {
        guard let dataSource = dataSource, let height = dataSource.tapBottomSheetInitialHeight?(), height > ConstantManager.TapBottomSheetMinimumHeight else { return 100 }
        return height
    }
    ///Defines the radious value for the .topLeft and .topRight corners for the modal controller default [.topRight,.topLeft]
    private var tapBottomSheetRadiousCorners:UIRectCorner {
        guard let dataSource = dataSource, let corners = dataSource.tapBottomSheetRadiousCorners?() else { return [.topRight,.topLeft] }
        return corners
    }
    
    ///Defines if the popup should dismiss itself if the user clicked outside the presented controller default is true
    private var tapBottomSheetShouldAutoDismiss:Bool {
           guard let dataSource = dataSource, let shouldDismiss = dataSource.tapBottomSheetShouldAutoDismiss?() else { return true }
           return shouldDismiss
    }
    
    ///Defines the points where you want the modal controller to jump to based on where the user dragged the controller default [50,100]
    private var tapBottomSheetStickingPoints:[CGFloat]? {
        guard let dataSource = dataSource, let sitckingPoints = dataSource.tapBottomSheetStickingPoints?() else { return nil }
        
        return [ConstantManager.TapBottomSheetMinimumYPoint] + sitckingPoints
    }
    
    // MARK: Override methods
    public final override func viewDidLoad() {
        super.viewDidLoad()
        
        // for iOS < 13, swiping down will not automatically dismiss the controller, we need to take care of this
        handleDismissOneSwipeDown()
        
        // First thing to do is to apply the customisation data from the data source
        reloadDataSource()
    }
    
    
    
    
    /// For iOS < 13, swiping down will not automatically dismiss the controller, we need to take care of this
    private func handleDismissOneSwipeDown() {
        // Apply dismissing upon swiping down for iOS < 13, as in iOS13+ it comes by default
        view.onSwipeDown { [weak self] (_) in
            self?.dismissBottomSheet()
        }
    }
    
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let delegate = delegate {
            delegate.tapBottomSheetWillDismiss?()
        }
        guard let nonNullPullUpController = addedPullUpController else { return }
        self.removePullUpController(nonNullPullUpController, animated: false)
    }
    
    /// Call this method when you need the bottom controller to update its look based in reloading th configurations from the data source again
    @objc public func reloadDataSource() {
        fetchUIData()
    }
    
    /// This function decides which UI attributes we should used based no default or passed data from the data source
    private func fetchUIData() {
        
        // If no data source is providede, we use the defaul values
        applyUI(with: tapBottomSheetBackgroundColor, and: tapBottomSheetBlurEffect)
        // Add the dismiss on click outside
        addDismissOnClickingOutside()
        
        // Let us add the pull up controller if any
        showPullUpController()
    }
    
    /**
     Applies the given ui attributes to the view controller
     - Parameter backgroundColor: The color we will set to the background
     - Parameter blurEffect: The blurring effect we will set to the background
     */
    private func applyUI(with backgroundColor:UIColor, and blurEffect:UIBlurEffect? = nil) {
        
        // Set the background color
        view.backgroundColor = backgroundColor
        
        // Make sure we remove the old blur effect if any first
        if let oldBlurView = view.viewWithTag(ConstantManager.TapBottomSheetContainerTag) {
            oldBlurView.removeFromSuperview()
        }
        
        // let us the blur effect
        addBlurEffect(with: blurEffect)
    }
    
    /**
    Applies the blur effect
    - Parameter blurEffect: The blurring effect we will set to the background
    */
    private func addBlurEffect(with blurEffect:UIBlurEffect? = nil) {
        // Make sure that there is a blur effect to add
        guard let blurEffect = blurEffect else { return }
        
        // If the caller provided a blur effect, we create a blur effect and vibrancy views and we add them to the view
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.tag = ConstantManager.TapBottomSheetContainerTag
        blurredEffectView.frame = view.bounds
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = view.bounds
        blurredEffectView.contentView.addSubview(vibrancyEffectView)
        view.addSubview(blurredEffectView)
    }
    
    /**
    Handles adding a modal controller with the needed configurations
    */
    private func showPullUpController() {
        
        // first remove any added controller before, defennsive coding
        if let oldController = addedPullUpController { removePullUpController(oldController, animated: true) }
        
        // hold a reference to the controller we will display
        addedPullUpController = tapBottomSheetViewControllerToPresent
        // If there is no controller passed, we just return
        guard let nonNullPresentController = addedPullUpController else { return }
        // Assign delegate
        nonNullPresentController.delegate = self
        // Add the controller and move it to the first sticky point needed
        nonNullPresentController.view.tapRoundCorners(corners: tapBottomSheetRadiousCorners, radius: tapBottomSheetControllerRadious)
        // Add the sticky points
        addStickyPoints(to: nonNullPresentController)
        
        addPullUpController(nonNullPresentController, initialStickyPointOffset: tapBottomSheetInitialHeight, animated: false, completion: { [weak self] (_) in
            DispatchQueue.main.async {
                guard let nonNullPullUpController = self?.addedPullUpController else { return }
                nonNullPullUpController.pullUpControllerMoveToVisiblePoint(self?.tapBottomSheetInitialHeight ?? 100, animated: true,completion: {
                    guard let delegate = self?.delegate else { return }
                    delegate.tapBottomSheetPresented?()
                })
            }
        })
    }
    
    /**
     Handles the logic to create the sticky points for the modal controller
    - Parameter pullUpController: The modal controller we want to adjust its sticky points
     */
    private func addStickyPoints(to pullUpController:TapPresentableViewController) {
        // Tell it the initial height, as this is a sticky point
        pullUpController.initialHeight = tapBottomSheetInitialHeight
        // Tell it the max height, will use it in case the caller didn't define stcky points and we will create our own
        pullUpController.maxHeight = self.view.frame.height - ConstantManager.TapBottomSheetMinimumYPoint
        // Tell it the points the caller passed if any
        pullUpController.tapBottomSheetStickingPoints = tapBottomSheetStickingPoints
    }
    
    /// Handles the logic needed to remove or add the feature of dismissing the bottom sheet upon clicking outside the modal view controller
    private func addDismissOnClickingOutside() {
        
        // First, remove the button  just defensive coding
        dismissButton.removeFromSuperview()
        // Second, configure the dismiss button
        configureTheDismissButton()
        
        // If the caller asked to dismiss upon clicking outside the modal view controller
        view.addSubview(dismissButton)
        view.bringSubviewToFront(dismissButton)
        
    }
    
    /// Creates and configure the dismiss button
    private func configureTheDismissButton() {
        dismissButton = .init(frame: view.frame)
        // Second check if the datasource asked to dismiss when clicking outside
        if tapBottomSheetShouldAutoDismiss  {// This means the caller asked for dismiss upon clicking outside
            dismissButton.addTarget(self, action:#selector(dismissBottomSheet), for: .touchUpInside)
        }
        // In all cases we need to fire the delegate func of tapping outside
        dismissButton.addTarget(self, action:#selector(tappedOutside), for: .touchUpInside)
    }
    
    /// This method handles the logic of firing the tap outside the filled area delegate
    @objc private func tappedOutside() {
        guard let delegate = delegate else { return }
        delegate.tapBottomSheetDidTapOutside?()
    }
     /// This method is responsible for the dismissal logic
    @objc private func dismissBottomSheet() {
        //delegate?.tapBottomSheetWillDismiss?()
        DispatchQueue.main.async { [weak self] in
            // Check first if we have a pull up controller, we remove it first then we dismiss
            guard let modalController = self?.addedPullUpController  else {
                self?.dismiss(animated: true, completion: nil)
                return
            }
            // Otherwise, we dismiss ourselves directly
            modalController.dismiss(animated: true) {
                self?.dismiss(animated: false, completion: nil)
            }
        }
    }
}


extension TapBottomSheetDialogViewController: TapPresentableViewControllerDelegate {
    func tapBottomSheetHeightChanged(with newHeight: CGFloat) {
        guard let delegate = delegate else { return }
        delegate.tapBottomSheetHeightChanged?(with: newHeight)
    }
}
