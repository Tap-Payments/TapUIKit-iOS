//
//  TapVerticalView+ShowHideTapViews.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 8/7/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
import TapCardScanner_iOS
/// Extension to the bottom sheet that contains all the logic required for showing and dismissing Tap custom views fromt the sheet controller
extension TapVerticalView {
    
    
    /// Call this method to remove all the shown hint views in the TAP bottom sheet
    @objc public func removeAllHintViews() {
        // Fetch all the hint views from the stack view first
        let hintViews:[TapHintView] = stackView.arrangedSubviews.filter{ $0.isKind(of: TapHintView.self) } as? [TapHintView] ?? []
        guard hintViews.count > 0 else { return }
        // For each one, apply the deletion method
        hintViews.forEach { [weak self] hintView in
            self?.stackView.removeArrangedSubview(hintView)
            hintView.isHidden = true
        }
    }
    
    
    /**
     Handles showing the GoPay sign in form by removing non required and adding required views
     - Parameter delegate: The delegate that will listen to the events fired from the GoPay sign in view/ viewmodel
     - Parameter goPayBarViewModel: The view model that will control the goPay sign view
     - Parameter hintViewStatus: Decides The theme, title and action button shown on the top of the OTP view based on the type
     - Parameter authenticationID: The string for authentication id process if any
     */
    @objc public func showGoPaySignInForm(with delegate:TapGoPaySignInViewProtocol,and goPayBarViewModel:TapGoPayLoginBarViewModel,hintViewStatus:TapHintViewStatusEnum = .GoPayOtp,for authenticationID:String = "") {
        // First declare the button state
        tapActionButton.viewModel?.buttonStatus = (hintViewStatus == .SavedCardOTP) ? .InvalidConfirm : .InvalidNext
        // Save the otp type to the view model
        goPayBarViewModel.hintViewStatus = hintViewStatus
        // Create the GoPay sign in view and assign the delegate
        let signGoPayView:TapGoPaySignInView = .init()
        signGoPayView.delegate = delegate
        signGoPayView.backgroundColor = .clear
        
        // Attach the view model to th just created view
        signGoPayView.setup(with: goPayBarViewModel,OTPHintBarMode: hintViewStatus,authenticationID: authenticationID)
        
        // Inform the amount section that now we are showing the gopay view, hence it changes the title and the action of the amount's action button
        changeTapAmountSectionStatus(to: .GoPayView)
        
        endEditing(true)
        // Remove from the stack view all the non needed view to prepare for showing the goPay sign in view
        remove(viewType: TapChipHorizontalList.self, with: .init(for:.fadeOut, with:0.3), and: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(550)){ [weak self] in
            // Lastly.. add the goPay sign in view
            self?.add(view: signGoPayView, with: [])
        }
    }
    
    /// Handles closing the GoPay sign in form by removing non required and adding required views
    @objc public func closeGoPaySignInForm() {
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
        remove(view: signGoPayView, with: .init(for:.fadeOut, with: 0.3))
        // Tell the amount section that we are no in teh default view so it will change the action and the title of its button
        changeTapAmountSectionStatus(to: .DefaultView)
        // Remove any hints view that were visible because of the signIn view if any
        removeAllHintViews()
    }
    
    @objc public func stopOTPTimers() {
        let filteredViews = stackView.arrangedSubviews.filter{ $0.isKind(of: TapGoPaySignInView.self)}
        guard filteredViews.count > 0, let signGoPayView:TapGoPaySignInView = filteredViews[0] as? TapGoPaySignInView else { return }
        // Expire and invalidate any OTP running timers, so it won't fire even after closing the goPay OTP view
        signGoPayView.stopOTPTimers()
    }
    
    /**
     Handles showing the card scanner  by removing non required and adding required views
     - Parameter delegate: The delegate that will listen to the events fired from the scanner in view/ viewmodel
     */
    @objc public func showScannerObjC(with delegate:TapInlineScannerProtocl) {
        showScanner(with: delegate, for: nil)
    }
    
    /**
     Handles showing the card scanner  by removing non required and adding required views
     - Parameter delegate: The delegate that will listen to the events fired from the scanner in view/ viewmodel
     - Parameter dataSource: To pass the allowed card brands for the scanners if needed
     */
    public func showScanner(with delegate:TapInlineScannerProtocl,for dataSource:TapScannerDataSource?) {
        endEditing(true)
        // Remove all non needed views preparing for showing the scanner afterwards
        remove(viewType: TapAmountSectionView.self, with: .init(), and: true, skipSelf: true)
        // Hide the action button as it is required to hide it nby the design for this scenario
        hideActionButton()
        // Create the hint view that shws the status of the scanner
        let hintViewModel:TapHintViewModel = .init(with: .ReadyToScan)
        let hintView:TapHintView = hintViewModel.createHintView()
        // Create the scanner view
        let tapCardScannerView:TapCardScannerView = .init()
        // And assign the delegate
        tapCardScannerView.delegate = delegate
        tapCardScannerView.configureScanner(dataSource: dataSource)
        // Inform the amount section that now we are showing the scanner view, hence it changes the title and the action of the amount's action button
        changeTapAmountSectionStatus(to: .ScannerView)
        
        DispatchQueue.main.async{ [weak self] in
            // Show the scanner hint view
            self?.attach(hintView: hintView, to: TapAmountSectionView.self,with: true)
            // Show the scanner view itself
            self?.add(view: tapCardScannerView, with: [.init(for: .slideIn, with: 0.3, wait: 0.3)],shouldFillHeight: true)
        }
    }
    
    /// Handles closing the scanner view by removing non required and adding required views
    @objc public func closeScanner() {
        endEditing(true)
        
        // Make sure we have a valid scanner view already
        let filteredViews = stackView.arrangedSubviews.filter{ $0.isKind(of: TapCardScannerView.self)}
        guard filteredViews.count > 0, let scannerView:TapCardScannerView = filteredViews[0] as? TapCardScannerView else { return }
        
        // Kill the camera and garbage collect anything leaking from the scanner activity
        scannerView.killScanner()
        // Remove the scanner view
        remove(view: scannerView, with: .init(for: .slideOut, with: 0.2))
        // Inform the amount section that now we are showing the default view, hence it changes the title and the action of the amount's action button
        changeTapAmountSectionStatus(to: .DefaultView)
        // Remove any hints view that were visible because of the scanner view if any
        removeAllHintViews()
        // Reveal back the action button
        showActionButton()
    }
    
    /// Removes all space views added to the bottom sheet, for example, keyboard is dimssing hence we will remove the space view added to push the views above the keyboars
    internal func removeSpaceViews() {
        // Get all space views added to the sheet
        let spaceViews:[SpaceView] = stackView.arrangedSubviews.filter{ $0.isKind(of: SpaceView.self) } as? [SpaceView] ?? []
        guard spaceViews.count > 0 else { return }
        // For each space view apply the deletion method
        spaceViews.forEach { spaceView in
            remove(view: spaceView, with: .init())
        }
    }
    
    /**
     Adds a space view to the bottom sheet, for example, keyboard is shown hence we will add the space view added to push the views above the keyboars
     - Parameter spaceRect: The rectangle of the needed space view to be added at the bottom of the sheet
     */
    internal func addSpaceView(with spaceRect:CGRect) {
        // Push the action button by the required space height
        tapActionButtonBottomConstraint.constant = spaceRect.height - 250
        // Save the current pushing padding height
        keyboardPadding = spaceRect.height - 230
        if #available(iOS 13.0, *) {}else {
            keyboardPadding = 0
        }
        // Adjust the content size of the current tap sheet to fire a notification that the size changed
        var currentContentSize = scrollView.contentSize
        currentContentSize.height -= 1
        
        // Animate pushing the views above the shown keyboard
        UIView.animate(withDuration: 0.25, animations: {
            self.tapActionButton.updateConstraints()
            self.layoutIfNeeded()
        })
        
        // Change the scroll view content size to reflect the adding space to show the keyboard
        self.delaySizeChange = false
        self.scrollView.contentSize = currentContentSize
        self.scrollView.scrollToBottom()
    }
    
    
    /** Removes all space views added to the bottom sheet, for example, keyboard is dimssing hence we will remove the space view added to push the views above the keyboars
     - Parameter spaceRect: The rectangle of the needed space view to be removed at the bottom of the sheet
     */
    internal func removeSpaceView(with spaceView:CGRect) {
        
        // Pull the action button by the required space height
        tapActionButtonBottomConstraint.constant = 30
        // Push the action button by the required space height
        keyboardPadding = 0
        // Adjust the content size of the current tap sheet to fire a notification that the size changed
        var currentContentSize = scrollView.contentSize
        currentContentSize.height -= 1
        
        // Animate pulling the views down again as the keyboard is dismissed
        UIView.animate(withDuration: 0.25, animations: {
            self.tapActionButton.updateConstraints()
            self.layoutIfNeeded()
        })
        // Change the scroll view content size to reflect the adding space to show the keyboard
        self.delaySizeChange = false
        self.scrollView.contentSize = currentContentSize
    }
    
    /// Shows the action button fade in + height increase
    @objc public func showActionButton(fadeInDuation:Double = 0, fadeInDelay:Double = 0) {
        if fadeInDuation != 0 {
            tapActionButton.fadeIn(duration: fadeInDuation, delay: fadeInDelay)
            //powereByTapView.fadeIn(duration: fadeInDuation, delay: fadeInDelay)
        }else{
            tapActionButton.fadeIn()
            //powereByTapView.fadeIn()
        }
        
        tapActionButtonHeightConstraint.constant = 48
        tapActionButton.updateConstraints()
        
        /*powereByTapView.snp.remakeConstraints { make in
         make.height.equalTo(33)
         }
         powereByTapView.layoutIfNeeded()
         powereByTapView.updateConstraints()*/
        
        layoutIfNeeded()
    }
    
    /// Hide the action button fade out + height decrease
    @objc  public func hideActionButton(fadeInDuation:Double = 0.25, fadeInDelay:Double = 0, keepPowredByTapView:Bool = false) {
        
        tapActionButton.fadeOut(duration: fadeInDuation, delay: fadeInDelay){ _ in
            DispatchQueue.main.async {
                self.tapActionButtonHeightConstraint.priority = .required
                self.tapActionButtonHeightConstraint.constant = 0
                self.tapActionButton.updateConstraints()
            }
        }
        
        /*if !keepPowredByTapView {
         powereByTapView.fadeOut(duration: fadeInDuation, delay: fadeInDelay){ _ in
         DispatchQueue.main.async {
         self.powereByTapView.snp.remakeConstraints { make in
         make.height.equalTo(0)
         }
         self.powereByTapView.layoutIfNeeded()
         self.powereByTapView.updateConstraints()
         }
         }
         }*/
        layoutIfNeeded()
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
        let requiredAnimations:[TapSheetAnimation] = animations ? [.init(for: .fadeIn)] : []
        // Insert at the hint view at the correct index
        if attachToViewIndex == stackView.arrangedSubviews.count - 1 {
            // The attaching to view is already the last element, hence we add at the end normally as we usually do
            add(view: hintView, with: requiredAnimations)
        }else {
            add(view: hintView,at: (attachToViewIndex+1), with: requiredAnimations)
        }
    }
}


fileprivate extension UIScrollView {
    
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        setContentOffset(bottomOffset, animated: true)
    }
}
