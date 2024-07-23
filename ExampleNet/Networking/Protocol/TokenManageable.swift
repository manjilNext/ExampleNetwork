//
//  TokenManageable.swift
//  ExampleNet
//
//  Created by Manjil Rajbhandari on 18/07/2024.
//

import Foundation
public protocol TokenManageable {
   
    func refreshToken() async -> Bool
    func isTokenValid() -> Bool
    var tokenParam: [String: String] {get }
    
}
