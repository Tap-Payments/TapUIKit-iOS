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
        tapRecentCardsView.setup(with: viewModel)
        tapRecentCardsView.localize(shouldFlip:true)
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
