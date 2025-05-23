//
//  TodosResponse.swift
//  ToDoApp
//
//  Created by Артемий Андреев  on 21.05.2025.
//

import Foundation

struct TodosResponse: Decodable {
    let todos: [TodoItem]
}
struct TodoItem: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
