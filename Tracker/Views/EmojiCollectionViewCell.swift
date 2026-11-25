//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Aleksandr on 25.11.2026.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiCollectionViewCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        contentView.backgroundColor = .clear
    }

    func configure(emoji: String, isSelected: Bool) {
        titleLabel.text = emoji
        contentView.backgroundColor = isSelected ? .systemGray5 : .clear
    }
}
