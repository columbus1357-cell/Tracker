//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Aleksandr on 25.11.2026.
//

import UIKit

// MARK: - ScheduleViewControllerDelegate

protocol ScheduleViewControllerDelegate: AnyObject {
    func scheduleViewController(_ controller: ScheduleViewController, didSelectDays days: [Weekday])
}

// MARK: - ScheduleViewController

final class ScheduleViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: ScheduleViewControllerDelegate?

    private var selectedDays: Set<Weekday>
    private let weekdays: [Weekday] = Weekday.allCases

    // MARK: - UI Elements

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(resource: .ypWhite)
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WeekdayCell")
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(resource: .ypWhite), for: .normal)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization

    init(selectedDays: [Weekday]) {
            self.selectedDays = Set(selectedDays)
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            nil
        }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Расписание"
        view.backgroundColor = UIColor(resource: .ypWhite)
        setupViews()
    }

    // MARK: - Private Methods

    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -24),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func title(for weekday: Weekday) -> String {
        switch weekday {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }

    private func applyCornerMask(to view: UIView, indexPath: IndexPath, totalRows: Int, radius: CGFloat = 16) {
        view.layer.masksToBounds = true

        if totalRows == 1 {
            view.layer.cornerRadius = radius
            view.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        } else if indexPath.row == 0 {
            view.layer.cornerRadius = radius
            view.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
        } else if indexPath.row == totalRows - 1 {
            view.layer.cornerRadius = radius
            view.layer.maskedCorners = [
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        } else {
            view.layer.cornerRadius = 0
            view.layer.maskedCorners = []
        }
    }

    // MARK: - Actions

    @objc private func switchValueChanged(_ sender: UISwitch) {
        let dayIndex = sender.tag
        guard weekdays.indices.contains(dayIndex) else { return }
        let day = weekdays[dayIndex]

        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }

    @objc private func doneButtonTapped() {
        let orderedDays = weekdays.filter { selectedDays.contains($0) }
        delegate?.scheduleViewController(self, didSelectDays: orderedDays)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekdays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeekdayCell", for: indexPath)
        let day = weekdays[indexPath.row]

        cell.textLabel?.text = title(for: day)
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = UIColor(resource: .ypBlack)
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(resource: .ypBackground)

        let toggle = UISwitch()
        toggle.tag = indexPath.row
        toggle.isOn = selectedDays.contains(day)
        toggle.onTintColor = UIColor(resource: .ypBlue)
        toggle.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        cell.accessoryView = toggle

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        applyCornerMask(to: cell, indexPath: indexPath, totalRows: weekdays.count, radius: 16)
    }
}
