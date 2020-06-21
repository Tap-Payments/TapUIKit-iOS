/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
/// Represent the model of an ITEM inside an order/transaction
public struct ItemModel : Codable {
    /// The title of the item
	let title : String?
    /// A description of the item
	let description : String?
    /// The raw original price in the original currency
	let price : Double?
    /// The quantity added to this item
	let quantity : Double?
    /// The discount applied to the item's price
	let discount : DiscountModel?

	enum CodingKeys: String, CodingKey {

		case title = "title"
		case description = "description"
		case price = "price"
		case quantity = "quantity"
		case discount = "discount"
	}

	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		title = try values.decodeIfPresent(String.self, forKey: .title)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		price = try values.decodeIfPresent(Double.self, forKey: .price)
		quantity = try values.decodeIfPresent(Double.self, forKey: .quantity)
		discount = try values.decodeIfPresent(DiscountModel.self, forKey: .discount)
	}
}
