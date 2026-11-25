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

final class NewHabitViewController: BaseTrackerFormViewController {

    // MARK: - Properties

    weak var delegate: NewHabitViewControllerDelegate?

    private let defaultCategoryTitle = "Мои привычки"
    private var selectedDays: [Weekday] = []

    // MARK: - UI Elements

    private lazy var optionsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [categoryButton, separatorView, scheduleButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.backgroundColor = UIColor(resource: .ypBackground)
        stackView.layer.cornerRadius = 16
        stackView.clipsToBounds = true
        return stackView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(resource: .ypGray)
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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новая привычка"
        updateScheduleSubtitle()
    }

    // MARK: - Overrides

    override func setupAdditionalViews() {
        contentView.addSubview(optionsStackView)

        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75)
        ])
    }

    override func topAnchorForEmojiSection() -> NSLayoutYAxisAnchor {
        optionsStackView.bottomAnchor
    }

    override func isFormValid() -> Bool {
        super.isFormValid() && !selectedDays.isEmpty
    }

    override func didTapCreateButton() {
        guard let rawTitle = trimmedTitle(),
              !selectedDays.isEmpty else {
            return
        }

        let newTracker = Tracker(
            id: UUID(),
            title: rawTitle,
            color: selectedColor ?? UIColor(resource: .ypColorSelection5),
            emoji: selectedEmoji ?? "🌱",
            schedule: selectedDays
        )

        delegate?.newHabitViewController(self, didCreateTracker: newTracker, categoryTitle: defaultCategoryTitle)
        dismiss(animated: true)
    }

    // MARK: - Private Methods

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

    // MARK: - Actions

    @objc private func scheduleButtonTapped() {
        let scheduleVC = ScheduleViewController(selectedDays: selectedDays)
        scheduleVC.delegate = self
        let navController = UINavigationController(rootViewController: scheduleVC)
        present(navController, animated: true)
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
