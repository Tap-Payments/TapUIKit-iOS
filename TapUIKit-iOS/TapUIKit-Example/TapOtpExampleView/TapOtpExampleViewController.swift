//
//  TapOtpExampleViewController.swift
//  TapUIKit-Example
//
//  Created by Kareem Ahmed on 7/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class TapOtpExampleViewController: UIViewController {

    @IBOutlet weak var tapOtpView: TapOtpView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func setupOtp() {
        let otpViewModel: TapOtpViewModel = .init()
        let otpView: TapOtpView = otpViewModel.createOtpView()
        otpViewModel.updateTimer(minutes: 0, seconds: 70)
    }

}
