//
//  TapBottomSheetDialogViewController.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 6/3/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import PullUpController

/// The data source needed to configure the data of the TAP sheet controller
@objc public protocol TapBottomSheetDialogDataSource {
    /**
     Defines the background color for the not filled part of the bottom sheet view controller
     - Returns: UIColor that defines the not filled part color. Default is clear with alpha of 0.5
     */
    @objc func backGroundColor() -> UIColor
    
    /**
    Defines the blur visual effect if required
    - Returns: The UIBlurEffect needed to be applied. Optional and default is none
    */
    @objc optional func blurEffect() -> UIBlurEffect?
    
    /**
    Defines the actual controller you want to display as a popup modal
    - Returns: The Viewcontroller to modally present. Optional and default is nil
    */
    @objc optional func viewControllerToPresent() -> TapPresentableViewController?
}

/// This class represents the bottom sheet popup with all of its configuration
@objc public class TapBottomSheetDialogViewController: UIViewController {

    /// The data source object to provide the configurations needed to customise the bottom sheet controller
    @objc public var dataSource:TapBottomSheetDialogDataSource?
    
    /// Holds a reference to the last/currenty displayed modal view controller
    private var addedPullUpController:PullUpController?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // First thing to do is to apply the customisation data from the data source
        reloadDataSource()
    }
    
    
    /// Call this method when you need the bottom controller to update its look based in reloading th configurations from the data source again
    @objc public func reloadDataSource() {
        fetchUIData()
    }
    
    /// This function decides which UI attributes we should used based no default or passed data from the data source
    private func fetchUIData() {
        // If we have a data source, the use the provided data
        guard let dataSource = dataSource else {
            applyUI(with: .init(white: 0, alpha: 0.5))
            return
        }
        // If no data source is providede, we use the defaul values
        applyUI(with: dataSource.backGroundColor(), and: dataSource.blurEffect?())
        
        // Let us add the pull up controller if any
        showPullUpController(with: dataSource.viewControllerToPresent?())
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
    - Parameter presentViewController: The controller we need to display as a modal popup controller
    */
    private func showPullUpController(with presentViewController:TapPresentableViewController? = nil) {
        
        // first remove any added controller before, defennsive coding
        if let oldController = addedPullUpController { removePullUpController(oldController, animated: true) }
        // hold a reference to the controller we will display
        addedPullUpController = presentViewController
        // If there is no controller passed, we just return
        guard let nonNullPresentController = presentViewController else { return }
        // Add the controller and move it to the first sticky point needed
        addPullUpController(nonNullPresentController, initialStickyPointOffset: 50, animated: false, completion: { [weak self] (_) in
            DispatchQueue.main.async {
                guard let nonNullPullUpController = self?.addedPullUpController else { return }
                nonNullPullUpController.pullUpControllerMoveToVisiblePoint(100, animated: true, completion: nil)
            }
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

