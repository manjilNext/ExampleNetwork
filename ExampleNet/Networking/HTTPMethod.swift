//
//  HTTPMethod.swift
//  ExampleNet
//
//  Created by Manjil Rajbhandari on 18/07/2024.
//

import Foundation

public enum HTTPMethod {
    
    case get, post, put, delete, patch
    
    var identifier: String {
        switch self {
            case .get: return "GET"
            case .post: return "POST"
            case .put: return "PUT"
            case .delete: return "DELETE"
            case .patch: return "PATCH"
        }
    }
}
