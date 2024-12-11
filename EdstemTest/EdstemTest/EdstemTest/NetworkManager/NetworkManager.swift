//
//  NetworkManager.swift
//  EdstemTest
//
//  Created by FARIS CP on 09/12/24.
//

import Foundation
struct NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    // MARK: - CommonGetAPI
    func getData(urlPath: String, queryParams: [String: Any]? = nil, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlPath) else { return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if let queryParams = queryParams {
            components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
        }
        guard let finalURL = components?.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        let commonHeaders: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        print(commonHeaders)
        for (key, value) in commonHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(NetworkError.noData))
            }
        }
        task.resume()
    }
}
enum NetworkError: Error {
    case noData
    case invalidURL
}
