//
//  CBCurrencyFormatter.swift
//  CurrencyFormatter
//
//  Created by Павел Калинин on 28.11.2025.
//
import Foundation

public protocol ICurrencyFormatter {
    func fetchCurrencies(completion: @escaping (Result<CurrencyResponse, Error>) -> Void)
    func formatAmount(_ amount: Double, for currency: Currency) -> String?
    func convertAmount(_ amount: Double, from sourceCurrency: Currency, to targetCurrency: Currency) -> Double
    func findCurrency(by charCode: String, in response: CurrencyResponse) -> Currency?
    func getCurrencySymbol(code: String) -> String
}

public struct CBCurrencyFormatter: ICurrencyFormatter {
    private let currencyService: CurrencyServiceProtocol
    private let formatter: CurrencyFormatterProtocol
    
    public init() {
        self.currencyService = CurrencyService()
        self.formatter = CurrencyFormatter()
    }
    
    public init(service: CurrencyServiceProtocol, formatter: CurrencyFormatterProtocol) {
        self.currencyService = service
        self.formatter = formatter
    }
    
    public func fetchCurrencies(completion: @escaping (Result<CurrencyResponse, Error>) -> Void) {
        currencyService.fetchCurrencies(completion: completion)
    }
    
    public func formatAmount(_ amount: Double, for currency: Currency) -> String? {
        return formatter.formatAmount(amount, for: currency)
    }
    
    public func convertAmount(_ amount: Double, from sourceCurrency: Currency, to targetCurrency: Currency) -> Double {
        return formatter.convertAmount(amount, from: sourceCurrency, to: targetCurrency)
    }
    
    public func findCurrency(by charCode: String, in response: CurrencyResponse) -> Currency? {
        return response.currencies.first { $0.charCode == charCode }
    }
    
    public func getCurrencySymbol(code: String) -> String {
        guard let url = Bundle.module.url(forResource: "CommonCurrency", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let currencyDict = jsonObject as? [String: [String: Any]] else {
            return code
        }
        
        return currencyDict[code.uppercased()]?["symbol_native"] as? String ?? ""
    }
}
