//
//  CoreDataManager.swift
//  ToDoApp
//
//  Created by Артемий Андреев  on 21.05.2025.
//

import CoreData
import UIKit

final class CoreDataManager {
    // MARK: singleton
    static let shared = CoreDataManager(inMemory: false)
    private let container: NSPersistentContainer

    init(inMemory: Bool) {
        container = NSPersistentContainer(name: "ToDoModel")
        if inMemory {
            let d = NSPersistentStoreDescription()
            d.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [d]
        }
        container.loadPersistentStores { _, error in
            if let error { fatalError("CoreData error: \(error)") }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    var viewContext: NSManagedObjectContext { container.viewContext }

    // MARK: CRUD
    @discardableResult
    func addTask(title: String,
                 taskDescription: String,
                 isDone: Bool = false) throws -> TaskModel {

        var model: TaskModel!
        try viewContext.performAndWait {
            let entity = TaskEntity(context: viewContext)
            entity.title     = title
            entity.desc      = taskDescription
            entity.createdAt = Date()
            entity.isDone    = isDone
            try viewContext.save()
            model = TaskModel(entity: entity)
        }
        return model
    }

    func fetchAllTasks() throws -> [TaskModel] {
        var result = [TaskModel]()
        try viewContext.performAndWait {
            let req: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            req.sortDescriptors = [.init(key: "createdAt", ascending: false)]
            result = try viewContext
                .fetch(req)
                .map(TaskModel.init)
        }
        return result
    }

    func updateTask(_ model: TaskModel) throws {
        try viewContext.performAndWait {
            guard let obj = try? viewContext.existingObject(with: model.id) as? TaskEntity else { return }
            obj.title     = model.title
            obj.desc      = model.taskDescription
            obj.isDone    = model.isDone
            try viewContext.save()
        }
    }

    func deleteTask(id: NSManagedObjectID) throws {
        try viewContext.performAndWait {
            if let obj = try? viewContext.existingObject(with: id) {
                viewContext.delete(obj)
                try viewContext.save()
            }
        }
    }

    // MARK: helper
    var isInitialDataLoaded: Bool {
        (try? viewContext.count(for: TaskEntity.fetchRequest())) ?? 0 > 0
    }
}

