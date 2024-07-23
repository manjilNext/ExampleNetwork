//
//  Parameters.swift
//  ExampleNet
//
//  Created by Manjil Rajbhandari on 18/07/2024.
//

import Foundation
public typealias Parameters = [String: Any]

extension Parameters {
    
    public func percentEncoded(parentKey: String? = nil) -> String {
        return self.map { key, value in
            var escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .allowedQueryCharacterSet) ?? ""
            if let `parentKey` = parentKey {
                escapedKey = "\(parentKey)[\(escapedKey)]"
            }
            
            if let dict = value as? Parameters {
                return dict.percentEncoded(parentKey: escapedKey)
            } else if let array = value as? [CustomStringConvertible] {
                return array.map { entry in
                    let escapedValue = "\(entry)"
                        .addingPercentEncoding(withAllowedCharacters: .allowedQueryCharacterSet) ?? ""
                    return "\(escapedKey)[]=\(escapedValue)"
                }.joined(separator: "&")
            } else {
                let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .allowedQueryCharacterSet) ?? ""
                return "\(escapedKey)=\(escapedValue)"
            }
        }
        .joined(separator: "&")
    }
}

extension CharacterSet {
    static let allowedQueryCharacterSet: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
