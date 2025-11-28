//
//  CurrencyResponse.swift
//  CurrencyFormatter
//
//  Created by Павел Калинин on 28.11.2025.
//

public struct CurrencyResponse: Codable {
    public let date: String
    public let name: String
    public let currencies: [Currency]
    
    public init(date: String, name: String, currencies: [Currency]) {
        self.date = date
        self.name = name
        self.currencies = currencies
    }
}
