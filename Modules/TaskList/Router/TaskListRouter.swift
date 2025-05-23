//
//  TaskListRouter.swift
//  ToDoApp
//
//  Created by Артемий Андреев  on 21.05.2025.
//

import UIKit

final class TaskListRouter: TaskListRouterProtocol {
    weak var viewController: UIViewController?

    static func createModule() -> UIViewController {
        let vc = TaskListViewController()
        let presenter = TaskListPresenter()
        let interactor = TaskListInteractor()
        let router = TaskListRouter()

        vc.presenter   = presenter
        presenter.view = vc
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        router.viewController = vc

        return vc
    }

    func openAdd(from view: UIViewController, delegate: TaskDetailDelegate) {
        let detail = TaskDetailRouter.createModule(mode: .new, delegate: delegate)
        view.navigationController?.pushViewController(detail, animated: true)
    }

    func openEdit(task: TaskModel,
                  from view: UIViewController,
                  delegate: TaskDetailDelegate) {
        let detail = TaskDetailRouter.createModule(mode: .edit(task), delegate: delegate)
        view.navigationController?.pushViewController(detail, animated: true)
    }
}
