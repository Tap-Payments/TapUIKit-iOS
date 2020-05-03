//
//  TapRecentCardsViewExampleViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 03/05/2020.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS
import LocalisationManagerKit_iOS
import MOLH

class TapRecentCardsViewExampleViewController: UIViewController {

    @IBOutlet weak var callBackTextView: UITextView!
    @IBOutlet weak var tapRecentCardsView: TapRecentCardsView!
    lazy var lang:String = "en"
    /// Configure the localisation Manager
    let sharedLocalisationManager = TapLocalisationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sharedLocalisationManager.localisationLocale = MOLHLanguage.currentAppleLanguage().lowercased()
        let viewModel:TapCardsCollectionViewModel = .init(with: [TapGoPayCellViewModel(),TapCardRecentCardCellViewModel(leftAccessoryImage: UIImage(named: "visa"), bodyContent: "123 456"),TapCardRecentCardCellViewModel(leftAccessoryImage: UIImage(named: "mastercard"), bodyContent: "789 012"),TapCardRecentCardCellViewModel(leftAccessoryImage: UIImage(named: "mastercard"), bodyContent: "789 012")])
        viewModel.delegate = self
        tapRecentCardsView.setup(with: viewModel)
        tapRecentCardsView.localize(shouldFlip:true)
    }
}

extension TapRecentCardsViewExampleViewController: TapCardsCollectionProtocol {
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
