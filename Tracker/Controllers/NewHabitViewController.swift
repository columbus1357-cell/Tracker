//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Aleksandr on 25.11.2026.
//

import UIKit

// MARK: - NewHabitViewControllerDelegate

protocol NewHabitViewControllerDelegate: AnyObject {
    func newHabitViewController(
        _ controller: NewHabitViewController,
        didCreateTracker tracker: Tracker,
        categoryTitle: String
    )
}

// MARK: - NewHabitViewController

final class NewHabitViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: NewHabitViewControllerDelegate?

    private let defaultCategoryTitle = "Мои привычки"
    private var selectedDays: [Weekday] = []

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

    private lazy var optionsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [categoryButton, separatorView, scheduleButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.backgroundColor = UIColor(named: "YPBackground") ?? .secondarySystemBackground
        stackView.layer.cornerRadius = 16
        stackView.clipsToBounds = true
        return stackView
    }()

    private lazy var categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        configureOptionButton(button, title: "Категория", subtitle: nil)
        return button
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "YPGray") ?? .separator
        return view
    }()

    private lazy var scheduleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        configureOptionButton(button, title: "Расписание", subtitle: nil)
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
        title = "Новая привычка"
        view.backgroundColor = UIColor(named: "YPWhite") ?? .systemBackground
        setupViews()
        setupHideKeyboardGesture()
        updateCreateButtonState()
        updateScheduleSubtitle()
    }

    // MARK: - Private Methods

    private func setupViews() {
        view.addSubview(titleTextField)
        view.addSubview(optionsStackView)
        view.addSubview(buttonsStackView)

        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),

            optionsStackView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            optionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75),

            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func configureOptionButton(_ button: UIButton, title: String, subtitle: String?) {
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.subtitle = subtitle
        configuration.titleAlignment = .leading
        configuration.baseForegroundColor = UIColor(named: "YPBlack") ?? .label
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            return outgoing
        }
        configuration.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            outgoing.foregroundColor = UIColor(named: "YPGray") ?? .secondaryLabel
            return outgoing
        }
        button.configuration = configuration
    }

    private func updateScheduleSubtitle() {
        let subtitle: String?
        if selectedDays.count == Weekday.allCases.count {
            subtitle = "Каждый день"
        } else if selectedDays.isEmpty {
            subtitle = nil
        } else {
            subtitle = selectedDays.map { shortTitle(for: $0) }.joined(separator: ", ")
        }
        configureOptionButton(scheduleButton, title: "Расписание", subtitle: subtitle)
    }

    private func shortTitle(for weekday: Weekday) -> String {
        switch weekday {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }

    private func updateCreateButtonState() {
        let hasTitle = !(titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let hasSchedule = !selectedDays.isEmpty
        let isEnabled = hasTitle && hasSchedule

        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled
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
        // Экран «Категория» по заданию этого урока пока не функционирует
    }

    @objc private func scheduleButtonTapped() {
        let scheduleVC = ScheduleViewController(selectedDays: selectedDays)
        scheduleVC.delegate = self
        let navController = UINavigationController(rootViewController: scheduleVC)
        present(navController, animated: true)
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func createButtonTapped() {
        guard let rawTitle = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !rawTitle.isEmpty,
              !selectedDays.isEmpty else {
            return
        }

        let newTracker = Tracker(
            id: UUID(),
            title: rawTitle,
            color: UIColor(named: "YPColorSelection5") ?? .systemGreen,
            emoji: "🌱",
            schedule: selectedDays
        )

        delegate?.newHabitViewController(self, didCreateTracker: newTracker, categoryTitle: defaultCategoryTitle)
        dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension NewHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - ScheduleViewControllerDelegate

extension NewHabitViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ controller: ScheduleViewController, didSelectDays days: [Weekday]) {
        selectedDays = days
        updateScheduleSubtitle()
        updateCreateButtonState()
    }
}
