//
//  File.swift
//  ExampleNet
//
//  Created by Manjil Rajbhandari on 18/07/2024.
//

import Foundation
public struct File {
    
    public let name: String
    public let fileName: String
    public let data: Data
    public let contentType: String
    
    public init(name: String, fileName: String, data: Data, contentType: String) {
        self.name = name
        self.fileName = fileName
        self.data = data
        self.contentType = contentType
    }
}
