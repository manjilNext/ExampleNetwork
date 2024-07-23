//
//  NetworkConformable.swift
//  ExampleNet
//
//  Created by Manjil Rajbhandari on 18/07/2024.
//

import Foundation
public protocol NetworkConformable {
    static func initialize(with config: NetworkingConfiguration)
  
//    func dataRequest<T>(service: Service, type: T.Type) async throws -> T?
//    func dataRequest<O>(service: Service ,type: O.Type) async throws -> Response<O>
//    func multipartRequest<O>(service: Service, multipart: [File], type: O.Type) async throws -> Response<O>
    
    func dataRequest<O>(service: Service, type: O.Type) async -> NetworkResult<O>
    func multipartRequest<O>(service: Service, multipart: [File], type: O.Type) async  -> NetworkResult<O>
}
