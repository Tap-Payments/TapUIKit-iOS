//
//  GoPayWrapperViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 7/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class GoPayWrapperViewController: UIViewController {

    @IBOutlet weak var signGoPayView: TapGoPaySignInView!
    let goPayBarViewModel:TapGoPayLoginBarViewModel = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signGoPayView.setup(with: goPayBarViewModel,and: .init(nameAR: "الكويت", nameEN: "Kuwait", code: "965", phoneLength: 8))
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
