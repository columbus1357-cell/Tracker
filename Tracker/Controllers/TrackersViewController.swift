//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Aleksandr on 24.11.2026.
//

import UIKit

// MARK: - TrackersViewController

final class TrackersViewController: UIViewController {

    // MARK: - Properties

    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = [] {
        didSet {
            completedTrackerIDs = Set(completedTrackers.map(\.trackerId))
        }
    }
    private var completedTrackerIDs: Set<UUID> = []
    private var currentDate: Date = Date()
    private var visibleCategories: [TrackerCategory] = []

    // MARK: - UI Elements

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(resource: .ypWhite)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            TrackerCategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCategoryHeaderView.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.calendar.locale = Locale(identifier: "ru_RU")
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.widthAnchor.constraint(equalToConstant: 96).isActive = true
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return picker
    }()

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Поиск"
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchResultsUpdater = self
        return controller
    }()

    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .emptyTrackersIcon)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .ypWhite)
        setupNavigationBar()
        setupCollectionView()
        setupEmptyStateViews()
        reloadVisibleTrackers()
    }

    // MARK: - Private Methods

    private func setupCollectionView() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func addTracker(_ tracker: Tracker, toCategoryTitle categoryTitle: String) {
        var updatedCategories: [TrackerCategory] = []
        var isCategoryFound = false

        for category in categories {
            if category.title == categoryTitle {
                let updatedTrackers = category.trackers + [tracker]
                updatedCategories.append(
                    TrackerCategory(title: category.title, trackers: updatedTrackers)
                )
                isCategoryFound = true
            } else {
                updatedCategories.append(category)
            }
        }

        if !isCategoryFound {
            updatedCategories.append(
                TrackerCategory(title: categoryTitle, trackers: [tracker])
            )
        }

        categories = updatedCategories
    }

    private func setupNavigationBar() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        addButton.tintColor = UIColor(resource: .ypBlack)
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    private func setupEmptyStateViews() {
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }

    private func reloadVisibleTrackers() {
        let calendar = Calendar(identifier: .iso8601)
        let weekdayNumber = calendar.component(.weekday, from: currentDate)
        let selectedWeekday = Weekday(rawValue: weekdayNumber)
        let searchText = searchController.searchBar.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() ?? ""

        visibleCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesDate: Bool
                if tracker.schedule.isEmpty {
                    if let createdDate = tracker.createdDate {
                        matchesDate = Calendar.current.isDate(createdDate, inSameDayAs: currentDate)
                    } else {
                        matchesDate = Calendar.current.isDateInToday(currentDate)
                    }
                } else if let selectedWeekday {
                    matchesDate = tracker.schedule.contains(selectedWeekday)
                } else {
                    matchesDate = false
                }

                let matchesSearch = searchText.isEmpty || tracker.title.lowercased().contains(searchText)
                return matchesDate && matchesSearch
            }
            guard !filteredTrackers.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }

        let hasSearchQuery = !searchText.isEmpty
        emptyStateLabel.text = hasSearchQuery ? "Ничего не найдено" : "Что будем отслеживать?"

        let isEmpty = visibleCategories.isEmpty
        collectionView.isHidden = isEmpty
        emptyStateImageView.isHidden = !isEmpty
        emptyStateLabel.isHidden = !isEmpty
        collectionView.reloadData()
    }

    private func isFutureDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfSelectedDay = calendar.startOfDay(for: date)
        let startOfToday = calendar.startOfDay(for: Date())
        return startOfSelectedDay > startOfToday
    }

    private func isTrackerCompleted(_ trackerId: UUID, on date: Date) -> Bool {
        guard completedTrackerIDs.contains(trackerId) else { return false }
        return completedTrackers.contains { record in
            record.trackerId == trackerId && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }

    private func completedDaysCount(for trackerId: UUID) -> Int {
        guard completedTrackerIDs.contains(trackerId) else { return 0 }
        return completedTrackers.filter { $0.trackerId == trackerId }.count
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        let selectionVC = TrackerTypeSelectionViewController()
        selectionVC.delegate = self
        let navController = UINavigationController(rootViewController: selectionVC)
        present(navController, animated: true)
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        reloadVisibleTrackers()
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let isCompleted = isTrackerCompleted(tracker.id, on: currentDate)
        let daysCount = completedDaysCount(for: tracker.id)
        let future = isFutureDate(currentDate)

        cell.delegate = self
        cell.configure(
            with: tracker,
            isCompleted: isCompleted,
            completedDaysCount: daysCount,
            isFutureDate: future
        )
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                  ofKind: kind,
                  withReuseIdentifier: TrackerCategoryHeaderView.reuseIdentifier,
                  for: indexPath
              ) as? TrackerCategoryHeaderView else {
            return UICollectionReusableView()
        }

        let category = visibleCategories[indexPath.section]
        header.configure(with: category.title)
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let interitemSpacing: CGFloat = 9
        let availableWidth = collectionView.bounds.width - interitemSpacing
        let cellWidth = floor(availableWidth / 2)
        return CGSize(width: cellWidth, height: 148)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        9
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        16
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 34)
    }
}

// MARK: - TrackerCollectionViewCellDelegate

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func didTapCompleteButton(in cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard !isFutureDate(currentDate) else { return }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]

        if let existingIndex = completedTrackers.firstIndex(where: {
            $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }) {
            completedTrackers.remove(at: existingIndex)
        } else {
            completedTrackers.append(TrackerRecord(trackerId: tracker.id, date: currentDate))
        }

        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        reloadVisibleTrackers()
    }
}

// MARK: - NewHabitViewControllerDelegate

extension TrackersViewController: NewHabitViewControllerDelegate {
    func newHabitViewController(
        _ controller: NewHabitViewController,
        didCreateTracker tracker: Tracker,
        categoryTitle: String
    ) {
        addTracker(tracker, toCategoryTitle: categoryTitle)
        reloadVisibleTrackers()
    }
}

// MARK: - TrackerTypeSelectionViewControllerDelegate

extension TrackersViewController: TrackerTypeSelectionViewControllerDelegate {
    func trackerTypeSelectionViewController(
        _ controller: TrackerTypeSelectionViewController,
        didSelect type: TrackerCreationType
    ) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }

            switch type {
            case .habit:
                let newHabitVC = NewHabitViewController()
                newHabitVC.delegate = self
                let navController = UINavigationController(rootViewController: newHabitVC)
                self.present(navController, animated: true)

            case .irregularEvent:
                let newEventVC = NewIrregularEventViewController()
                newEventVC.delegate = self
                let navController = UINavigationController(rootViewController: newEventVC)
                self.present(navController, animated: true)
            }
        }
    }
}

// MARK: - NewIrregularEventViewControllerDelegate

extension TrackersViewController: NewIrregularEventViewControllerDelegate {
    func newIrregularEventViewController(
        _ controller: NewIrregularEventViewController,
        didCreateTracker tracker: Tracker,
        categoryTitle: String
    ) {
        addTracker(tracker, toCategoryTitle: categoryTitle)
        reloadVisibleTrackers()
    }
}
