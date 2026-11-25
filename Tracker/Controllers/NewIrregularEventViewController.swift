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

final class NewIrregularEventViewController: BaseTrackerFormViewController {

    // MARK: - Properties

    weak var delegate: NewIrregularEventViewControllerDelegate?

    private let defaultCategoryTitle = "Мои события"
    private let selectedDate: Date

    init(selectedDate: Date = Date()) {
        self.selectedDate = selectedDate
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новое нерегулярное событие"
    }

    // MARK: - Overrides

    override func setupAdditionalViews() {
        categoryButton.backgroundColor = UIColor(resource: .ypBackground)
        contentView.addSubview(categoryButton)

        NSLayoutConstraint.activate([
            categoryButton.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            categoryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryButton.heightAnchor.constraint(equalToConstant: 75)
        ])
    }

    override func topAnchorForEmojiSection() -> NSLayoutYAxisAnchor {
        categoryButton.bottomAnchor
    }

    override func didTapCreateButton() {
        guard let rawTitle = trimmedTitle() else {
            return
        }

        let newTracker = Tracker(
            id: UUID(),
            title: rawTitle,
            color: selectedColor ?? UIColor(resource: .ypColorSelection5),
            emoji: selectedEmoji ?? "⚡️",
            schedule: [],
            createdDate: selectedDate
        )

        delegate?.newIrregularEventViewController(self, didCreateTracker: newTracker, categoryTitle: defaultCategoryTitle)
        dismiss(animated: true)
    }
}
