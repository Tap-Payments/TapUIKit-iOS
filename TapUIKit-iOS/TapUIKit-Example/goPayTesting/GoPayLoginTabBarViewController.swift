//
//  GoPayLoginTabBarViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 7/15/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class GoPayLoginTabBarViewController: UIViewController {

    @IBOutlet weak var goPayLoginBar: TapGoPayLoginBarView!
    let goPayBarViewModel:TapGoPayLoginBarViewModel = .init(countries: [.init(nameAR: "الكويت", nameEN: "Kuwait", code: "965", phoneLength: 8)])
    
    @IBOutlet weak var validSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        goPayBarViewModel.delegate = self
        goPayLoginBar.setup(with: goPayBarViewModel)
    }
    @IBAction func validChanged(_ sender: Any) {
        goPayBarViewModel.changeSelectionValidation(to: validSwitch.isOn)
    }
}

extension GoPayLoginTabBarViewController: TapGoPayLoginBarViewModelDelegate {
    func loginOptionSelected(with viewModel: TapGoPayTitleViewModel) {
        print(viewModel.titleStatus)
        validSwitch.setOn(false, animated: true)
    }
}
