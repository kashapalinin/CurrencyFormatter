//
//  CurrencyXMLParser.swift
//  CurrencyFormatter
//
//  Created by Павел Калинин on 28.11.2025.
//
import Foundation

public struct CurrencyXMLParser {
    
    public init() {}
    
    public func parse(data: Data) async throws -> CurrencyResponse {
        return try await withCheckedThrowingContinuation { continuation in
            let parserHelper = ParserHelper()
            let xmlParser = XMLParser(data: data)
            xmlParser.delegate = parserHelper
            
            if xmlParser.parse() {
                if let response = parserHelper.response {
                    continuation.resume(returning: response)
                } else {
                    continuation.resume(throwing: ParserError.invalidData)
                }
            } else {
                let error = parserHelper.parserError ?? .unknownError
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func parse(xmlString: String) async throws -> CurrencyResponse {
        guard let data = xmlString.data(using: .utf8) else {
            throw ParserError.invalidInput
        }
        return try await parse(data: data)
    }
}

private class ParserHelper: NSObject {
    private var currentElement = ""
    private var currentCurrency: [String: String] = [:]
    private var currencies: [Currency] = []
    private var date: String = ""
    private var name: String = ""
    
    var response: CurrencyResponse?
    var parserError: CurrencyXMLParser.ParserError?
    
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

extension ParserHelper: XMLParserDelegate {
    func parser(
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
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedString.isEmpty {
            if currentElement != "Valute" && currentElement != "ValCurs" {
                currentCurrency[currentElement] = (currentCurrency[currentElement] ?? "") + trimmedString
            }
        }
    }
    
    func parser(
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
    
    func parserDidEndDocument(_ parser: XMLParser) {
        response = CurrencyResponse(date: date, name: name, currencies: currencies)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        parserError = .parsingFailed(parseError)
    }
    
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        parserError = .validationFailed(validationError)
    }
}

extension CurrencyXMLParser {
    public enum ParserError: Error, LocalizedError {
        case invalidInput
        case invalidData
        case parsingFailed(Error)
        case validationFailed(Error)
        case unknownError
        
        public var errorDescription: String? {
            switch self {
            case .invalidInput:
                return "Invalid input data"
            case .invalidData:
                return "Invalid XML data structure"
            case .parsingFailed(let error):
                return "XML parsing failed: \(error.localizedDescription)"
            case .validationFailed(let error):
                return "XML validation failed: \(error.localizedDescription)"
            case .unknownError:
                return "Unknown parsing error occurred"
            }
        }
    }
}
