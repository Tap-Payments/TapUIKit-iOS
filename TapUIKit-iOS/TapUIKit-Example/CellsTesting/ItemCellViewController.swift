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
    var itemPrice:Double = 1500.5
    var itemQuantity:Int = 1
    var itemDiscount:DiscountModel? = nil
    
    var tapTableViewModel:TapGenericTableViewModel = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTheViewModel()
    }
    
    
    @IBAction func showDescriptionChanged(_ sender: Any) {
        guard let uiswitch:UISwitch = sender as? UISwitch else { return }
        
        itemDescriptio = uiswitch.isOn ? "Item Description" : ""
        configureTheViewModel()
        
    }
    @IBAction func showDiscountChanged(_ sender: Any) {
        guard let uiswitch:UISwitch = sender as? UISwitch else { return }
        
        itemDiscount = nil
        
        if uiswitch.isOn {
            itemDiscount = .init(type:DiscountType.Fixed,value:100.200)
        }
        
        
        configureTheViewModel()
        
        
    }
    private func configureTheViewModel() {
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
