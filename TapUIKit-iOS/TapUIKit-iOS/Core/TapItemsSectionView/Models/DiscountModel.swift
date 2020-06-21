/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
/// Represent the model of a dicount object for an item
public struct DiscountModel : Codable {
    /// The type of the applied discount whether fixed or percentage
	let type : DiscountType?
    /// The value of the discount itself
	let value : Double?

	enum CodingKeys: String, CodingKey {

		case type = "type"
		case value = "value"
	}

	public init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		type = try values.decodeIfPresent(DiscountType.self, forKey: .type)
		value = try values.decodeIfPresent(Double.self, forKey: .value)
	}
}



/// Represent an enum to decide all the possible discount types
public enum DiscountType: Codable {
    /// Meaning, the discount will be a percentage of the item's price
    case Percentage
    /// Meaning, the discount will be a fixed value to be deducted as is
    case Fixed
    
    enum Key: CodingKey {
        case rawValue
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(String.self, forKey: .rawValue)
        switch rawValue.lowercased() {
        case "percentage":
            self = .Percentage
        case "fixed":
            self = .Fixed
        default:
            throw CodingError.unknownValue
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .Percentage:
            try container.encode("Percentage", forKey: .rawValue)
        case .Fixed:
            try container.encode("Fixed", forKey: .rawValue)
        }
    }
}

