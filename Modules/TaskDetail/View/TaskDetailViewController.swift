//
//  TaskDetailViewController.swift
//  ToDoApp
//
//  Created by Артемий Андреев on 21.05.2025.
//

import UIKit

final class TaskDetailViewController: UIViewController {

    var presenter: TaskDetailPresenterProtocol!

    // MARK: — UI

    private let titleTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 32, weight: .bold)
        tv.contentInsetAdjustmentBehavior = .never
        tv.textColor = .label
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.textContainer.lineFragmentPadding = 0
        tv.textContainerInset = .zero
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let titlePlaceholder: UILabel = {
        let lbl = UILabel()
        lbl.text = "Название заметки"
        lbl.font = .systemFont(ofSize: 32, weight: .bold)
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.backgroundColor = .clear
        lbl.layer.masksToBounds = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 18)
        tv.textColor = .label
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let descriptionPlaceholder: UILabel = {
        let lbl = UILabel()
        lbl.text = "Текст заметки"
        lbl.font = .systemFont(ofSize: 18)
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // MARK: — Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPlaceholders()
        presenter.viewDidLoad()
    }

    // MARK: — Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.tintColor = .systemYellow
        navigationItem.backButtonTitle = "Назад"

        let saveButton = UIBarButtonItem(
            title: "Готово",
            style: .plain,
            target: self,
            action: #selector(saveTapped)
        )
        navigationItem.rightBarButtonItem = saveButton

        view.addSubview(titleTextView)
        titleTextView.addSubview(titlePlaceholder)
        view.addSubview(dateLabel)
        view.addSubview(descriptionTextView)
        descriptionTextView.addSubview(descriptionPlaceholder)

        titleTextView.delegate = self
        descriptionTextView.delegate = self

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleTextView.topAnchor.constraint(equalTo: safe.topAnchor, constant: -32),
            titleTextView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            titleTextView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            titleTextView.heightAnchor.constraint(equalToConstant: 44),

            titlePlaceholder.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor),
            titlePlaceholder.topAnchor.constraint(equalTo: titleTextView.topAnchor),

            dateLabel.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),

            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 24),
            descriptionTextView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            descriptionTextView.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -16),

            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 5),
            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 8)
        ])
    }

    private func setupPlaceholders() {
        titlePlaceholder.isHidden = !titleTextView.text.isEmpty
        descriptionPlaceholder.isHidden = !descriptionTextView.text.isEmpty
    }

    // MARK: - Save Action

    @objc private func saveTapped() {
        let title = titleTextView.text ?? ""
        let taskDescription = descriptionTextView.text ?? ""
        presenter.save(title: title, taskDescription: taskDescription, isDone: false)
    }
}

// MARK: — UITextViewDelegate

extension TaskDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === titleTextView {
            titlePlaceholder.isHidden = !textView.text.isEmpty
        } else if textView === descriptionTextView {
            descriptionPlaceholder.isHidden = !textView.text.isEmpty
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView === titleTextView && textView.text.isEmpty {
            titlePlaceholder.isHidden = true
        }
        if textView === descriptionTextView && textView.text.isEmpty {
            descriptionPlaceholder.isHidden = true
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView === titleTextView && textView.text.isEmpty {
            titlePlaceholder.isHidden = false
        }
        if textView === descriptionTextView && textView.text.isEmpty {
            descriptionPlaceholder.isHidden = false
        }
    }
}

// MARK: — TaskDetailViewProtocol

extension TaskDetailViewController: TaskDetailViewProtocol {
    func showTask(title: String, taskDescription: String, isDone: Bool) {
        titleTextView.text = title
        descriptionTextView.text = taskDescription
        dateLabel.text = Date().shortString
        setupPlaceholders()
    }

    func close() {
        navigationController?.popViewController(animated: true)
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
}
