//
//  TaskListViewController.swift
//  ToDoApp
//
//  Created by Артемий Андреев on 21.05.2025.
//

import UIKit

final class TaskListViewController: UIViewController {

    // MARK: – UI
    private var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)
    private let spinner = UIActivityIndicatorView(style: .large)

    private var countItem: UIBarButtonItem!

    var presenter: TaskListPresenterProtocol!
    private var viewModels: [TaskViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
        navigationController?.setToolbarHidden(false, animated: false)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Задачи"
        navigationItem.backButtonTitle = "Назад"

        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self

        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.backgroundColor = .systemBackground
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseID)
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)

        spinner.center = view.center
        spinner.hidesWhenStopped = true
        spinner.color = .label
        view.addSubview(spinner)

        countItem = UIBarButtonItem(
            title: "0 задач",
            style: .plain,
            target: nil,
            action: nil
        )
        countItem.isEnabled = false
        countItem.tintColor = .secondaryLabel

        let flex = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )

        let addItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )
        addItem.tintColor = .systemYellow

        toolbarItems = [flex, countItem, flex, addItem]
        navigationController?.toolbar.tintColor = .systemYellow
    }

    @objc private func addTapped() {
        presenter.addTapped()
    }
}

// MARK: – TaskListViewProtocol

extension TaskListViewController: TaskListViewProtocol {
    func showLoading(_ flag: Bool) {
        flag ? spinner.startAnimating() : spinner.stopAnimating()
    }

    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .cancel))
        present(alert, animated: true)
    }

    func showTasks(_ tasks: [TaskViewModel]) {
        viewModels = tasks
        countItem.title = "\(tasks.count) задач"
        tableView.reloadData()
    }
}

// MARK: – UITableViewDataSource & UITableViewDelegate

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = viewModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TaskCell.reuseID,
            for: indexPath
        ) as! TaskCell

        cell.configure(with: vm) { [weak self] in
            self?.presenter.toggleDone(at: indexPath.row)
        }
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tv: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.delete(at: indexPath.row)
        }
    }

    // MARK: – Context Menu Configuration

    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
            identifier: indexPath as NSCopying,
            previewProvider: nil
        ) { [weak self] _ in
            guard let self = self else { return UIMenu() }

            let edit = UIAction(
                title: "Редактировать",
                image: UIImage(systemName: "pencil")
            ) { _ in
                self.presenter.didSelectRow(at: indexPath.row)
            }

            let share = UIAction(
                title: "Поделиться",
                image: UIImage(systemName: "square.and.arrow.up")
            ) { _ in
                let vm = self.viewModels[indexPath.row]
                let text = vm.taskDescription.isEmpty
                    ? vm.title
                    : "\(vm.title)\n\n\(vm.taskDescription)"
                let sheet = UIActivityViewController(
                    activityItems: [text],
                    applicationActivities: nil
                )
                self.present(sheet, animated: true)
            }

            let delete = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self.presenter.delete(at: indexPath.row)
            }

            return UIMenu(title: "", children: [edit, share, delete])
        }
    }
}

// MARK: – UISearchBarDelegate

extension TaskListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        presenter.search(text: searchText)
    }
}

// MARK: – TaskCell

private final class TaskCell: UITableViewCell {

    static let reuseID = "TaskCell"

    private let titleLabel = UILabel()
    private let descLabel  = UILabel()
    private let dateLabel  = UILabel()
    private let doneButton = UIButton(type: .system)

    private var toggleHandler: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        [doneButton, titleLabel, descLabel, dateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        doneButton.addTarget(self,
                             action: #selector(toggle),
                             for: .touchUpInside)

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label

        descLabel.font  = .preferredFont(forTextStyle: .subheadline)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 2

        dateLabel.font  = .preferredFont(forTextStyle: .caption1)
        dateLabel.textColor = .tertiaryLabel

        let g = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            doneButton.widthAnchor.constraint(equalToConstant: 28),
            doneButton.heightAnchor.constraint(equalToConstant: 28),
            doneButton.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            doneButton.centerYAnchor.constraint(equalTo: g.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: doneButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: g.topAnchor),

            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 2),
            dateLabel.bottomAnchor.constraint(equalTo: g.bottomAnchor)
        ])
    }

    func configure(with vm: TaskViewModel,
                   toggleHandler: @escaping () -> Void) {
        self.toggleHandler = toggleHandler

        let symbol = vm.done ? "checkmark.circle" : "circle"
        doneButton.setImage(UIImage(systemName: symbol), for: .normal)
        doneButton.tintColor = vm.done ? .systemYellow : .secondaryLabel

        let attrs: [NSAttributedString.Key: Any] = vm.done
            ? [.strikethroughStyle: NSUnderlineStyle.single.rawValue,
               .foregroundColor: UIColor.secondaryLabel]
            : [:]
        titleLabel.attributedText = NSAttributedString(string: vm.title,
                                                       attributes: attrs)

        descLabel.text = vm.taskDescription
        dateLabel.text = vm.date
    }

    @objc private func toggle() {
        toggleHandler?()
    }
}
