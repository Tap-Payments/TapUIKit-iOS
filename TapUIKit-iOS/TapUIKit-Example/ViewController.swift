//
//  ViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 27/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class ViewController: UIViewController {
    
    @IBOutlet weak var tapChip: TapChip!
    @IBOutlet weak var tapChip2: TapChip!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let leftAccessory:TapChipAccessoryView = TapChipAccessoryView(image: UIImage(named: "visa")) { (tapChip) in
            tapChip.showShadow(glowing: true)
        }
        let rightAccessory:TapChipAccessoryView = TapChipAccessoryView(image: UIImage(named: "mastercard"))  { (tapChip) in
            tapChip.showShadow(glowing: false)
        }
        tapChip.setup(contentString: "∙∙∙∙ 1234", rightAccessory: rightAccessory)
        
        tapChip2.setup(contentString: "∙∙∙∙ 1234∙∙∙∙ 1234",leftAccessory: leftAccessory)
    }
    
    
}

