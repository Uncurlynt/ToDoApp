//
//  TaskModel.swift
//  ToDoApp
//
//  Created by Артемий Андреев  on 21.05.2025.
//

import Foundation
import CoreData

struct TaskModel: Identifiable, Equatable {
    let id: NSManagedObjectID
    var title: String
    var taskDescription: String
    var createdAt: Date
    var isDone: Bool

    init(entity: TaskEntity) {
        id          = entity.objectID
        title       = entity.title ?? ""
        taskDescription = entity.desc  ?? ""
        createdAt   = entity.createdAt ?? Date()
        isDone      = entity.isDone
    }
}
