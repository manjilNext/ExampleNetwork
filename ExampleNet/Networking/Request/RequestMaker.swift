//
//  RequestMaker.swift
//  ExampleNet
//
//  Created by Manjil Rajbhandari on 18/07/2024.
//

import Foundation
import HandyJSON

public typealias NetworkResult<O> = (Result<O, NetworkingError>)
public struct RequestMaker {
    
    private let service: Service
    private let config: NetworkingConfiguration
    
    init(service: Service, config: NetworkingConfiguration) {
        self.service = service
        self.config = config
    }
    
   
    func makeDataRequest<O>() async -> NetworkResult<O> {
        return await performRequest()
    }
    
    func makeMultiRequest<O>(multipart: [File]) async -> NetworkResult<O> {
        return await performRequest(multipart: multipart)
    }
    
    private func performRequest<O>(multipart: [File] = []) async -> NetworkResult<O> {
        do {
            let requestBuilder = RequestBuilder(service: service, config: config)
            let request: URLRequest
            var parameter: Parameters = [:]
            if  multipart.isEmpty {
                request = try requestBuilder.getRequest()
            } else {
                let multi =  try requestBuilder.getMultipartRequest()
                request = multi.request
                parameter = multi.parameters
            }
            let session  = URLSession(configuration: config.sessionConfiguration)
            return await tokenValidation(session, request: request, parameters: parameter, multipart: multipart)
        } catch {
            return .failure(NetworkingError(error))
        }
    }
    
    private func tokenValidation<O>(_ session: URLSession, request: URLRequest, parameters: Parameters = [:], multipart: [File] = []) async -> NetworkResult<O> {
        if  service.router.needsAuthorization,  await !updateTokenIfNeeded()  {
            return .failure(NetworkingError("TOKEN_EXPIRE"))
        }
        return await checkMultipartThenRequest(session, request: request, parameters: parameters, multipart: multipart)
    }
    
    private func updateTokenIfNeeded() async -> Bool  {
        guard config.tokenManageable.isTokenValid() else {
            return await refreshToken()
        }
        return true
    }
    
    private func refreshToken() async -> Bool {
        await config.tokenManageable.refreshToken()
    }
    
    private func checkMultipartThenRequest<O>(_ session: URLSession, request: URLRequest, parameters: Parameters, multipart: [File]) async -> NetworkResult<O> {
        if multipart.isEmpty {
            return  await normalRequest(session, request: request)
        }
        return await multipartRequest(session, request: request, parameters: parameters, multipart: multipart)
    }
    
    private func normalRequest<O>(_ session: URLSession, request: URLRequest) async -> NetworkResult<O> {
        var statusCode: Int?
        do {
            
            let (data, response)  = try await session.data(for: request)
            if let httpURLResponse = response as? HTTPURLResponse {
                statusCode = httpURLResponse.statusCode
            }
            if config.printLogger {
                Logger.log(response, request: request, data: data)
            }
            
            let jsonString = data.prettyPrintedJSONString
            if  O.self is String.Type, let string = String(data: data, encoding: .utf8), let value = string as? O {
                let   networkResponse = NetworkingResponse<O>(router: service.router, data: data, request: request, response: response, object: value)
                //return  await handleResponse(networkResponse: networkResponse, session: session, request: request)
            }
            if let decodableType = O.self as? Decodable.Type {
                let object =  try JSONDecoder().decode(decodableType, from: data)
                let  networkResponse = NetworkingResponse<O>(router: service.router, data: data, request: request, response: response, object: object as? O)
               // return  await handleResponse(networkResponse: networkResponse, session: session, request: request)
            }
            
//            return .failure(NetworkingError("Response is not in correct format."))
           
            if let handyJSONType = O.self as? HandyJSON.Type {
                let result:  NetworkResult<HandyJSON> = checkStatus(statusCode: statusCode ?? 0, jsonString: jsonString, type: handyJSONType)
                
                switch result {
                    
                case .success(let object):
                    return .success(object as! O)
                case .failure(let error):
                    return .failure(error)
                }
            }
           
            return .failure(NetworkingError("Response is not in correct format."))
            
        } catch let error as DecodingError {
            switch error {
                
            case .typeMismatch(let type, let context) :
                let message = "Type '\(type)' mismatch: \(context.debugDescription)"
                return .failure(NetworkingError(message, code: statusCode ?? error.errorCode))
            case .valueNotFound(let value,let context):
                let message = "value '\(value)' mismatch: \(context.debugDescription)"
                return .failure(NetworkingError(message))
            case .keyNotFound(let key, let context):
                let message = "Key '\(key)' mismatch: \(context.debugDescription)"
                return .failure(NetworkingError(message))
            case .dataCorrupted(let context):
                let message = "Data  corrupted: \(context.debugDescription)"
                return .failure(NetworkingError(message, code: statusCode ?? error.errorCode))
            @unknown default:
                return .failure(NetworkingError(error.localizedDescription, code: statusCode ?? error.errorCode))
            }
        }
       /* catch let DecodingError.typeMismatch(type, context) {
            let message = "Type '\(type)' mismatch: \(context.debugDescription)"
            return .failure(NetworkingError(message, code: statusCode))
        } catch  let DecodingError.keyNotFound(key, context) {
            let message = "Key '\(key)' mismatch: \(context.debugDescription)"
            return .failure(NetworkingError(message))
        } catch let DecodingError.valueNotFound(value, context) {
            let message = "value '\(value)' mismatch: \(context.debugDescription)"
            return .failure(NetworkingError(message))
        }*/ catch {
            return .failure(NetworkingError(error.localizedDescription, code: statusCode ?? error.errorCode))
        }
    }
    
    
    private func checkStatus<O: HandyJSON>(statusCode: Int, jsonString: NSString, type: HandyJSON.Type) -> NetworkResult<O> {
        if 200..<300 ~= statusCode {
            let dataParamsMergeValue = returnDictionary(jsonString: jsonString)
            
                if let model = JSONDeserializer<O>.deserializeFrom(json: dataParamsMergeValue as String)  {
                    // Observable.error(MyError.deserializationError)
                      return .success(model)
                } else {
                   return .failure(.init(.deserializationError))
                }
            }  else {
            return .failure(NetworkingError("Response is not in correct format."))
//            let errorMsg = errorHandler(statusCode: statusCode, jsonString: jsonString)
//            return errorMsg
        }
    }
    
    private func returnDictionary(jsonString: NSString) -> NSString {
        
        guard let jsonData = jsonString.data(using: String.Encoding.utf8.rawValue) else {
            print("Invalid JSON string")
            return ""
        }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            print("Failed to parse JSON data in returnDictionary")
            return ""
        }
        
        var finaDict: [String: Any] = jsonObject
        
        if let dataDictValue = finaDict["paramsConstants.data"] as? [String: Any] {
           var finalDataDictVal = dataDictValue
            let dataMessage = finalDataDictVal["paramsConstants.message"]
            finalDataDictVal.removeValue(forKey: "paramsConstants.message")
            finaDict.merge(finalDataDictVal) { _, _ in
            }
            finaDict.removeValue(forKey: "paramsConstants.data")
            finaDict["dataMessage"] = dataMessage
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: finaDict, options: [.prettyPrinted])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return NSString(string: jsonString)
            } else {
                return NSString(string: "")
            }
        } catch {
            return NSString(string: "")
        }
    }
    
    private func errorHandler<O: HandyJSON>(statusCode: Int, jsonString: NSString) ->  NetworkResult<O> {
        print("Status Code \(statusCode)")
        
        guard let jsonData = jsonString.data(using: String.Encoding.utf8.rawValue) else {
            print("Invalid JSON string")
            return .failure(.init(.deserializationError))
        }
        
        guard let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            print("Failed to parse JSON data")
            return .failure(.init(.deserializationError))
        }
        
        var finaDict: [String: Any] = jsonObject
        finaDict["success"] = false as Any
        finaDict["statusCode"] = statusCode as Any
        
        let errorMsg =
        """
        {
          "success": "false",
          "message": "Error Processing request!"
        }
        """
        
        guard let staticErrorModel = JSONDeserializer<O>.deserializeFrom(json: errorMsg as String) else {
            return .failure(.init(.deserializationError))
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: finaDict, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                
                guard let dynamicErrorMsg = JSONDeserializer<O>.deserializeFrom(json: jsonString as String) else {
                    return .failure(.init(.deserializationError))
                }
                return .success(dynamicErrorMsg)
            } else {
                return .success(staticErrorModel)
            }
        } catch {
            return .success(staticErrorModel)
        }
    }
    
//    private func handleResponse<O>(networkResponse: NetworkingResponse<O>, session: URLSession, request: URLRequest) async -> NetworkResult<O> {
//        if networkResponse.statusCode == 401 && service.router.needsAuthorization {
//            /*guard await refreshToken() else {
//                return .failure(NetworkingError("TOKEN_EXPIRE"))
//            }*/
//            return .failure(NetworkingError("TOKEN_EXPIRE"))
//            //return await normalRequest(session, request: request)
//        }
//        return .success(networkResponse)
//    }
    
    private func multipartRequest<O>(_ session: URLSession, request: URLRequest, parameters: Parameters, multipart: [File]) async -> NetworkResult<O> {
        let boundary = UUID().uuidString
        var request = request
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let bodyData = createBodyWithMultipleImages(parameters: parameters, multipart: multipart, boundary: boundary)
        request.httpBody = bodyData
        
        return await normalRequest(session, request: request)
    }
    
    private func createBodyWithMultipleImages(parameters: Parameters, multipart: [File], boundary: String) -> Data {
        var body = Data()
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        multipart.forEach {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\($0.name)\"; filename=\"\($0.fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \($0.contentType)\r\n\r\n".data(using: .utf8)!)
            body.append($0.data)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}
