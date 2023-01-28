//
//  CustomerDataViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 03/11/2022.
//  Copyright © 2022 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class CustomerDataViewController: UIViewController {

    @IBOutlet weak var customerDataCollectionViw: CustomerDataCollectionView!
    let customerDataViewModel = CustomerContactDataCollectionViewModel.init(toBeCollectedData: [.email,.phone], allowedCountries: [.EG,.KW,.SA,.BH,.AE,.OM,.QA,.JO,.LB], selectedCountry: .EG)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customerDataCollectionViw.setupView(with: customerDataViewModel)
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
