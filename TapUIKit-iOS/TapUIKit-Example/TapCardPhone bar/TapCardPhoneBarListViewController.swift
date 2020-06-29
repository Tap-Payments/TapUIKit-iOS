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

    
    @IBOutlet weak var tapCardPhoneListView: TapCardPhoneBarList!
    let tapCardPhoneListViewModel:TapCardPhoneBarListViewModel = .init()
    var dataSource:[TapCardPhoneIconViewModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.append(.init(tapCardPhoneIconUrl: "https://img.icons8.com/color/2x/visa.png"))
        dataSource.append(.init(tapCardPhoneIconUrl: "https://img.icons8.com/color/2x/mastercard.png"))
        dataSource.append(.init(tapCardPhoneIconUrl: "https://img.icons8.com/color/2x/amex.png"))
        
        tapCardPhoneListView.setupView(with: tapCardPhoneListViewModel)
        
        tapCardPhoneListViewModel.dataSource = dataSource
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
        
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
