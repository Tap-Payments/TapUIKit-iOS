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
    let otpViewModel: TapSwitchViewModel = .init()//TapOtpViewModel = .init(phoneNo: "50393828", showMessage: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        otpViewModel.updateTimer(minutes: 0, seconds: 50)
        otpView.setup(with: otpViewModel)
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
