//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Aleksandr on 25.11.2026.
//

import UIKit

// MARK: - TrackerCollectionViewCellDelegate

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func didTapCompleteButton(in cell: TrackerCollectionViewCell)
}

// MARK: - TrackerCollectionViewCell

final class TrackerCollectionViewCell: UICollectionViewCell {

    // MARK: - Static Properties

    static let reuseIdentifier = "TrackerCollectionViewCell"

    // MARK: - Properties

    weak var delegate: TrackerCollectionViewCellDelegate?

    // MARK: - UI Elements

    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiCircleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "YPBlack") ?? .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(
        with tracker: Tracker,
        isCompleted: Bool,
        completedDaysCount: Int,
        isFutureDate: Bool
    ) {
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        daysLabel.text = daysWordForm(for: completedDaysCount)

        actionButton.isEnabled = !isFutureDate
        actionButton.alpha = isFutureDate ? 0.3 : 1.0

        let iconName = isCompleted ? "checkmark" : "plus"
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        let image = UIImage(systemName: iconName, withConfiguration: iconConfig)
        actionButton.setImage(image, for: .normal)
        actionButton.backgroundColor = isCompleted
            ? tracker.color.withAlphaComponent(0.3)
            : tracker.color
    }

    // MARK: - Actions

    @objc private func actionButtonTapped() {
        delegate?.didTapCompleteButton(in: self)
    }

    // MARK: - Private Methods

    private func daysWordForm(for count: Int) -> String {
        let mod100 = count % 100
        if mod100 >= 11 && mod100 <= 19 {
            return "\(count) дней"
        }
        switch count % 10 {
        case 1: return "\(count) день"
        case 2, 3, 4: return "\(count) дня"
        default: return "\(count) дней"
        }
    }

    private func setupViews() {
        contentView.addSubview(cardView)
        cardView.addSubview(emojiCircleView)
        emojiCircleView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)

        contentView.addSubview(daysLabel)
        contentView.addSubview(actionButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            emojiCircleView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiCircleView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiCircleView.widthAnchor.constraint(equalToConstant: 24),
            emojiCircleView.heightAnchor.constraint(equalToConstant: 24),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiCircleView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiCircleView.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            daysLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -8),

            actionButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            actionButton.widthAnchor.constraint(equalToConstant: 34),
            actionButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
}
