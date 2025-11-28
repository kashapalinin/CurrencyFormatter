//
//  CBCurrencyFormatter.swift
//  CurrencyFormatter
//
//  Created by Павел Калинин on 28.11.2025.
//
import Foundation

public struct CBCurrencyFormatter {
    private let currencyService: CurrencyServiceProtocol
    private let formatter: CurrencyFormatterProtocol
    
    public init() {
        self.currencyService = CurrencyService()
        self.formatter = CurrencyFormatter()
    }
    
    public init(service: CurrencyService, formatter: CurrencyFormatter) {
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
}
