//
//  CurrencyService.swift
//  CurrencyFormatter
//
//  Created by Павел Калинин on 28.11.2025.
//


import Foundation

public protocol CurrencyServiceProtocol {
    func fetchCurrencies(completion: @escaping (Result<CurrencyResponse, Error>) -> Void)
}

public class CurrencyService: CurrencyServiceProtocol {
    private let baseURL = "https://www.cbr.ru/scripts/XML_daily.asp"
    private let parser = CurrencyXMLParser()
    
    public init() {}
    
    public func fetchCurrencies(completion: @escaping (Result<CurrencyResponse, Error>) -> Void) {
        var urlString = baseURL
        
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            self?.parser.parse(data: data, completion: completion)
        }
        
        task.resume()
    }
}
