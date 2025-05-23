//
//  TaskListPresenter.swift
//  ToDoApp
//
//  Created by Артемий Андреев  on 21.05.2025.
//

import Foundation
import CoreData
import UIKit


final class TaskListPresenter {
    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorInput!
    var router: TaskListRouterProtocol!

    private var tasks: [TaskModel] = []

    private lazy var df: DateFormatter = Date.todoDateFormatter
}

// MARK: - TaskListPresenterProtocol
extension TaskListPresenter: TaskListPresenterProtocol {

    var tasksCount: Int { tasks.count }

    func viewDidLoad() {
        view?.showLoading(true)
        if interactorIsEmpty {
            interactor.initialImport()
        } else {
            interactor.loadTasks()
        }
    }

    private var interactorIsEmpty: Bool {
        !CoreDataManager.shared.isInitialDataLoaded
    }

    func addTapped() {
        guard let viewVC = view as? UIViewController else { return }
        router.openAdd(from: viewVC, delegate: self)
    }

    func didSelectRow(at index: Int) {
        let task = tasks[index]
        guard let viewVC = view as? UIViewController else { return }
        router.openEdit(task: task, from: viewVC, delegate: self)
    }

    func toggleDone(at index: Int) {
        var task = tasks[index]
        task.isDone.toggle()
        tasks[index] = task
        interactor.toggleDone(id: task.id, flag: task.isDone)
        view?.showTasks(makeVMs(tasks))
    }

    func delete(at index: Int) {
        let task = tasks.remove(at: index)
        interactor.deleteTask(id: task.id)
        view?.showTasks(makeVMs(tasks))
    }

    func search(text: String) {
        interactor.search(query: text)
    }

    private func makeVMs(_ models: [TaskModel]) -> [TaskViewModel] {
        models.map {
            TaskViewModel(id: $0.id,
                          title: $0.title,
                          taskDescription: $0.taskDescription,
                          date: $0.createdAt.shortString,
                          status: $0.isDone ? "Выполнено" : "Не выполнено",
                          done: $0.isDone)
        }
    }
}

// MARK: - TaskListInteractorOutput
extension TaskListPresenter: TaskListInteractorOutput {
    func didLoadTasks(_ tasks: [TaskModel]) {
        self.tasks = tasks
        view?.showLoading(false)
        view?.showTasks(makeVMs(tasks))
    }

    func didFail(_ error: Error) {
        view?.showLoading(false)
        view?.showError(error.localizedDescription)
    }
}

// MARK: - TaskDetailDelegate
extension TaskListPresenter: TaskDetailDelegate {
    func didAddTask(_ task: TaskModel) {
        tasks.insert(task, at: 0)
        view?.showTasks(makeVMs(tasks))
    }

    func didUpdate(_ task: TaskModel) {
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx] = task
            view?.showTasks(makeVMs(tasks))
        }
    }

    func didDelete(id: NSManagedObjectID) {
        tasks.removeAll { $0.id == id }
        view?.showTasks(makeVMs(tasks))
    }
}
