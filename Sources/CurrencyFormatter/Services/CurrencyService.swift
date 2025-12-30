//
//  CurrencyService.swift
//  CurrencyFormatter
//
//  Created by Павел Калинин on 28.11.2025.
//
import Foundation

public protocol CurrencyServiceProtocol {
    func fetchCurrencies() async throws -> CurrencyResponse
}

public class CurrencyService: CurrencyServiceProtocol {
    private let baseURL = "https://www.cbr.ru/scripts/XML_daily.asp"
    private let parser = CurrencyXMLParser()
    
    public init() {}
    
    public func fetchCurrencies() async throws -> CurrencyResponse {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try await parser.parse(data: data)
    }
}
