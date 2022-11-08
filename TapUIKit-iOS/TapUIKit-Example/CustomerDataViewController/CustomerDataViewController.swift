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
    let customerDataViewModel = CustomerContactDataCollectionViewModel.init(toBeCollectedData: [.email], allowedCountries: [.init(nameAR: "الكويت", nameEN: "Kuwait", code: "965", phoneLength: 8)], selectedCountry: .init(nameAR: "الكويت", nameEN: "Kuwait", code: "965", phoneLength: 8))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customerDataCollectionViw.setupView(with: customerDataViewModel)
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
