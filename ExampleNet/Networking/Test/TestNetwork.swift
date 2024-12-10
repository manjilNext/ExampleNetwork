//
//  TestNetwork.swift
//  ExampleNet
//
//  Created by Dawa Pakhrin on 25/07/2024.
//

import Foundation
import HandyJSON

struct CatService: Service {
    var name: String {
        ""
    }

    var router: NetworkingRouter
}

struct CatModel: HandyJSON {
    var id: String?
    var url: String?
    var width: Int?
    var height: Int?

    var data: [CatModel] = []

    init() {

    }
}

class TokenManager: TokenManageable {
    func refreshToken() async -> Bool {
        return true
    }

    func isTokenValid() -> Bool {
        return true
    }

    var tokenParam: [String: String] {
        return ["Authorization": "Bearer myToken"]
    }
}

extension NetworkingRouter {
    var headers: [String: String] { [:] }
}

enum CatRouter: NetworkingRouter {
    case getCatInfo

    var path: String {
        switch self {
        case .getCatInfo:
            return "cats"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getCatInfo:
            return .get
        }
    }

    var encoder: [EncoderType] {
        switch self {
        case .getCatInfo:
            return [.json(nil)]
        }
    }

    var overridenBaseURL: String? {
        return nil
    }

    var needsAuthorization: Bool {
        return true
    }
}

class TestNetwork: ObservableObject {
    @Published var catImages: [CatModel] = []

    @MainActor
    func fetchCatImages() async {


        let service = CatRouter.getCatInfo

        let result = await NetworkingDefault.default.dataRequest(service: CatService.init(router: service), type: CatModel.self)

        switch result {
        case .success(let data):
            catImages = data.data
        case .failure(let error):
            print(error.localizedDescription)
        }
    }

//    static func runExample() {
//        if #available(iOS 13.0, macOS 10.15, *) {
//            Task {
//                let testNetwork = TestNetwork()
//                await testNetwork.fetchCatImages()
//            }
//        } else {
//            print("This example requires iOS 13.0+ or macOS 10.15+")
//        }
//    }
}

