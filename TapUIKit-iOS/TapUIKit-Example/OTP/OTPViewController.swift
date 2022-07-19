//
//  OTPViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 7/16/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class OTPViewController: UIViewController {

    @IBOutlet weak var otpView: TapSwitchView!//TapOtpView!
    let otpViewModel: TapSwitchViewModel = .init(with: .invalidCard, merchant: "jazeera airways", whichSwitchesToShow: .all)
//        .init(mainSwitch: TapSwitchModel(title: "For faster and easier checkout,save your mobile number.", subtitle: ""), goPaySwitch: TapSwitchModel(title: "Save for goPay Checkouts", subtitle: "By enabling goPay, your mobile number will be saved with Tap Payments to get faster and more secure checkouts in multiple apps and websites."))
//        
//        .init(mainSwitch: TapSwitchModel(title: "For faster and easier checkout,save your mobile number.", subtitle: ""),
//        goPaySwitch: TapSwitchModel(title: "Save for goPay Checkouts", subtitle: "By enabling goPay, your mobile number will be saved with Tap Payments to get faster and more secure checkouts in multiple apps and websites.", notes: "Please check your email or SMS’s in order to complete the goPay Checkout signup process."),
//        merchantSwitch: TapSwitchModel(title: "Save for [merchant_name] Checkouts", subtitle: ""))
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        otpViewModel.updateTimer(minutes: 0, seconds: 50)
        otpView.setup(with: otpViewModel)
//        print(otpViewModel.goPaySwitch?.isOn)
//        print(otpViewModel.mainSwitch.isOn)
//        print(otpViewModel.merchantSwitch?.isOn)
        
        otpViewModel.delegate = self
//        otpViewModel.updateTimer(minutes: 0, seconds: 50)
        
        //otpViewModel.delegate = self
        // Do any additional setup after loading the view.
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

extension OTPViewController: TapSwitchViewModelDelegate {
    func didChangeState(state: TapSwitchEnum, enabledSwitches: TapSwitchEnum) {
        print("current card State: \(state.rawValue)")
    }
    
    func didChangeCardState(cardState: TapSwitchCardStateEnum) {
        print("current card State: \(cardState.rawValue)")
    }
    
    func didChangeState(state: TapSwitchEnum) {
        print("current state: \(state.rawValue)")
    }
}
