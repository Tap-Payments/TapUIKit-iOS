//
//  TapCardPhoneBarListViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 6/29/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class TapCardPhoneBarListViewController: UIViewController {

    
    @IBOutlet weak var iconsNumberLabel: UILabel!
    @IBOutlet weak var iconsStepper: UIStepper!
    @IBOutlet weak var tapCardPhoneListView: TapCardPhoneBarList!
    let tapCardPhoneListViewModel:TapCardPhoneBarListViewModel = .init()
    var dataSource:[TapCardPhoneIconViewModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.append(.init(tapCardPhoneIconUrl: "https://img.icons8.com/color/2x/visa.png"))
        dataSource.append(.init(tapCardPhoneIconUrl: "https://img.icons8.com/color/2x/mastercard.png"))
        dataSource.append(.init(tapCardPhoneIconUrl: "https://img.icons8.com/color/2x/amex.png"))
        dataSource.append(.init(tapCardPhoneIconUrl: "https://img.icons8.com/officel/2x/nfc-sign.png"))
        dataSource.append(.init(tapCardPhoneIconUrl: "https://img.icons8.com/officel/2x/bluetooth.png"))
        dataSource.append(.init(tapCardPhoneIconUrl: "https://img.icons8.com/color/2x/mac-os.png"))
        dataSource.append(.init(tapCardPhoneIconUrl: "https://img.icons8.com/cotton/2x/apple-pay.png"))
        dataSource.append(.init(tapCardPhoneIconUrl: "https://img.icons8.com/color/2x/icloud.png"))
        
        tapCardPhoneListView.setupView(with: tapCardPhoneListViewModel)
        
        tapCardPhoneListViewModel.dataSource = Array(dataSource.prefix(upTo: 3))
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
        
    }
    
    @IBAction func iconsStepperChanged(_ sender: Any) {
        guard sender as? UIStepper == iconsStepper else { return }
        
        iconsNumberLabel.text = "# icons : \(iconsStepper.value)"
        tapCardPhoneListViewModel.dataSource = Array(dataSource.prefix(upTo: Int(iconsStepper.value)))
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
