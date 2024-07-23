//
//  Service.swift
//  ExampleNet
//
//  Created by Manjil Rajbhandari on 18/07/2024.
//

import Foundation

public protocol Service {
    var name: String { get }
    var router: NetworkingRouter  { get set }
}
