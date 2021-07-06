//
//  TapCardInputViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 7/6/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS
import TapCardInputKit_iOS
import CommonDataModelsKit_iOS
import LocalisationManagerKit_iOS
import TapCardVlidatorKit_iOS

class TapCardInputViewController: UIViewController {
    @IBOutlet weak var cardInput: TapCardInput!
    
    @IBOutlet weak var delegateTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cardInput.delegate = self
        cardInput.setup(for: .InlineCardInput)
        
    }
    

    @IBAction func oneBrandSwitchChanged(_ sender: Any) {
        guard let uiSwitch:UISwitch = sender as? UISwitch else { return }
        cardInput.reset()
        if uiSwitch.isOn {
            cardInput.setup(for: .InlineCardInput,allowedCardBrands: [CardBrand.visa.rawValue],cardIconUrl: "https://img.icons8.com/color/2x/visa.png")
        }else {
            cardInput.setup(for: .InlineCardInput)
        }
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

extension TapCardInputViewController: TapCardInputProtocol {
    func shouldAllowChange(with cardNumber: String) -> Bool {
        return true
    }
    
    
    func dataChanged(tapCard: TapCard) {
        
    }
    
    
    func brandDetected(for cardBrand: CardBrand, with validation: CrardInputTextFieldStatusEnum) {
        delegateTextView.text = "Validation status : \(validation.toString())\n\(delegateTextView.text ?? "")\n";
    }
    
    
    func saveCardChanged(enabled: Bool) {
        delegateTextView.text = "SAVE CARD isENABLED : \(enabled)\n\(delegateTextView.text ?? "")\n";
    }
    
    
    func cardDataChanged(tapCard: TapCard) {
       delegateTextView.text = "Card Number : \(tapCard.tapCardNumber ?? "")\nCard Name : \(tapCard.tapCardName ?? "")\nCard Expiry : \(tapCard.tapCardExpiryMonth ?? "")/\(tapCard.tapCardExpiryYear ?? "")\nCard CVV : \(tapCard.tapCardCVV ?? "")\n\(delegateTextView.text ?? "")\n"
    }
    
    func scanCardClicked() {
        delegateTextView.text = "SCAN CLICKED\n\(delegateTextView.text ?? "")\n";
    }
    
    
}

extension CrardInputTextFieldStatusEnum {
    func toString() -> String {
        switch self {
            case .Invalid:
                return "Invalid"
            case .Incomplete:
                return "Incomplete"
            case .Valid:
                return "Valid"
            case .isEditing:
                return "Incomplete"
        }
    }
}
