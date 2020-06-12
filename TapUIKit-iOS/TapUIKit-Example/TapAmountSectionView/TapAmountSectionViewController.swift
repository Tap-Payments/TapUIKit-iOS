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
    @IBOutlet weak var amountsSwitch: UISwitch!
    @IBOutlet weak var itemsSwitch: UISwitch!
    @IBOutlet weak var convertSwitch: UISwitch!
    @IBOutlet weak var originalCurrencyButton: UIButton!
    @IBOutlet weak var convertedCurrencyButton: UIButton!
    @IBOutlet weak var originalAmountTextField: UITextField!
    @IBOutlet weak var convertedTextField: UITextField!
    
    var oiginalAmount:Double = 10000 {
        didSet {
            viewModel.originalTransactionAmount = oiginalAmount
        }
    }
    var oiginalCurrency:TapCurrencyCode = .USD {
        didSet {
            viewModel.originalTransactionCurrency = oiginalCurrency
        }
    }
    var convertedAmount:Double = 3333.333 {
        didSet {
            viewModel.convertedTransactionAmount = convertedAmount
        }
    }
    var convertedCurrency:TapCurrencyCode? = .KWD {
        didSet {
            viewModel.convertedTransactionCurrency = convertedCurrency
        }
    }
    var numberOfItems:Int = 10 {
        didSet {
            viewModel.numberOfItems = numberOfItems
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDefaultViewModel()
        originalAmountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        convertedTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tapAmountSectionView.changeViewModel(with: viewModel)
    }
    
    
    func createDefaultViewModel() {
        viewModel = .init(originalTransactionAmount: oiginalAmount, originalTransactionCurrency: oiginalCurrency, convertedTransactionAmount: convertedAmount, convertedTransactionCurrency: convertedCurrency, numberOfItems: numberOfItems)
    }
    
    @IBAction func currencySelectionClicked(_ sender: Any) {
        
        guard let button:UIButton = sender as? UIButton else { return }
        
        let (title,tag) = (button == originalCurrencyButton) ?  ("Original Currency",1) : ("Convert Currency",2)
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 300)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        pickerView.delegate = self
        pickerView.dataSource = self
        vc.view.addSubview(pickerView)
        let allCurriences:[TapCurrencyCode] = TapCurrencyCode.allCases
        
        let editRadiusAlert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        editRadiusAlert.setValue(vc, forKey: "contentViewController")
        editRadiusAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            if tag == 1 {
                self?.oiginalCurrency = allCurriences[pickerView.selectedRow(inComponent: 0)]
            }else if tag == 2 {
                self?.convertedCurrency = allCurriences[pickerView.selectedRow(inComponent: 0)]
            }
        }))
        editRadiusAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(editRadiusAlert, animated: true)
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        guard let swtch:UISwitch = sender as? UISwitch else { return }
        
        if swtch == amountsSwitch {
            viewModel.shouldShowAmount = swtch.isOn
        }else if swtch == itemsSwitch {
            viewModel.shouldShowItems = swtch.isOn
        }else if swtch == convertSwitch {
            convertedCurrency = swtch.isOn ? (convertedCurrency ?? .KWD) : nil
            convertedAmount = swtch.isOn ? ( convertedAmount > 0 ? convertedAmount : 3333.333) : 0
            convertedTextField.isUserInteractionEnabled = swtch.isOn
            convertedCurrencyButton.isUserInteractionEnabled = swtch.isOn
        }
    }
    
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == convertedTextField {
            convertedAmount = Double(textField.text ?? "0") ?? 0
        }else if textField == originalAmountTextField {
            oiginalAmount = Double(textField.text ?? "0") ?? 0
        }
    }
}


extension TapAmountSectionViewController:UIPickerViewDataSource,UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TapCurrencyCode.allCases.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let allCurriences:[TapCurrencyCode] = TapCurrencyCode.allCases
        return allCurriences[row].appleRawValue
    }
    
    
    
    // usually i can use this code to remove keyboard if we touch other area
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
}

