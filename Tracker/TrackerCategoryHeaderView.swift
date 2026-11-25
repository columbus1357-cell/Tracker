//
//  TrackerCategoryHeaderView.swift
//  Tracker
//
//  Created by Aleksandr on 25.11.2026.
//

import UIKit

// MARK: - TrackerCategoryHeaderView

final class TrackerCategoryHeaderView: UICollectionReusableView {

    // MARK: - Static Properties

    static let reuseIdentifier = "TrackerCategoryHeaderView"

    // MARK: - UI Elements

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(named: "YPBlack") ?? .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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

    func configure(with title: String) {
        titleLabel.text = title
    }

    // MARK: - Private Methods

    private func setupViews() {
        addSubview(titleLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
