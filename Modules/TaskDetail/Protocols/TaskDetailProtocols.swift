//
//  TaskDetailProtocols.swift
//  ToDoApp
//
//  Created by Артемий Андреев  on 21.05.2025.
//

import Foundation
import CoreData
import UIKit

enum TaskDetailMode {
    case new
    case edit(TaskModel)
}

protocol TaskDetailDelegate: AnyObject {
    func didAddTask(_ task: TaskModel)
    func didUpdate(_ task: TaskModel)
    func didDelete(id: NSManagedObjectID)
}

protocol TaskDetailViewProtocol: AnyObject {
    func showTask(title: String, taskDescription: String, isDone: Bool)
    func close()
    func showError(_ message: String)
}

protocol TaskDetailPresenterProtocol: AnyObject {
    func viewDidLoad()
    func save(title: String, taskDescription: String, isDone: Bool)
    func delete()
}

protocol TaskDetailInteractorInput: AnyObject {
    func addTask(title: String, taskDescription: String, isDone: Bool)
    func updateTask(model: TaskModel)
    func deleteTask(id: NSManagedObjectID)
}

protocol TaskDetailInteractorOutput: AnyObject {
    func didAdd(_ task: TaskModel)
    func didUpdate(_ task: TaskModel)
    func didDelete(id: NSManagedObjectID)
    func didFail(_ error: Error)
}

protocol TaskDetailRouterProtocol: AnyObject {
    func closeDetail(_ view: UIViewController)
}

