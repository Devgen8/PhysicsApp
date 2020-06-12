//
//  NetworkService.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 12.06.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation

class NetworkService {
    static func fetchRecipes(urlString: String, response: @escaping (SearchResponse?) -> Void) {
        request(urlString: urlString) { (result) in
            switch result {
            case .success(let data):
                do {
                    let recipes = try JSONDecoder().decode(SearchResponse.self, from: data)
                    response(recipes)
                } catch let jsonError {
                    print("Failed to decode JSON", jsonError)
                    response(nil)
                }
            case .failure(let error):
                print("Error received requesting data: \(error.localizedDescription)")
                response(nil)
            }
        }
    }
    
    static func request(urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else { return }
                completion(.success(data))
            }
        }.resume()
    }
}
