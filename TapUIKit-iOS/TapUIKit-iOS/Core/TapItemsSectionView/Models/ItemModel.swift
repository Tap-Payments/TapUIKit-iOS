/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
/// Represent the model of an ITEM inside an order/transaction
@objc public class ItemModel : NSObject, Codable {
    
    /// The title of the item
	let title : String?
    /// A description of the item
	let itemDescription : String?
    /// The raw original price in the original currency
	let price : Double?
    /// The quantity added to this item
	let quantity : Int?
    /// The discount applied to the item's price
	let discount : DiscountModel?

    
    /**
     - Parameter title: The title of the item
     - Parameter description: A description of the item
     - Parameter price: The raw original price in the original currency
     - Parameter quantity: The quantity added to this item
     - Parameter discount: The discount applied to the item's price
     
     */
    @objc public init(title: String?, description: String?, price: Double = 0, quantity: Int = 0, discount: DiscountModel?) {
        self.title = title
        self.itemDescription = description
        self.price = price
        self.quantity = quantity
        self.discount = discount
    }
    
	enum CodingKeys: String, CodingKey {

		case title = "title"
		case itemDescription = "description"
		case price = "price"
		case quantity = "quantity"
		case discount = "discount"
	}

    required public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		title = try values.decodeIfPresent(String.self, forKey: .title)
		itemDescription = try values.decodeIfPresent(String.self, forKey: .itemDescription)
		price = try values.decodeIfPresent(Double.self, forKey: .price)
		quantity = try values.decodeIfPresent(Int.self, forKey: .quantity)
		discount = try values.decodeIfPresent(DiscountModel.self, forKey: .discount)
	}
    
    /**
     Holds the logic to calculate the final price of the item based on price, quantity and discount
     - Returns: The total price of the item as follows : (itemPrice-discount) * quantity
     */
    internal func itemFinalPrice() -> Double {
        
        // Defensive coding, make sure all values are set
        guard let price = price else { return 0 }
        
        // First apply the discount if any
        var discountedItemPrice:Double = discount?.caluclateActualDiscountedValue(with: price) ?? price
        
        // Put in the quantity in action
        discountedItemPrice = discountedItemPrice * Double(quantity ?? 1)
        
        return discountedItemPrice
        
    }
    
}
