//
//  TapCardPhoneIconViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 6/28/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class TapCardPhoneIconViewController: UIViewController {

    @IBOutlet weak var tapCardPhoneIconVie: TapCardPhoneIconView!
    let tapCardPhoneViewModel:TapCardPhoneIconViewModel = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapCardPhoneIconVie.setupView(with: tapCardPhoneViewModel)
        tapCardPhoneViewModel.tapCardPhoneIconUrl = "https://img.icons8.com/color/2x/visa.png"
        //tapCardPhoneViewModel.tapCardPhoneIconStatus = .selected
        // Do any additional setup after loading the view.
    }
    
    @IBAction func statusChanged(_ sender: Any) {
        guard let segment:UISegmentedControl = sender as? UISegmentedControl else { return }
        
        
        switch segment.selectedSegmentIndex {
        case 0:
            tapCardPhoneViewModel.tapCardPhoneIconStatus = .selected
        case 1:
            tapCardPhoneViewModel.tapCardPhoneIconStatus = .otherSegmentSelected
        case 2:
            tapCardPhoneViewModel.tapCardPhoneIconStatus = .otherIconIsSelected
        default:
            return
        }
        
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
