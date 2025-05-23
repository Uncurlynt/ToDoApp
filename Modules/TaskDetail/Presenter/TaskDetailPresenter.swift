//
//  TaskDetailPresenter.swift
//  ToDoApp
//
//  Created by Артемий Андреев  on 21.05.2025.
//

import Foundation
import CoreData

final class TaskDetailPresenter {
    weak var view: TaskDetailViewProtocol?
    weak var delegate: TaskDetailDelegate?
    var interactor: TaskDetailInteractorInput!
    var router: TaskDetailRouterProtocol!

    private let mode: TaskDetailMode
    private var currentTask: TaskModel? {
        if case .edit(let t) = mode { return t } else { return nil }
    }

    init(mode: TaskDetailMode) { self.mode = mode }
}

// MARK: - PresenterProtocol
extension TaskDetailPresenter: TaskDetailPresenterProtocol {

    func viewDidLoad() {
        if let t = currentTask {
            view?.showTask(title: t.title,
                           taskDescription: t.taskDescription,
                           isDone: t.isDone)
        }
    }

    func save(title: String,
              taskDescription: String,
              isDone: Bool) {

        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            view?.showError("Название не может быть пустым")
            return
        }

        switch mode {
        case .new:
            interactor.addTask(title: title,
                               taskDescription: taskDescription,
                               isDone: isDone)
        case .edit(var task):
            task.title       = title
            task.taskDescription = taskDescription
            task.isDone      = isDone
            interactor.updateTask(model: task)
        }
    }

    func delete() {
        guard let id = currentTask?.id else { return }
        interactor.deleteTask(id: id)
    }
}

// MARK: - Interactor Output
extension TaskDetailPresenter: TaskDetailInteractorOutput {
    func didAdd(_ task: TaskModel) {
        delegate?.didAddTask(task)
        view?.close()
    }
    func didUpdate(_ task: TaskModel) {
        delegate?.didUpdate(task)
        view?.close()
    }
    func didDelete(id: NSManagedObjectID) {
        delegate?.didDelete(id: id)
        view?.close()
    }

    func didFail(_ error: Error) {
        view?.showError(error.localizedDescription)
    }
}

