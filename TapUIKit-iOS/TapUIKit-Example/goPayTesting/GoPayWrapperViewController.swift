//
//  GoPayWrapperViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 7/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS
import TapCardScanner_iOS

class GoPayWrapperViewController: UIViewController {

    @IBOutlet weak var signGoPayView: TapGoPaySignInView!
    let goPayBarViewModel:TapGoPayLoginBarViewModel = .init(countries: [.init(nameAR: "الكويت", nameEN: "Kuwait", code: "965", phoneLength: 8)])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signGoPayView.setup(with: goPayBarViewModel)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let blurEffectView: VisualEffectView = .init(frame: view.frame)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.tag = 1010
        blurEffectView.colorTint = try! UIColor(tap_hex: "#f9f9f9")
        blurEffectView.colorTintAlpha = 0.8
        blurEffectView.blurRadius = 10
        blurEffectView.scale = 1
        //view.addSubview(blurEffectView)
        //view.sendSubviewToBack(blurEffectView)
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
