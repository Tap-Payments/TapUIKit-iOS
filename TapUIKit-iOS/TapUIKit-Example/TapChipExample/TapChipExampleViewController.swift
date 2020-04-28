//
//  TapChipExampleViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 28/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class TapChipExampleViewController: UIViewController {

    @IBOutlet weak var tapChip: TapChip!
    @IBOutlet weak var tapChip2: TapChip!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let leftAccessory:TapChipAccessoryView = TapChipAccessoryView(image: UIImage(named: "visa")) { (tapChip) in
            tapChip.showShadow(glowing: true)
        }
        let rightAccessory:TapChipAccessoryView = TapChipAccessoryView(image: UIImage(named: "mastercard"))  { (tapChip) in
            tapChip.showShadow(glowing: false)
        }
        tapChip.setup(contentString: "∙∙∙∙ 1234", rightAccessory: rightAccessory)
        
        tapChip2.setup(contentString: "∙∙∙∙ 1234∙∙∙∙ 1234",leftAccessory: leftAccessory)
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
