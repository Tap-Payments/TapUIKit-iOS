//
//  TapCardPhoneBarListViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 6/29/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS
import enum TapCardVlidatorKit_iOS.CardBrand

class TapCardPhoneBarListViewController: UIViewController {

    
    @IBOutlet weak var iconsNumberLabel: UILabel!
    @IBOutlet weak var iconsStepper: UIStepper!
    @IBOutlet weak var tapCardPhoneListView: TapCardPhoneBarList!
    @IBOutlet weak var selectionSwitch: UISegmentedControl!
    let tapCardPhoneListViewModel:TapCardPhoneBarListViewModel = .init()
    var dataSource:[TapCardPhoneIconViewModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.append(.init(associatedCardBrand: .visa, tapCardPhoneIconUrl: "https://img.icons8.com/color/2x/visa.png"))
        dataSource.append(.init(associatedCardBrand: .masterCard, tapCardPhoneIconUrl: "https://img.icons8.com/color/2x/mastercard.png"))
        dataSource.append(.init(associatedCardBrand: .americanExpress, tapCardPhoneIconUrl: "https://img.icons8.com/color/2x/amex.png"))
        dataSource.append(.init(associatedCardBrand: .mada, tapCardPhoneIconUrl: "https://i.ibb.co/S3VhxmR/796px-Mada-Logo-svg.png"))
        dataSource.append(.init(associatedCardBrand: .viva, tapCardPhoneIconUrl: "https://i.ibb.co/cw5y89V/unnamed.png"))
        dataSource.append(.init(associatedCardBrand: .wataniya, tapCardPhoneIconUrl: "https://i.ibb.co/PCYd8Xm/ooredoo-3x.png"))
        dataSource.append(.init(associatedCardBrand: .zain, tapCardPhoneIconUrl: "https://i.ibb.co/mvkJXwF/zain-3x.png"))
        
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
    @IBAction func selectionSwitchChanged(_ sender: Any) {
        
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
