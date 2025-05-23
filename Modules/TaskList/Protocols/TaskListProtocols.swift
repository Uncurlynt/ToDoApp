//
//  TaskListProtocols.swift
//  ToDoApp
//
//  Created by Артемий Андреев  on 21.05.2025.
//

import Foundation
import UIKit
import CoreData


// MARK: View ↔ Presenter
protocol TaskListViewProtocol: AnyObject {
    func showTasks(_ tasks: [TaskViewModel])
    func showLoading(_ flag: Bool)
    func showError(_ message: String)
}

protocol TaskListPresenterProtocol: AnyObject {
    var tasksCount: Int { get }
    func viewDidLoad()
    func addTapped()
    func didSelectRow(at index: Int)
    func toggleDone(at index: Int)
    func delete(at index: Int)
    func search(text: String)
}

// MARK: Presenter ↔ Interactor
protocol TaskListInteractorInput: AnyObject {
    func loadTasks()
    func initialImport()
    func deleteTask(id: NSManagedObjectID)
    func toggleDone(id: NSManagedObjectID, flag: Bool)
    func search(query: String)
}

protocol TaskListInteractorOutput: AnyObject {
    func didLoadTasks(_ tasks: [TaskModel])
    func didFail(_ error: Error)
}

// MARK: Router
protocol TaskListRouterProtocol: AnyObject {
    func openAdd(from view: UIViewController, delegate: TaskDetailDelegate)
    func openEdit(task: TaskModel, from view: UIViewController, delegate: TaskDetailDelegate)
}

struct TaskViewModel {
    let id: NSManagedObjectID
    let title: String
    let taskDescription: String
    let date: String
    let status: String
    let done: Bool
}
