//
//  TaskDetailInteractor.swift
//  ToDoApp
//
//  Created by Артемий Андреев  on 21.05.2025.
//

import Foundation
import CoreData

final class TaskDetailInteractor: TaskDetailInteractorInput {

    weak var output: TaskDetailInteractorOutput?

    func addTask(title: String, taskDescription: String, isDone: Bool) {
        DispatchQueue.global().async {
            do {
                let model = try CoreDataManager.shared
                    .addTask(title: title,
                             taskDescription: taskDescription,
                             isDone: isDone)
                DispatchQueue.main.async { [weak self] in
                    self?.output?.didAdd(model)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.output?.didFail(error)
                }
            }
        }
    }

    func updateTask(model: TaskModel) {
        DispatchQueue.global().async {
            do {
                try CoreDataManager.shared.updateTask(model)
                DispatchQueue.main.async { [weak self] in
                    self?.output?.didUpdate(model)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.output?.didFail(error)
                }
            }
        }
    }

    func deleteTask(id: NSManagedObjectID) {
        DispatchQueue.global().async {
            do {
                try CoreDataManager.shared.deleteTask(id: id)
                DispatchQueue.main.async { [weak self] in
                    self?.output?.didDelete(id: id)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.output?.didFail(error)
                }
            }
        }
    }
}
