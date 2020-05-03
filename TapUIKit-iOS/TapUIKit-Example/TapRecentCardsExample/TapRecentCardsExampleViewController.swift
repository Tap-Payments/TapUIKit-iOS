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
    lazy var lang:String = "en"
    @IBOutlet weak var callBackTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel:TapCardsCollectionViewModel = .init(with: [TapGoPayCellViewModel(),TapCardRecentCardCellViewModel(leftAccessoryImage: UIImage(named: "visa"), bodyContent: "123 456"),TapCardRecentCardCellViewModel(leftAccessoryImage: UIImage(named: "mastercard"), bodyContent: "789 012"),TapCardRecentCardCellViewModel(leftAccessoryImage: UIImage(named: "mastercard"), bodyContent: "789 012")])
        tapRecentCardsView.setup(with: viewModel)
        
        viewModel.delegate = self
    }
}


extension TapRecentCardsExampleViewController: TapCardsCollectionProtocol {
    func editRecentCardsClicked() {
        print("EDIT CLICKED")
        callBackTextView.text = "EDIT CLICKED\n\(callBackTextView.text ?? "")"
    }
    
    func recentCardClicked(with viewModel: TapCardRecentCardCellViewModel) {
        print("CARD CLICKED : \(viewModel.bodyContent)")
        callBackTextView.text = "CARD CLICKED : \(viewModel.bodyContent)\n\(callBackTextView.text ?? "")"
    }
    
    func goPayClicked(with viewModel: TapGoPayCellViewModel) {
        print("GO PAY CLICKED")
        callBackTextView.text = "GO PAY CLICKED\n\(callBackTextView.text ?? "")"
    }
}
