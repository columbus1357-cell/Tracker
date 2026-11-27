//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Aleksandr on 23.11.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)

        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
        if hasCompletedOnboarding {
            window.rootViewController = TabBarController()
        } else {
            let onboardingVC = OnboardingViewController()
            onboardingVC.onFinish = { [weak self] in
                guard let self else { return }
                UserDefaults.standard.set(true, forKey: self.hasCompletedOnboardingKey)
                self.window?.rootViewController = TabBarController()
            }
            window.rootViewController = onboardingVC
        }

        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }
}
