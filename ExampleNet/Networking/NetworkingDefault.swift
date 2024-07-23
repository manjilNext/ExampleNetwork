//
//  NetworkingDefault.swift
//  ExampleNet
//
//  Created by Manjil Rajbhandari on 18/07/2024.
//

import Foundation
public class NetworkingDefault: NetworkConformable {
    public func dataRequest<T>(service: Service, type: T.Type) async throws -> T? {
        nil
    }
    
    
    /// make the instance shared
    public static let `default` = NetworkingDefault()
    private init() {}
    
    /// The networking configuration
    private var config: NetworkingConfiguration?
    
    /// Method to set the configuration from client side
    /// - Parameter config: The networking configuration
    public static func initialize(with config: NetworkingConfiguration) {
        NetworkingDefault.default.config = config
        _ = Connectivity.default
    }
    
    /// Method to create a response publisher for data
//    public func dataRequest<O>(service: Service, type: O.Type)  async throws ->  Response<O> {
//        try  await createAndPerformRequest(service, multipart: [])
//    }
//    
//    /// Method to create a response publisher for data
//    public func multipartRequest<O>(service: Service, multipart: [File], type: O.Type) async throws -> Response<O> {
//        try await createAndPerformRequest(service, multipart: multipart)
//    }
//    
//    private func createAndPerformRequest<O>(_ service: Service, multipart: [File]) async throws ->  Response<O> {
//        guard let config = NetworkingDefault.default.config else {
//            throw NetworkingError(.networkingNotInitialized)
//        }
//        
//        guard Connectivity.default.status == .connected else {
//            throw NetworkingError(.noConnectivity)
//        }
//        let requestMaker = RequestMaker(service: service, config: config)
//        
//        let result: NetworkResult<O> = await (multipart.isEmpty ?   requestMaker.makeDataRequest() :  requestMaker.makeMultiRequest(multipart: multipart))
//        
//        switch result {
//            case .success(let data):
//                if let model = data.object {
//                    let response = Response(data: model, statusCode: data.statusCode)
//                    return response
//                }
//            case .failure(let error):
//                throw error
//        }
//        
//        throw NetworkingError("SOMETHING_WENT_WRONG")
//    }
    
    public func dataRequest<O>(service: Service, type: O.Type)  async ->  NetworkResult<O> {
        await createAndPerformRequest(service, multipart: [])
    }
    
    public func multipartRequest<O>(service: Service, multipart: [File], type: O.Type) async  -> NetworkResult<O> {
        await createAndPerformRequest(service, multipart: multipart)
    }
    
    private func createAndPerformRequest<O>(_ service: Service, multipart: [File]) async  ->  NetworkResult<O> {
        guard let config = NetworkingDefault.default.config else {
            return .failure(NetworkingError(.networkingNotInitialized))
        }
        
        guard Connectivity.default.status == .connected else {
            return .failure(NetworkingError(.noConnectivity))
        }
        let requestMaker = RequestMaker(service: service, config: config)
        
        return  await (multipart.isEmpty ?   requestMaker.makeDataRequest() :  requestMaker.makeMultiRequest(multipart: multipart))
    }
}
