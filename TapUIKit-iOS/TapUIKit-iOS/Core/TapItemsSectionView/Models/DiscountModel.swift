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
    
    /**
     Calculates and apply the correct discount scheme for a given a price
     - Parameter originalPrice: The original price the discount will be applied to
     - Returns: The discounted price after applying the correct discount value. NOTE, if the discounted value is less than 0, the original price is returned.
     */
    internal func caluclateActualDiscountedValue(with originalPrice:Double) -> Double {
        
        var discountValue:Double = 0
        
        // We first need to know the type of the discount
        switch type {
            case .Fixed:
                discountValue = calculateFixedDiscount()
            case .Percentage:
                discountValue = ( calculatePercentageDiscount() * originalPrice )
            default:
                discountValue = 0
        }
        
        // Make sure now that the discounted value is bigger than 0 otherwise return the original value
        let discountedValue = originalPrice - discountValue
        guard discountedValue >= 0 else { return originalPrice }
        return discountedValue
    }
    
    /**
     Calculates and apply the correct discount scheme in case of a fixed discount is applied
     - Returns: The discount value as is or 0 if the discount value is negative
     */
    private func calculateFixedDiscount() -> Double {
        // Check if the passed discount is a correct one, and return the correct value
        guard let nonNullValue = value, nonNullValue >= 0.0 else { return 0 }
        return nonNullValue
    }
    
    /**
     Calculates and apply the correct discount scheme in case of a percentage discount is applied
     - Returns: The percentage value of the discount value or 0 if the discount value is outside the range of 0..100
     */
    private func calculatePercentageDiscount() -> Double {
        // Check if the passed discount is a correct one, and return the correct value
        guard let nonNullValue = value, nonNullValue >= 0.0, nonNullValue <= 100 else { return 0 }
        return (nonNullValue/100)
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

