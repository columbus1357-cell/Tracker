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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новое нерегулярное событие"
    }

    // MARK: - Overrides

    override func setupAdditionalViews() {
        categoryButton.backgroundColor = UIColor(resource: .ypBackground)
        view.addSubview(categoryButton)

        NSLayoutConstraint.activate([
            categoryButton.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryButton.heightAnchor.constraint(equalToConstant: 75)
        ])
    }

    override func didTapCreateButton() {
        guard let rawTitle = trimmedTitle() else {
            return
        }

        let newTracker = Tracker(
            id: UUID(),
            title: rawTitle,
            color: UIColor(resource: .ypColorSelection5),
            emoji: "⚡️",
            schedule: [],
            createdDate: Date()
        )

        delegate?.newIrregularEventViewController(self, didCreateTracker: newTracker, categoryTitle: defaultCategoryTitle)
        dismiss(animated: true)
    }
}
