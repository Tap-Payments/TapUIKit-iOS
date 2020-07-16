//
//  TapHintViewModel.swift
//  TapUIKit-iOS
//
//  Created by Osama Rabie on 7/13/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import Foundation
/// A protocol to be used to fire functions and events in the associated view
internal protocol TapHintViewDelegate {
    /// A method to instruc the view to reload itself to respond to new status
    func reloadHintView()
}

/// A protocol to be used to fire functions and events in the parent view
@objc public protocol TapHintViewModelDelegate {
    /**
        An event will be fired once the hint view is clicked
     - Parameter viewModel: The associated view model with the clicked hint vie
     */
    @objc func hintViewClicked(with viewModel:TapHintViewModel)
}

/// The view model that controls the tap hint view
@objc public class TapHintViewModel:NSObject {
    
    /// The delegate used to fire events inside the associated view
    internal var viewDelegate:TapHintViewDelegate?
    /// The status of this hint
    @objc public var tapHintViewStatus:TapHintViewStatusEnum = .ReadyToScan {
        didSet{
            // Upon status change, the associated view needs to reload itself
            viewDelegate?.reloadHintView()
        }
    }
    /// Set this value if you want to set a specific title in the hint view
    @objc public var overrideTitle:String? {
        didSet {
            viewDelegate?.reloadHintView()
        }
    }
    /// Set this valye if you want to append a value to the normal hint status localized value
    @objc public var appendTitle:String? {
        didSet {
            viewDelegate?.reloadHintView()
        }
    }
    
    /// The delegate used to fire events to the caller view
    @objc public var delegate:TapHintViewModelDelegate?
    
    /**
     Creates a view model with the provided status
     - Parameter tapHintViewStatus: The status of this hint
     */
    @objc public init(with tapHintViewStatus:TapHintViewStatusEnum) {
        super.init()
        defer {
            self.tapHintViewStatus = tapHintViewStatus
        }
    }
    
    /**
     The localization path of the localized value to show for each status putting in mind if the user wants to override this value or append to it
     - Parameter localized: If set, the method will return th localzed value otherwise, will return the localization path only
     - Returns: The actual localization path in the localization file or the localized value itself based on inptu, overrided by an verride value of provided or append
     */
    internal func localizedTitle(localized: Bool = true) -> String {
        // Check if the user provided an override value
        if let overrideValue = overrideTitle {
            return overrideValue
        }
        // Return the localized value and append to it the append value if any
        return "\(tapHintViewStatus.localizedTitle(localized: localized)) \(appendTitle ?? "")"
    }
    
    @objc public override init() {
        super.init()
    }
    
    @objc public func createHintView() -> TapHintView {
        let tapHintView:TapHintView = .init()
        tapHintView.translatesAutoresizingMaskIntoConstraints = false
        tapHintView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        tapHintView.setup(with: self)
        return tapHintView
    }
    
    /// Inform the view model with the click action happened on the hint view
    internal func hintViewClicked() {
        delegate?.hintViewClicked(with: self)
    }
    
    
}
