//
//  TapSwitchViewModel.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/20/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

/// A protocol to be used to fire functions and events in the associated view
internal protocol TapSwitchViewDelegate {
    func removeSubSwitches()
    func addSubSwitches()
}

/// A protocol to be used to fire functions and events in the parent view
@objc public protocol TapSwitchViewModelDelegate {
    /**
       An event will be fired once the main switch toggled
    - Parameter enabled: is the switch is on, true if  the switch is on
    */
    @objc func didToggleMainSwitch(enabled: Bool)
}

@objc public class TapSwitchViewModel: NSObject {
    
    /// The delegate used to fire events inside the associated view
    internal var viewDelegate: TapSwitchViewDelegate?// TapOtpViewDelegate?
    
    /// The delegate used to fire events to the caller view
    @objc public var delegate:TapSwitchViewModelDelegate?
    
    public var mainSwitch: TapSwitchModel
    public var goPaySwitch: TapSwitchModel?
    public var merchantSwitch: TapSwitchModel?
    
    
    public init(mainSwitch: TapSwitchModel, goPaySwitch: TapSwitchModel) {
        self.mainSwitch = mainSwitch
        self.goPaySwitch = goPaySwitch
    }
    
    public init(mainSwitch: TapSwitchModel, merchantSwitch: TapSwitchModel) {
        self.mainSwitch = mainSwitch
        self.merchantSwitch = merchantSwitch
    }
    
    public init(mainSwitch: TapSwitchModel, goPaySwitch: TapSwitchModel, merchantSwitch: TapSwitchModel) {
        self.mainSwitch = mainSwitch
        self.goPaySwitch = goPaySwitch
        self.merchantSwitch = merchantSwitch
    }
    
    
    // MARK: Toggle Switch
    internal func updateMainSwitchState(isOn: Bool) {
        self.mainSwitch.isOn = isOn
        if isOn {
            self.viewDelegate?.addSubSwitches()
        } else {
            self.viewDelegate?.removeSubSwitches()
        }
        self.delegate?.didToggleMainSwitch(enabled: isOn)
    }
    
    internal func updateGoPaySwitchState(isOn: Bool) {
        self.goPaySwitch?.isOn = isOn
    }
    
    internal func updateMerchantSwitchState(isOn: Bool) {
        self.merchantSwitch?.isOn = isOn
    }
    
    /**
        This
    */
    @objc public func createSwitchView() -> TapSwitchView {
        let tapSwitchView:TapSwitchView = .init()
        tapSwitchView.translatesAutoresizingMaskIntoConstraints = false
        tapSwitchView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        tapSwitchView.setup(with: self)
        return tapSwitchView
    }
}
