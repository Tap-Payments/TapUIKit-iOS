//
//  TapLoyaltyViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 13/09/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//
import UIKit
import TapUIKit_iOS

class TapLoyaltyViewController: UIViewController {

    @IBOutlet weak var loyaltyView: TapLoyaltyView!
    
    
    
    var loyaltyViewModel:TapLoyaltyViewModel = TapLoyaltyViewModel.init(loyaltyModel: .init(id: "", bankName: "ADCB", bankLogo: "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/78/00/ed/7800edd0-5854-b6ce-458f-dfcf75caa495/AppIcon-0-0-1x_U007emarketing-0-0-0-5-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/1024x1024.jpg", loyaltyProgramName: "ADCB TouchPoints", loyaltyPointsName: "TouchPoints", termsConditionsLink: "https://www.adcb.com/en/personal/adcb-for-you/touchpoints/touchpoints-rewards.aspx", supportedCurrencies: [.init(currency: AmountedCurrency.init(.AED, 300, "", 2, 50), balanceAmount: 500, minimumAmount: 100)], transactionsCount: "25.000"), amount: 300, transactionTotalAmount:300, currency: .AED)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loyaltyView.changeViewModel(with: loyaltyViewModel)
        
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
