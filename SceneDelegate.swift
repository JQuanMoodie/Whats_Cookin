//
//  SceneDelegate.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/16/24.
//
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)

        let splashScreenViewController = SplashScreenViewController()
        window.rootViewController = splashScreenViewController
        self.window = window
        window.makeKeyAndVisible()

        splashScreenViewController.simulateLoading {
            self.setRootViewController()
        }
    }

    func setRootViewController() {
        let isLoggedIn = UserDefaults.standard.string(forKey: "username") != nil
        let rootViewController: UIViewController
        if (isLoggedIn) {
            let homeViewController = HomeViewController()
            rootViewController = UINavigationController(rootViewController: homeViewController)
        } else {
            let loginViewController = LoginViewController()
            loginViewController.delegate = self
            rootViewController = loginViewController
        }
        self.window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Handle any tasks needed when the app enters the background.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Handle any tasks needed when the app becomes active.
    }
}

extension SceneDelegate: LoginViewControllerDelegate {
    func didLoginSuccessfully(username: String) {
        print("Login successful for user: \(username)")
        UserDefaults.standard.set(username, forKey: "username")

        let homeViewController = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeViewController)
        if let window = self.window {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
}


