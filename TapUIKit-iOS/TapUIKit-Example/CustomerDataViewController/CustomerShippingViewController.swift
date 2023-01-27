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
    //let customerDataViewModel = CustomerContactDataCollectionViewModel.init(toBeCollectedData: [.email], allowedCountries: [.init(nameAR: "الكويت", nameEN: "Kuwait", code: "965", phoneLength: 8),.init(nameAR: "مصر", nameEN: "Egypt", code: "20", phoneLength: 10)], selectedCountry: .init(nameAR: "الكويت", nameEN: "Kuwait", code: "965", phoneLength: 8))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //customerDataCollectionViw.setupView(with: customerDataViewModel)
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
