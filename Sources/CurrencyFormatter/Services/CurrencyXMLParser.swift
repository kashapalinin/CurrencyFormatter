//
//  CurrencyXMLParser.swift
//  CurrencyFormatter
//
//  Created by Павел Калинин on 28.11.2025.
//
import Foundation

public class CurrencyXMLParser: NSObject {
    private var currentElement = ""
    private var currentCurrency: [String: String] = [:]
    private var currencies: [Currency] = []
    private var date: String = ""
    private var name: String = ""
    private var completion: ((Result<CurrencyResponse, Error>) -> Void)?
    
    public func parse(data: Data, completion: @escaping (Result<CurrencyResponse, Error>) -> Void) {
        self.completion = completion
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
}

extension CurrencyXMLParser: XMLParserDelegate {
    public func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentElement = elementName
        
        if elementName == "ValCurs" {
            date = attributeDict["Date"] ?? ""
            name = attributeDict["name"] ?? ""
        } else if elementName == "Valute" {
            currentCurrency["ID"] = attributeDict["ID"]
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedString.isEmpty {
            if currentElement != "Valute" && currentElement != "ValCurs" {
                currentCurrency[currentElement] = (currentCurrency[currentElement] ?? "") + trimmedString
            }
        }
    }
    
    public func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        if elementName == "Valute" {
            if let currency = createCurrency(from: currentCurrency) {
                currencies.append(currency)
            }
            currentCurrency.removeAll()
        }
        currentElement = ""
    }
    
    public func parserDidEndDocument(_ parser: XMLParser) {
        let response = CurrencyResponse(date: date, name: name, currencies: currencies)
        completion?(.success(response))
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        completion?(.failure(parseError))
    }
    
    private func createCurrency(from dict: [String: String]) -> Currency? {
        guard
            let id = dict["ID"],
            let numCode = dict["NumCode"],
            let charCode = dict["CharCode"],
            let nominalStr = dict["Nominal"],
            let nominal = Int(nominalStr),
            let name = dict["Name"],
            let valueStr = dict["Value"],
            let vunitRateStr = dict["VunitRate"],
            let value = parseDouble(valueStr),
            let vunitRate = parseDouble(vunitRateStr)
        else {
            return nil
        }
        
        return Currency(
            id: id,
            numCode: numCode,
            charCode: charCode,
            nominal: nominal,
            name: name,
            value: value,
            vunitRate: vunitRate
        )
    }
    
    private func parseDouble(_ string: String) -> Double? {
        let formattedString = string.replacingOccurrences(of: ",", with: ".")
        return Double(formattedString)
    }
}
