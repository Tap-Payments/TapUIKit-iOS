//
//  GoPayPasswordViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 7/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class GoPayPasswordViewController: UIViewController {
    
    @IBOutlet weak var goPayPasswordField: TapGoPayPasswordTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        goPayPasswordField.delegate = self
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

extension GoPayPasswordViewController:TapGoPayPasswordTextFieldProtocol {
    func passwordChanged(to password: String) {
        
    }
    
    func returnClicked(with password: String) {
        
    }
}
