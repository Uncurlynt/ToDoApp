//
//  TaskDetailRouter.swift
//  ToDoApp
//
//  Created by Артемий Андреев  on 21.05.2025.
//

import UIKit

final class TaskDetailRouter: TaskDetailRouterProtocol {
    weak var viewController: UIViewController?

    static func createModule(mode: TaskDetailMode,
                             delegate: TaskDetailDelegate) -> UIViewController {

        let vc = TaskDetailViewController()
        let presenter = TaskDetailPresenter(mode: mode)
        let interactor = TaskDetailInteractor()
        let router = TaskDetailRouter()

        vc.presenter  = presenter
        presenter.view = vc
        presenter.interactor = interactor
        presenter.router = router
        presenter.delegate = delegate
        interactor.output = presenter
        router.viewController = vc

        return vc
    }

    func closeDetail(_ view: UIViewController) {
        view.navigationController?.popViewController(animated: true)
    }
}

