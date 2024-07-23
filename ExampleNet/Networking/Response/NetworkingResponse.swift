//
//  NetworkingResponse.swift
//  ExampleNet
//
//  Created by Manjil Rajbhandari on 18/07/2024.
//

import Foundation
public struct NetworkingResponse<T> {
    let data: Data?
    let object: T?
    let urlRequest: URLRequest
    let urlResponse: URLResponse?
    let router: NetworkingRouter
    let statusCode: Int
    
    public init(router: NetworkingRouter, data: Data?, request: URLRequest, response: URLResponse, object: T?) {
        self.router = router
        self.data = data
        self.object = object
        self.urlRequest = request
        self.urlResponse = response
        
        if let httpURLResponse = response as? HTTPURLResponse {
            self.statusCode = httpURLResponse.statusCode
        } else {
            self.statusCode = 0
        }
    }
}
