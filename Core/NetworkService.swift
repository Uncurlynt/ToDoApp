//
//  NetworkService.swift
//  ToDoApp
//
//  Created by Артемий Андреев  on 21.05.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case emptyData
    case decodingError(Error)
}

final class NetworkService {
    static let shared = NetworkService()
    private init() {}

    func fetchTodos() async throws -> [TodoItem] {
        guard let url = URL(string: Constants.apiURL) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse(statusCode: -1)
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.invalidResponse(statusCode: http.statusCode)
        }
        guard !data.isEmpty else {
            throw NetworkError.emptyData
        }

        do {
            let decoded = try JSONDecoder().decode(TodosResponse.self, from: data)
            return decoded.todos
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
