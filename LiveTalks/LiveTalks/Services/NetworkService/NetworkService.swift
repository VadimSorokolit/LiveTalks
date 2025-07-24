//
//  NetworkService.swift
//  LiveTalks
//
//  Created by Vadim Sorokolit on 23.07.2025.
//

import Foundation
import UIKit

protocol NetworkServiceProtocol: AnyObject {
    func fetchLocation() async throws -> Location
}

final class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Objects
    
    private struct Constants {
        static let scheme: String = "http"
        static let host: String = "ip-api.com"
        static let path: String = "/json"
    }
    
    static let shared = NetworkService()
    
    // MARK: - Initializer
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchLocation() async throws -> Location {
        guard let url = self.makeLocationURL() else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResp = response as? HTTPURLResponse, 200..<300 ~= httpResp.statusCode else {
            throw URLError(.badServerResponse)
        }
        let location = try JSONDecoder().decode(Location.self, from: data)
        
        return location
    }
    
    // MARK: - Private Methods
    
    private func makeLocationURL() -> URL? {
        var components = URLComponents()
        components.scheme = Constants.scheme
        components.host = Constants.host
        components.path = Constants.path
        return components.url
    }
    
}
