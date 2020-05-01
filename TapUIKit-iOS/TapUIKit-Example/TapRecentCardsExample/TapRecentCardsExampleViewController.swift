//
//  TapRecentCardsExampleViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 30/04/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class TapRecentCardsExampleViewController: UIViewController {

    @IBOutlet weak var tapRecentCardsView: TapRecentCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel:TapCardsCollectionViewModel = .init(with: [TapGoPayCellViewModel(),TapSeparatorViewModel(),TapCardRecentCardCellViewModel(leftAccessoryImage: UIImage(named: "visa"), bodyContent: "123 456"),TapCardRecentCardCellViewModel(leftAccessoryImage: UIImage(named: "mastercard"), bodyContent: "789 012"),TapCardRecentCardCellViewModel(leftAccessoryImage: UIImage(named: "mastercard"), bodyContent: "789 012")])
        //let viewModel:TapCardsCollectionViewModel = .init(with: [TapGoPayCellViewModel()])
        // Do any additional setup after loading the view.
        tapRecentCardsView.setup(with: viewModel)
        
        viewModel.delegate = self
    }
}


extension TapRecentCardsExampleViewController: TapCardsCollectionProtocol {
    func recentCardClicked(with viewModel: TapCardRecentCardCellViewModel) {
        print("CARD CLICKED : \(viewModel.bodyContent)")
    }
    
    func goPayClicked(with viewModel: TapGoPayCellViewModel) {
        print("GO PAY CLICKED")
    }
}
