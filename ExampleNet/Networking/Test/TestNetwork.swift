//
//  TestNetwork.swift
//  ExampleNet
//
//  Created by Dawa Pakhrin on 25/07/2024.
//

import Foundation

struct CatModel: Codable {
    let id: String?
    let url: String?
    let width: Int?
    let height: Int?
}

class MyTokenManager: TokenManageable {
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

enum CatApiService: NetworkingRouter {
    case getCatInfo

    var path: String {
        switch self {
        case .getCatInfo:
            return "v1/images/search"
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

    func fetchCatImages() async {
        let tokenManager = MyTokenManager()
        let config = NetworkingConfiguration(baseURL: "https://api.thecatapi.com/", tokenManageable: tokenManager)
        NetworkingDefault.initialize(with: config)

        do {
            // Create the service
            let service = CatApiService.getCatInfo

            // Perform network request
            let (data, _) = try await URLSession.shared.data(from: URL(string: config.baseURL + service.path)!)

            // Decode response using Codable
            let catModels = try JSONDecoder().decode([CatModel].self, from: data)
            DispatchQueue.main.async {
                self.catImages = catModels
            }
            for catModel in catModels {
                print("--------------------------------------------------------")
                print("ID: \(catModel.id ?? "No ID")")
                print("URL: \(catModel.url ?? "No URL")")
                print("Width: \(catModel.width ?? 0)")
                print("Height: \(catModel.height ?? 0)")
                print("--------------------------------------------------------")
            }
        } catch {
            print("An error occurred: \(error)")
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
