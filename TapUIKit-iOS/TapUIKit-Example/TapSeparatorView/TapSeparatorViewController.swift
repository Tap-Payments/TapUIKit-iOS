//
//  TapSeparatorViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 6/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class TapSeparatorViewController: UIViewController {

    @IBOutlet weak var separatorView: TapSeparatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func animateSwitch(_ sender: Any) {
        
        guard let animateSwitch = sender as? UISwitch else { return }
        
        separatorView.changeWidth(with: animateSwitch.isOn ? 0 : 20)
        
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
