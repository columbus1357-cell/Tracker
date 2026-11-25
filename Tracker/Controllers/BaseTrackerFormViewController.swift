//
//  BaseTrackerFormViewController.swift
//  Tracker
//
//  Created by Aleksandr on 25.11.2026.
//

import UIKit

// MARK: - BaseTrackerFormViewController

class BaseTrackerFormViewController: UIViewController {

    // MARK: - UI Elements

    lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = UIColor(resource: .ypBackground)
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

    lazy var categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor(resource: .ypBackground)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        configureOptionButton(button, title: "Категория", subtitle: nil)
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
        button.setTitleColor(UIColor(resource: .ypRed), for: .normal)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(resource: .ypRed).cgColor
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var createButton: UIButton = {
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
        view.backgroundColor = UIColor(resource: .ypWhite)
        setupBaseViews()
        setupAdditionalViews()
        setupHideKeyboardGesture()
        updateCreateButtonState()
    }

    // MARK: - Subclass Hooks

    func setupAdditionalViews() {}

    func isFormValid() -> Bool {
        trimmedTitle() != nil
    }

    func didTapCreateButton() {}

    // MARK: - Helpers

    func trimmedTitle() -> String? {
        guard let text = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return nil
        }
        return text
    }

    func configureOptionButton(_ button: UIButton, title: String, subtitle: String?) {
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.subtitle = subtitle
        configuration.titleAlignment = .leading
        configuration.baseForegroundColor = UIColor(resource: .ypBlack)
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            return outgoing
        }
        configuration.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            outgoing.foregroundColor = UIColor(resource: .ypGray)
            return outgoing
        }
        button.configuration = configuration
    }

    func updateCreateButtonState() {
        let isEnabled = isFormValid()
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled
            ? UIColor(resource: .ypBlack)
            : UIColor(resource: .ypGray)
        createButton.setTitleColor(UIColor(resource: .ypWhite), for: .normal)
    }

    // MARK: - Private Methods

    private func setupBaseViews() {
        view.addSubview(titleTextField)
        view.addSubview(buttonsStackView)

        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),

            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
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

    @objc func categoryButtonTapped() {
        // Экран «Категория» пока не функционирует
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func createButtonTapped() {
        didTapCreateButton()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension BaseTrackerFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
