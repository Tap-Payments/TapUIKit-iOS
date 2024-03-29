//
//  TokenizedCard.swift
//  goSellSDK
//
//  Copyright © 2019 Tap Payments. All rights reserved.
//

import TapCardVlidatorKit_iOS
/// Tokenized card model.
@objcMembers public final class TokenizedCard: IdentifiableWithString {
    
    // MARK: - Public -
    // MARK: Properties
    
    /// Unique tokenized card identifier.
    public let identifier: String
    
    /// Object type.
    public let object: String
    
    /// Last four digits.
    public let lastFourDigits: String
    
    /// Expiration month.
    public let expirationMonth: Int
    
    /// Expiration year.
    public let expirationYear: Int
    
    /// BIN number.
    public let binNumber: String
    
    /// Card brand.
    public let brand: CardBrand
    
    /// Card funding.
    public let funding: String
    
    /// Cardholder name.
    public let cardholderName: String?
    
    /// Customer identifier.
    public let customerIdentifier: String?
    
    /// Card fingerprint.
    public let fingerprint: String
    
    /// Address on card.
    public private(set) var address: Address?
    
    /// Card issuer
    public private(set) var issuer: Issuer?
    
    // MARK: - Private -
    
    private enum CodingKeys: String, CodingKey {
        
        case identifier         = "id"
        case object             = "object"
        case lastFourDigits     = "last_four"
        case expirationMonth    = "exp_month"
        case expirationYear     = "exp_year"
        case binNumber          = "first_six"
        case brand              = "brand"
        case funding            = "funding"
        case cardholderName     = "name"
        case customerIdentifier = "customer"
        case fingerprint        = "fingerprint"
        case address            = "address"
        case issuer             = "issuer"
    }
    
    // MARK: Methods
    
    private init(identifier: String, object: String, lastFourDigits: String, expirationMonth: Int, expirationYear: Int, binNumber: String, brand: CardBrand, funding: String, cardholderName: String?, customerIdentifier: String?, fingerprint: String, address: Address?, issuer:Issuer?) {
        
        self.identifier         = identifier
        self.object             = object
        self.lastFourDigits     = lastFourDigits
        self.expirationMonth    = expirationMonth
        self.expirationYear     = expirationYear
        self.binNumber          = binNumber
        self.brand              = brand
        self.funding            = funding
        self.cardholderName     = cardholderName
        self.customerIdentifier = customerIdentifier
        self.fingerprint        = fingerprint
        self.address            = address
        self.issuer             = issuer
    }
}

// MARK: - Encodable
extension TokenizedCard: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(identifier, forKey: .identifier)
        try container.encodeIfPresent(object, forKey: .object)
        try container.encodeIfPresent(lastFourDigits, forKey: .lastFourDigits)
        try container.encodeIfPresent(expirationMonth, forKey: .expirationMonth)
        try container.encodeIfPresent(expirationYear, forKey: .expirationYear)
        try container.encodeIfPresent(binNumber, forKey: .binNumber)
        try container.encodeIfPresent(brand, forKey: .brand)
        try container.encodeIfPresent(funding, forKey: .funding)
        try container.encodeIfPresent(cardholderName, forKey: .cardholderName)
        try container.encodeIfPresent(customerIdentifier, forKey: .customerIdentifier)
        try container.encodeIfPresent(fingerprint, forKey: .fingerprint)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(issuer, forKey: .issuer)
    }
}

// MARK: - Decodable
extension TokenizedCard: Decodable {
    
    public convenience init(from decoder: Decoder) throws {
        
        let container           = try decoder.container(keyedBy: CodingKeys.self)
        
        let identifier         = try container.decode                              (String.self,       forKey: .identifier)
        let object             = try container.decode                              (String.self,       forKey: .object)
        let lastFourDigits     = try container.decode                              (String.self,       forKey: .lastFourDigits)
        let expirationMonth    = try container.decode                              (Int.self,          forKey: .expirationMonth)
        let expirationYear     = try container.decode                              (Int.self,          forKey: .expirationYear)
        let binNumber          = try container.decode                              (String.self,       forKey: .binNumber)
        let brand              = try container.decode                              (CardBrand.self,    forKey: .brand)
        let funding            = try container.decode                              (String.self,       forKey: .funding)
        let cardholderName     = try container.decodeIfPresent                  (String.self,       forKey: .cardholderName)
        let customerIdentifier = try container.decodeIfPresent                     (String.self,       forKey: .customerIdentifier)
        let fingerprint        = try container.decode                              (String.self,       forKey: .fingerprint)
        let address            = try container.decodeIfPresent                    (Address.self,      forKey: .address)
        let issuer             = try container.decodeIfPresent                  (Issuer.self,      forKey: .issuer)
        
        self.init(identifier:           identifier,
                  object:               object,
                  lastFourDigits:       lastFourDigits,
                  expirationMonth:      expirationMonth,
                  expirationYear:       expirationYear,
                  binNumber:            binNumber,
                  brand:                brand,
                  funding:              funding,
                  cardholderName:       cardholderName,
                  customerIdentifier:   customerIdentifier,
                  fingerprint:          fingerprint,
                  address:              address,
                  issuer:               issuer)
    }
}



// MARK: - Issuer
@objcMembers public final class Issuer: NSObject, Codable {
    let bank, country, id: String?
}
