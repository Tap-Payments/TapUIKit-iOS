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
    var itemModel:ItemModel = try! .init(from: ["title":"Item Title","description":"Item Description","price":1500.5,"quantity":1])
    var tapTableViewModel:TapGenericTableViewModel = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
