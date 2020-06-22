//
//  ItemCellViewController.swift
//  TapUIKit-Example
//
//  Created by Osama Rabie on 6/21/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

import UIKit
import TapUIKit_iOS

class ItemCellViewController: UIViewController {
    @IBOutlet weak var tabGenericTable: TapGenericTableView!
    
    var itemTitle:String = "Item Title"
    var itemDescriptio:String = "Item Description"
    var itemPrice:Double = 1500
    var itemQuantity:Int = 1
    var itemDiscountValue:Double = 0
    var itemDiscount:DiscountModel? = nil
    
    var tapTableViewModel:TapGenericTableViewModel = .init()
    
    @IBOutlet weak var discountTypeSegmern: UISegmentedControl!
    @IBOutlet weak var discountValueSlider: UISlider!
    @IBOutlet weak var discountAmountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTheViewModel()
    }
    
    
    @IBAction func showDescriptionChanged(_ sender: Any) {
        guard let uiswitch:UISwitch = sender as? UISwitch else { return }
        
        itemDescriptio = uiswitch.isOn ? "Item Description" : ""
        configureTheViewModel()
        
    }
    @IBAction func quantityStepper(_ sender: Any) {
        guard let stepper:UIStepper = sender as? UIStepper else { return }
        itemQuantity = Int(stepper.value)
        configureTheViewModel()
    }
    @IBAction func showDiscountChanged(_ sender: Any) {
        guard let uiswitch:UISwitch = sender as? UISwitch else { return }
        
        itemDiscount = nil
        
        discountTypeSegmern.isUserInteractionEnabled = uiswitch.isOn
        discountValueSlider.isUserInteractionEnabled = uiswitch.isOn
        
        configureTheViewModel()
        
        
    }
    @IBAction func discountTypeChanged(_ sender: Any) {
        guard let segment:UISegmentedControl = sender as? UISegmentedControl else { return }
        if segment == discountTypeSegmern {
            discountValueSlider.setValue(0, animated: true)
            discountValueSlider.maximumValue = segment.selectedSegmentIndex == 0 ? 1000 : 99
            configureTheViewModel()
        }
    }
    @IBAction func discountSliderChanged(_ sender: Any) {
        guard let slider:UISlider = sender as? UISlider else { return }
        if slider == discountValueSlider {
            discountAmountLabel.text = "Discount amount : \(slider.value) \(discountTypeSegmern.selectedSegmentIndex == 0 ? "" : "%")"
            configureTheViewModel()
        }
    }
    private func configureTheViewModel() {
        if discountValueSlider.isUserInteractionEnabled {
            let discountType:DiscountType = discountTypeSegmern.selectedSegmentIndex == 0 ? .Fixed : .Percentage
            itemDiscount = .init(type: discountType, value: Double(discountValueSlider.value))
        }else{
            itemDiscount = nil
        }
        let itemModel:ItemModel = .init(title: itemTitle, description: itemDescriptio, price: itemPrice, quantity: itemQuantity, discount: itemDiscount)
        //try! .init(from: ["title":itemTitle,"description":itemDescriptio
            //,"price":itemPrice,"quantity":itemQuantity])
        let itemCellViewModel:ItemCellViewModel = .init(itemModel: itemModel, originalCurrency: .KWD)
        tapTableViewModel.dataSource = [itemCellViewModel]
        tabGenericTable.changeViewMode(with: tapTableViewModel)
    }
}


extension Decodable {
    init(from: Any) throws {
        let data = try JSONSerialization.data(withJSONObject: from, options: .prettyPrinted)
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:sszzz"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        self = try decoder.decode(Self.self, from: data)
    }
}
