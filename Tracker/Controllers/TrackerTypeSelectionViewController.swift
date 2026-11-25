//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Aleksandr on 25.11.2026.
//

import UIKit

// MARK: - TrackerCreationType

enum TrackerCreationType {
    case habit
    case irregularEvent
}

// MARK: - TrackerTypeSelectionViewControllerDelegate

protocol TrackerTypeSelectionViewControllerDelegate: AnyObject {
    func trackerTypeSelectionViewController(
        _ controller: TrackerTypeSelectionViewController,
        didSelect type: TrackerCreationType
    )
}

// MARK: - TrackerTypeSelectionViewController

final class TrackerTypeSelectionViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: TrackerTypeSelectionViewControllerDelegate?

    // MARK: - UI Elements

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [habitButton, irregularEventButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()

    private lazy var habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(resource: .ypWhite), for: .normal)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(resource: .ypWhite), for: .normal)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Создание трекера"
        view.backgroundColor = UIColor(resource: .ypWhite)
        setupViews()
    }

    // MARK: - Private Methods

    private func setupViews() {
        view.addSubview(buttonsStackView)

        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Actions

    @objc private func habitButtonTapped() {
        delegate?.trackerTypeSelectionViewController(self, didSelect: .habit)
    }

    @objc private func irregularEventButtonTapped() {
        delegate?.trackerTypeSelectionViewController(self, didSelect: .irregularEvent)
    }
}
