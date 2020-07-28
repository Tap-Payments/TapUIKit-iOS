//
//  TapSwitchViewModel.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/20/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

/// A protocol to be used to fire functions and events in the associated view
internal protocol TapSwitchViewDelegate {
    /// An event will be fired once the main switch card state changed to valid card or valid telecom
    func hideMainSwitch()
    /// An event will be fired once the main switch card state changed to invalid card or invalid telecom
    func showMainSwitch()
    /// An event will be fired once the main switch state changed to off
    func removeSubSwitches()
    /// An event will be fired once the main switch state changed to on
    func addSubSwitches()
    
    func updateSwitchesText()
}

/// A protocol to be used to fire functions and events in the parent view
@objc public protocol TapSwitchViewModelDelegate {
    /**
       An event will be fired once the switch state changed
    - Parameter state: return current switch state
    */
    @objc func didChangeState(state: TapSwitchEnum)
    
    /**
       An event will be fired once the switch card state changed
    - Parameter cardState: return the new switch card state
    */
    @objc func didChangeCardState(cardState: TapSwitchCardStateEnum)
}

@objc public class TapSwitchViewModel: NSObject {
    
    /// The delegate used to fire events inside the associated view
    internal var viewDelegate: TapSwitchViewDelegate? {
        didSet {
            updateCardState()
        }
    }
    
    /// The delegate used to fire events to the caller view
    @objc public var delegate:TapSwitchViewModelDelegate?
    
    /// main Switch model that holds the main switch properties
    internal var mainSwitch: TapSwitchModel = TapSwitchModel(title: "", subtitle: "")
    /// goPay Switch model that holds the goPay switch properties
    internal var goPaySwitch: TapSwitchModel?
    /// merchant Switch model that holds the merchant switch properties
    internal var merchantSwitch: TapSwitchModel?
    /// merchant Switch model that holds the merchant switch properties
    internal var merchant: String
    
    /// current state for switch view, default state is .none
    public var state: TapSwitchEnum = .none {
        didSet {
            self.delegate?.didChangeState(state: state)
        }
    }
    
    /// current state for switch view, default state is .none
    public var cardState: TapSwitchCardStateEnum = .invalidCard {
        didSet {
            self.updateCardState()
            self.delegate?.didChangeCardState(cardState: cardState)
        }
    }
    
    public init(with cardState: TapSwitchCardStateEnum, merchant: String) {
        self.merchant = merchant
        self.cardState = cardState
        super.init()
        self.configureSwitches()
    }
    
    /**
     Initialize switch view with mainSwitch and goPaySwitch
     - Parameter mainSwitch: main switch model to holde the required properties
     - Parameter goPaySwitch: goPay switch model to holde the required properties
     */
//    public init(mainSwitch: TapSwitchModel, goPaySwitch: TapSwitchModel) {
//        self.mainSwitch = mainSwitch
//        self.goPaySwitch = goPaySwitch
//    }
    
    /**
    Initialize switch view with mainSwitch and goPaySwitch
    - Parameter mainSwitch: main switch model to holde the required properties
    - Parameter merchantSwitch: merchant switch model to holde the required properties
    */
//    public init(mainSwitch: TapSwitchModel, merchantSwitch: TapSwitchModel) {
//        self.mainSwitch = mainSwitch
//        self.merchantSwitch = merchantSwitch
//    }
    
    /**
    Initialize switch view with mainSwitch and goPaySwitch
    - Parameter mainSwitch: main switch model to holde the required properties
    - Parameter goPaySwitch: goPay switch model to holde the required properties
    - Parameter merchantSwitch: merchantSwitch switch model to holde the required properties
    */
//    public init(mainSwitch: TapSwitchModel, goPaySwitch: TapSwitchModel, merchantSwitch: TapSwitchModel) {
//        self.mainSwitch = mainSwitch
//        self.goPaySwitch = goPaySwitch
//        self.merchantSwitch = merchantSwitch
//    }
    
    // MARK: Create Switches
    private func configureSwitches() {
        self.mainSwitch = TapSwitchModel(localisedSwitchKey: (cardState == .validCard || cardState == .invalidCard) ? "mainCards" : "mainTelecom")
        self.mainSwitch.title = cardState.mainLocalisedTitle()
        self.goPaySwitch = TapSwitchModel(localisedSwitchKey: "goPay")
        self.merchantSwitch = TapSwitchModel(localisedSwitchKey: "merchant", merchant: merchant)
        
//        self.updateCardState()
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
    
    // MARK: Card State
    /**
     Update main switch depending on the card state change
     */
    func updateCardState() {
        self.mainSwitch.title = cardState.mainLocalisedTitle()//update(localisedSwitchKey: (cardState == .validCard || cardState == .invalidCard) ? "mainCards" : "mainTelecom")
        self.viewDelegate?.updateSwitchesText()
        switch cardState {
        case .invalidCard, .invalidTelecom:
            self.updateMainSwitchState(isOn: false)
            self.viewDelegate?.hideMainSwitch()
        case .validCard, .validTelecom:
            self.viewDelegate?.showMainSwitch()
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
        self.updateCardState()
        return tapSwitchView
    }
}
