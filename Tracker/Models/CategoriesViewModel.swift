//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Aleksandr on 27.11.2026.
//

import Foundation

typealias Binding<T> = (T) -> Void

final class CategoriesViewModel {

    // MARK: - Bindings

    var onCategoriesChange: Binding<[String]>?
    var onCategorySelected: Binding<String>?

    // MARK: - Private Properties

    private let categoryStore: TrackerCategoryStore
    private(set) var categories: [String] = [] {
        didSet {
            onCategoriesChange?(categories)
        }
    }
    private(set) var selectedCategory: String?

    // MARK: - Init

    init(
        categoryStore: TrackerCategoryStore = TrackerCategoryStore(),
        selectedCategory: String? = nil
    ) {
        self.categoryStore = categoryStore
        self.selectedCategory = selectedCategory
        self.categoryStore.delegate = self
    }

    // MARK: - Public Methods

    func loadCategories() {
        categories = categoryStore.fetchCategories().map { $0.title }
    }

    func addCategory(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        categoryStore.addCategory(title: trimmed)
    }

    func numberOfRows() -> Int {
        categories.count
    }

    func categoryTitle(at index: Int) -> String {
        categories[index]
    }

    func isCategorySelected(at index: Int) -> Bool {
        categories[index] == selectedCategory
    }

    func didSelectRow(at index: Int) {
        let category = categories[index]
        selectedCategory = category
        onCategoriesChange?(categories)
        onCategorySelected?(category)
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        loadCategories()
    }
}
