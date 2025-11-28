//
//  CurrencyFormatter.swift
//  CurrencyFormatter
//
//  Created by Павел Калинин on 28.11.2025.
//
import Foundation

public protocol CurrencyFormatterProtocol {
    func formatAmount(_ amount: Double, currencyCode: String) -> String?
    func formatAmount(_ amount: Double, for currency: Currency) -> String?
    func formatNumber(_ number: Double) -> String?
    func convertAmount(_ amount: Double, from sourceCurrency: Currency, to targetCurrency: Currency) -> Double
}

public class CurrencyFormatter: CurrencyFormatterProtocol {
    private let numberFormatter: NumberFormatter
    private let currencyFormatter: NumberFormatter
    
    public init(locale: Locale = Locale(identifier: "ru_RU")) {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 4
        numberFormatter.locale = locale
        
        currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = locale
    }
    
    public func formatAmount(_ amount: Double, currencyCode: String) -> String? {
        currencyFormatter.currencyCode = currencyCode
        return currencyFormatter.string(from: NSNumber(value: amount))
    }
    
    public func formatAmount(_ amount: Double, for currency: Currency) -> String? {
        let convertedAmount = amount * currency.vunitRate
        return formatAmount(convertedAmount, currencyCode: currency.charCode)
    }
    
    public func formatNumber(_ number: Double) -> String? {
        return numberFormatter.string(from: NSNumber(value: number))
    }
    
    public func convertAmount(_ amount: Double, from sourceCurrency: Currency, to targetCurrency: Currency) -> Double {
        let amountInTarget = amount * sourceCurrency.value / Double(sourceCurrency.nominal)
        return amountInTarget / targetCurrency.vunitRate
    }
}
