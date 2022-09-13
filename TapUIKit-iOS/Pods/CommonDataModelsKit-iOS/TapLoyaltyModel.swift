//
//  TapLoyaltyModel.swift
//  CommonDataModelsKit-iOS
//
//  Created by Osama Rabie on 13/09/2022.
//

import Foundation

/// Tap loyalty model.
public struct TapLoyaltyModel : Codable {
    /// The id of teh loyalty programe
    public let id :String?
    /// The bank identifier to match it with the bin response
    public let bankName: String?
    /// The icon of the loyalty program owner
    public let bankLogo: String?
    /// The name of the loyalty programe to be used in the header title
    public let loyaltyProgramName: String?
    /// The name of the used shceme (ADCB Points, Fawry Values, etc.)
    public let loyaltyPointsName: String?
    /// A link to open the T&C of the loyalty scheme
    public let termsConditionsLink: String?
    /// The list of supported currencies each with the conversion rate
    public let supportedCurrencies: [LoyaltySupportedCurrency]?
    /// The name of the used shceme (ADCB Points, Fawry Values, etc.)
    public let transactionsCount: String?
}

// MARK: Welcome convenience initializers and mutators

public extension TapLoyaltyModel {
    ///Tap loyalty model. from given Data
    /// - Parameter data: The data to decode it into the model
    init(data: Data) throws {
        self = try newJSONDecoder().decode(TapLoyaltyModel.self, from: data)
    }
    
    ///Tap loyalty model. from given json string
    /// - Parameter string: The string  json to decode it into the modelParameter data: The data to decode it into the model
    /// - Parameter encoding: The encoding method. Default is UTF8
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    ///Tap loyalty model. from data/json in a given URL
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    /**
     Tap loyalty model.
     - Parameter id: The id of teh loyalty programe
     - Parameter bankName: The bank identifier to match it with the bin response
     - Parameter bankLogo: The icon of the loyalty program owner
     - Parameter loyaltyProgramName: The name of the loyalty programe to be used in the header title
     - Parameter loyaltyPointsName: The name of the used shceme (ADCB Points, Fawry Values, etc.)
     - Parameter termsConditionsLink: A link to open the T&C of the loyalty scheme
     - Parameter supportedCurrencies: The list of supported currencies each with the conversion rate
     - Parameter transactionsCount: The name of the used shceme (ADCB Points, Fawry Values, etc.)
     */
    func with(
        id: String? = nil,
        bankName: String? = nil,
        bankLogo: String? = nil,
        loyaltyProgramName: String? = nil,
        loyaltyPointsName: String? = nil,
        termsConditionsLink: String? = nil,
        transactionsCount: String? = nil,
        supportedCurrencies: [LoyaltySupportedCurrency]? = nil
    ) -> TapLoyaltyModel {
        return TapLoyaltyModel(
            id: id ?? self.id,
            bankName: bankName ?? self.bankName,
            bankLogo: bankLogo ?? self.bankLogo,
            loyaltyProgramName: loyaltyProgramName ?? self.loyaltyProgramName,
            loyaltyPointsName: loyaltyPointsName ?? self.loyaltyPointsName,
            termsConditionsLink: termsConditionsLink ?? self.termsConditionsLink,
            supportedCurrencies: supportedCurrencies ?? self.supportedCurrencies,
            transactionsCount: transactionsCount ?? self.transactionsCount
        )
    }
    
    /// Encodes the model into Data
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    
    /// Encodes the model into pretty formatted JSON string
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - SupportedCurrency
/// The model of the loyalty supported currencies. Each one will have the the rating + the currency itself
public struct LoyaltySupportedCurrency: Codable {
    /// The rate to convert amount to loyalty points using this currency
    public let rate: Double?
    /// The currency itself
    public let currency: TapCurrencyCode?
    /// Balance in this currency
    public let balanceAmount:Double?
}

// MARK: SupportedCurrency convenience initializers and mutators

public extension LoyaltySupportedCurrency {
    /**
     The model of the loyalty supported currencies. Each one will have the the rating + the currency itself
     - Parameter data: The data to decode it into the model
     */
    init(data: Data) throws {
        self = try newJSONDecoder().decode(LoyaltySupportedCurrency.self, from: data)
    }
    
    /**
     The model of the loyalty supported currencies. Each one will have the the rating + the currency itself
     - Parameter string: The string  json to decode it into the modelParameter data: The data to decode it into the model
     - Parameter encoding: The encoding method. Default is UTF8
     */
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    /**
     The model of the loyalty supported currencies. Each one will have the the rating + the currency itself
     - Parameter rate: The rate to convert amount to loyalty points using this currency
     - Parameter currency: The currency itself
     */
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    /**
     The model of the loyalty supported currencies. Each one will have the the rating + the currency itself
     - Parameter rate: The rate to convert amount to loyalty points using this currency
     - Parameter currency: The currency itself
     - Parameter balance: The balane in this currency
     */
    func with(
        rate: Double? = nil,
        currency: TapCurrencyCode? = nil,
        balance: Double? = nil
    ) -> LoyaltySupportedCurrency {
        return LoyaltySupportedCurrency(
            rate: rate ?? self.rate,
            currency: currency ?? self.currency,
            balanceAmount: balance ?? self.balanceAmount
        )
    }
    
    /// Encodes the model into Data
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    /// Encodes the model into pretty formatted JSON string
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
