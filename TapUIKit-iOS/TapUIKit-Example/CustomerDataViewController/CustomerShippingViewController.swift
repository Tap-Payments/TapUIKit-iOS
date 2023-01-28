//
//  CustomerShippingViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 27/01/2023.
//  Copyright © 2023 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class CustomerShippingViewController: UIViewController {

    @IBOutlet weak var customerDataCollectionViw: CustomerShippingDataCollectionView!
    let customerDataViewModel = CustomerShippingDataCollectionViewModel.init(allowedCountries: TapCountryCode.allCases, selectedCountry: .EG)
    
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
