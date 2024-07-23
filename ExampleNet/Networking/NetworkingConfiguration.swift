//
//  NetworkingConfiguration.swift
//  ExampleNet
//
//  Created by Manjil Rajbhandari on 18/07/2024.
//

import Foundation
public struct NetworkingConfiguration {
    
    /// The baseURL for the API
    let baseURL: String
    let parameter: [String: String]
    
    /// The url session connfiguration
    let sessionConfiguration: URLSessionConfiguration
    let tokenManageable: TokenManageable
    let printLogger: Bool
    
    
    public init(baseURL: String, parameter: [String: String] = [:], tokenManageable: TokenManageable, sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default, printLogger: Bool = false) {
        self.baseURL = baseURL
        self.parameter = parameter
        self.sessionConfiguration = sessionConfiguration
        self.tokenManageable = tokenManageable
        self.printLogger = printLogger
    }
    
    /// The configuration information
    public func debugInfo() -> [String: Any] {
        [
            "baseURL": baseURL,
            "sessionConfiguration": sessionConfiguration,
        ]
    }
}
