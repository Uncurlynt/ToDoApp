//
//  TaskListInteractor.swift
//  ToDoApp
//
//  Created by Артемий Андреев  on 21.05.2025.
//

import Foundation
import CoreData

final class TaskListInteractor: TaskListInteractorInput {

    weak var output: TaskListInteractorOutput?

    // MARK: load
    func loadTasks() {
        DispatchQueue.global().async {
            do {
                let tasks = try CoreDataManager.shared.fetchAllTasks()
                DispatchQueue.main.async { [weak self] in
                    self?.output?.didLoadTasks(tasks)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.output?.didFail(error)
                }
            }
        }
    }

    // MARK: initial import
    func initialImport() {
        Task {
            do {
                let todos = try await NetworkService.shared.fetchTodos()
                let mapped = todos.map {
                    try? CoreDataManager.shared.addTask(title: $0.todo,
                                                        taskDescription: "",
                                                        isDone: $0.completed)
                }.compactMap { $0 }
                DispatchQueue.main.async { [weak self] in
                    self?.output?.didLoadTasks(mapped)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.output?.didFail(error)
                }
            }
        }
    }

    // MARK: delete / toggle
    func deleteTask(id: NSManagedObjectID) {
        DispatchQueue.global().async {
            try? CoreDataManager.shared.deleteTask(id: id)
        }
    }

    func toggleDone(id: NSManagedObjectID, flag: Bool) {
        DispatchQueue.global().async { [flag] in
            guard var task = try? CoreDataManager.shared.fetchAllTasks()
                    .first(where: { $0.id == id }) else { return }
            task.isDone = flag
            try? CoreDataManager.shared.updateTask(task)
        }
    }

    // MARK: search
    func search(query: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let lower = query.lowercased()
            let tasks = (try? CoreDataManager.shared.fetchAllTasks()) ?? []
            let filtered = query.isEmpty
              ? tasks
              : tasks.filter {
                    $0.title.lowercased().contains(lower)
                 || $0.taskDescription.lowercased().contains(lower)
                }
            DispatchQueue.main.async { [weak self] in
                self?.output?.didLoadTasks(filtered)
            }
        }
    }
}
