//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Aleksandr on 27.11.2026.
//

import UIKit

final class OnboardingViewController: UIPageViewController {

    var onFinish: (() -> Void)?

    private lazy var pages: [UIViewController] = {
        let firstPage = OnboardingPageViewController(
            image: UIImage(named: "onboardingTrackersBackground"),
            title: "Отслеживайте только то, что хотите",
            onButtonTap: { [weak self] in
                self?.onFinish?()
            }
        )

        let secondPage = OnboardingPageViewController(
            image: UIImage(named: "onboardingHabitsBackground"),
            title: "Даже если это не литры воды и йога",
            onButtonTap: { [weak self] in
                self?.onFinish?()
            }
        )

        return [firstPage, secondPage]
    }()

    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = pages.count
        control.currentPage = 0
        control.currentPageIndicatorTintColor = .black
        control.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.3)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    init() {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }

        setupPageControl()
    }

    private func setupPageControl() {
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = currentIndex - 1
        if previousIndex < 0 {
            return pages.last
        }
        return pages[previousIndex]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = currentIndex + 1
        if nextIndex >= pages.count {
            return pages.first
        }
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let currentViewController = pageViewController.viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentViewController) else {
            return
        }

        pageControl.currentPage = currentIndex
    }
}
