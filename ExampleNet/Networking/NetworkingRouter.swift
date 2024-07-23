//
//  NetworkingRouter.swift
//  ExampleNet
//
//  Created by Manjil Rajbhandari on 18/07/2024.
//

import Foundation

public protocol NetworkingRouter {
    
    /// The headers that will be passed by client to the request
    var headers: [String: String] { get }
    
    /// The endpoint path that will get appended to base path
    var path: String { get }
    
    /// The requests method
    var httpMethod: HTTPMethod { get }
    
    /// The encoders to use to be used for parameter encoding
    var encoder: [EncoderType] { get }
    
    /// The base URL to override if need be
    var overridenBaseURL: String? { get }
    
    var needsAuthorization: Bool {  get }
    
}
