//
//  RequestBuilder.swift
//  ExampleNet
//
//  Created by Manjil Rajbhandari on 18/07/2024.
//

import Foundation
struct RequestBuilder {
    /// The router of the request
    let service: Service
    
    /// The session config
    let config: NetworkingConfiguration
    
    func getRequest() throws -> URLRequest {
        let request = try createRequest()
        return try applyEncodings(from: service.router.encoder, to: request)
    }
    
    func getMultipartRequest() throws -> (request: URLRequest, parameters: Parameters) {
        let request = try createRequest()
        let parameters = combineParameters(from: service.router.encoder)
        return (request, parameters)
    }
    
    private func createRequest() throws -> URLRequest {
        guard let url = URL(string: service.router.overridenBaseURL ?? config.baseURL)?.appendingPathComponent(service.router.path) else {
            throw NetworkingError(.invalidBaseURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = service.router.httpMethod.identifier
        applyHeaders(config: config, router: service.router, request: &request)
        return request
    }
    
    private func createURL() -> URL? {
        guard var url = URL(string: service.router.overridenBaseURL ?? config.baseURL) else  { return nil }
        if !service.name.isEmpty {
            url  = url.appendingPathComponent(service.name)
        }
        url = url.appendingPathComponent(service.router.path)
        
        return url
    }
    
    private func applyHeaders(config: NetworkingConfiguration, router: NetworkingRouter, request: inout URLRequest) {
        router.headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        config.parameter.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        config.tokenManageable.tokenParam.forEach { request.addValue($1, forHTTPHeaderField: $0)}
        
    }
    
    private func applyEncodings(from encodings: [EncoderType], to request: URLRequest) throws -> URLRequest {
        var updatedRequest = request
        try encodings.forEach { type in
            switch type {
            case .json(let params):
                try updatedRequest.jsonEncoding(params)
            case .url(let params):
                try updatedRequest.urlEncoding(params)
            }
        }
        return updatedRequest
    }
    
    private func combineParameters(from encodings: [EncoderType]) -> Parameters {
        var parameters = Parameters()
        encodings.forEach { type in
            switch type {
            case .json(let params), .url(let params):
                if let params {
                    params.forEach { key, value in parameters[key] = value }
                }
            }
        }
        return parameters
    }
}
