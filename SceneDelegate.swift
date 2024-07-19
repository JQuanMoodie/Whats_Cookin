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

        let loginViewController = LoginViewController()
        loginViewController.delegate = self

        window.rootViewController = loginViewController
        self.window = window
        window.makeKeyAndVisible()
    }
}

extension SceneDelegate: LoginViewControllerDelegate {
    func didLoginSuccessfully(username: String) {
        print("Login successful for user: \(username)") // Debugging statement
        
        // Save username to UserDefaults
        UserDefaults.standard.set(username, forKey: "username")

        // Navigate to HomeViewController after successful login
        let homeViewController = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeViewController)
        if let window = self.window {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
}

