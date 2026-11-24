//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Aleksandr on 24.11.2026.
//

import UIKit

final class TrackersViewController: UIViewController {
    
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
        return controller
    }()
    
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "EmptyTrackersIcon")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "YPBlack") ?? .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YPWhite") ?? .systemBackground
        setupNavigationBar()
        setupEmptyStateViews()
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
        addButton.tintColor = UIColor(named: "YPBlack") ?? .label
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
    
    @objc private func addButtonTapped() {
        // Логику добавления добавим позже
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        // Фильтрацию трекеров по дате добавим позже
    }
}
