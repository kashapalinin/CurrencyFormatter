//
//  Currency.swift
//  CurrencyFormatter
//
//  Created by Павел Калинин on 28.11.2025.
//

public struct Currency: Codable, Identifiable {
    public let id: String
    public let numCode: String
    public let charCode: String
    public let nominal: Int
    public let name: String
    public let value: Double
    public let vunitRate: Double
    
    public init(
        id: String,
        numCode: String,
        charCode: String,
        nominal: Int,
        name: String,
        value: Double,
        vunitRate: Double
    ) {
        self.id = id
        self.numCode = numCode
        self.charCode = charCode
        self.nominal = nominal
        self.name = name
        self.value = value
        self.vunitRate = vunitRate
    }
}
