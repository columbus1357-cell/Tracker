//
//  NewIrregularEventViewController.swift
//  Tracker
//
//  Created by Aleksandr on 25.11.2026.
//

import UIKit

// MARK: - NewIrregularEventViewControllerDelegate

protocol NewIrregularEventViewControllerDelegate: AnyObject {
    func newIrregularEventViewController(
        _ controller: NewIrregularEventViewController,
        didCreateTracker tracker: Tracker,
        categoryTitle: String
    )
}

// MARK: - NewIrregularEventViewController

final class NewIrregularEventViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: NewIrregularEventViewControllerDelegate?

    private let defaultCategoryTitle = "Мои события"

    // MARK: - UI Elements

    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = UIColor(named: "YPBackground") ?? .secondarySystemBackground
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.delegate = self

        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always

        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()

    private lazy var categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor(named: "YPBackground") ?? .secondarySystemBackground
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)

        var configuration = UIButton.Configuration.plain()
        configuration.title = "Категория"
        configuration.titleAlignment = .leading
        configuration.baseForegroundColor = UIColor(named: "YPBlack") ?? .label
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            return outgoing
        }
        button.configuration = configuration
        return button
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(named: "YPRed") ?? .systemRed, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = (UIColor(named: "YPRed") ?? .systemRed).cgColor
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новое нерегулярное событие"
        view.backgroundColor = UIColor(named: "YPWhite") ?? .systemBackground
        setupViews()
        setupHideKeyboardGesture()
        updateCreateButtonState()
    }

    // MARK: - Private Methods

    private func setupViews() {
        view.addSubview(titleTextField)
        view.addSubview(categoryButton)
        view.addSubview(buttonsStackView)

        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),

            categoryButton.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),

            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func updateCreateButtonState() {
        let hasTitle = !(titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        createButton.isEnabled = hasTitle
        createButton.backgroundColor = hasTitle
            ? (UIColor(named: "YPBlack") ?? .label)
            : (UIColor(named: "YPGray") ?? .systemGray3)
        createButton.setTitleColor(UIColor(named: "YPWhite") ?? .white, for: .normal)
    }
    
    private func setupHideKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions

    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }

    @objc private func categoryButtonTapped() {
        // Экран «Категория» пока не функционирует
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func createButtonTapped() {
            guard let rawTitle = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !rawTitle.isEmpty else {
                return
            }

        let newTracker = Tracker(
            id: UUID(),
            title: rawTitle,
            color: UIColor(named: "YPColorSelection5") ?? .systemGreen,
            emoji: "⚡️",
            schedule: [],
            createdDate: Date()
        )

            delegate?.newIrregularEventViewController(self, didCreateTracker: newTracker, categoryTitle: defaultCategoryTitle)
            dismiss(animated: true)
        }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension NewIrregularEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
