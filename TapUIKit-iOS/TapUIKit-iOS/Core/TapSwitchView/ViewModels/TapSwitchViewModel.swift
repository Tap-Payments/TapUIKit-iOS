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
    - Parameter enabled: return current switch state
    */
    @objc func didChangeState(state: TapSwitchEnum)
}

@objc public class TapSwitchViewModel: NSObject {
    
    /// The delegate used to fire events inside the associated view
    internal var viewDelegate: TapSwitchViewDelegate?// TapOtpViewDelegate?
    
    /// The delegate used to fire events to the caller view
    @objc public var delegate:TapSwitchViewModelDelegate?
    
    internal var mainSwitch: TapSwitchModel
    internal var goPaySwitch: TapSwitchModel?
    internal var merchantSwitch: TapSwitchModel?
    
    public var state: TapSwitchEnum = .none {
        didSet {
            self.delegate?.didChangeState(state: state)
        }
    }
    
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
            if self.merchantSwitch != nil {
                self.updateMerchantSwitchState(isOn: true)
            }
            if self.goPaySwitch != nil {
                self.updateGoPaySwitchState(isOn: true)
            }
            
        } else {
            self.viewDelegate?.removeSubSwitches()
            self.state = .none
        }
    }
    
    internal func updateGoPaySwitchState(isOn: Bool) {
        self.goPaySwitch?.isOn = isOn
        self.validateState()
    }
    
    internal func updateMerchantSwitchState(isOn: Bool) {
        self.merchantSwitch?.isOn = isOn
        self.validateState()
    }
    
    internal func validateState() {
        let merchantState: Bool = self.merchantSwitch?.isOn ?? false
        let goPayState: Bool = self.goPaySwitch?.isOn ?? false

        if !merchantState && !goPayState {
            self.updateMainSwitchState(isOn: false)
            return
        } else if merchantState && goPayState {
            self.state = .all
            return
        }
        
        if merchantState {
            self.state = .merchant
            return
        }
        
        if goPayState {
            self.state = .goPay
        }
    }
    
    /**
        Creating and setup Switch View
    */
    @objc public func createSwitchView() -> TapSwitchView {
        let tapSwitchView:TapSwitchView = .init()
        tapSwitchView.translatesAutoresizingMaskIntoConstraints = false
        tapSwitchView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        tapSwitchView.setup(with: self)
        return tapSwitchView
    }
}
