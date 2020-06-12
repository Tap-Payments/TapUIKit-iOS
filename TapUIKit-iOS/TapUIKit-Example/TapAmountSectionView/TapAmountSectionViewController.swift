//
//  TapAmountSectionViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 6/12/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS
import CommonDataModelsKit_iOS

class TapAmountSectionViewController: UIViewController {

    @IBOutlet weak var tapAmountSectionView: TapAmountSectionView!
    var viewModel:TapAmountSectionViewModel = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDefaultViewModel()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tapAmountSectionView.changeViewModel(with: viewModel)
    }
    
    
    func createDefaultViewModel() {
        viewModel = .init(originalTransactionAmount: 10000.25, originalTransactionCurrency: .KWD)
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
