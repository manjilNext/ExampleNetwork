//
//  Data+Extension.swift
//  ExampleNet
//
//  Created by Manjil Rajbhandari on 21/07/2024.
//

import Foundation

extension Data {
    var prettyPrintedJSONString: NSString {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return "" }

        return prettyPrintedString
    }
}
