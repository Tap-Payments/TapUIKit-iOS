//
//  TapMerchantHeaderViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 6/9/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS
import MOLH

class TapMerchantHeaderViewController: UIViewController {

    @IBOutlet weak var tapMerchantHeaderView: TapMerchantHeaderView!
    @IBOutlet weak var merchantNameTextField: UITextField!
    @IBOutlet weak var merchantLogoTextField: UITextField!
    
    var viewModel:TapMerchantHeaderViewModel = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDefaultViewModel()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tapMerchantHeaderView.changeViewModel(with: viewModel)
    }
    
    
    func createDefaultViewModel() {
        viewModel = .init(subTitle: "Tap Payments", iconURL: "https://avatars3.githubusercontent.com/u/19837565?s=200&v=4")
    }
    
    @IBAction func resetDefaultClicked(_ sender: Any) {
        createDefaultViewModel()
        tapMerchantHeaderView.changeViewModel(with: viewModel)
    }
    
    @IBAction func applyChangesClicked(_ sender: Any) {
        viewModel = .init(subTitle: merchantNameTextField.text ?? "", iconURL: merchantLogoTextField.text ?? "")
        tapMerchantHeaderView.changeViewModel(with: viewModel)
    }
}


extension TapMerchantHeaderViewController {
    
    // usually i can use this code to remove keyboard if we touch other area
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
}
