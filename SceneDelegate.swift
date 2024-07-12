//
//  SceneDelegate.swift
//  what'sCookin
//
//  Created by Raisa Methila on 7/4/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        let loginViewController = LoginViewController()
        loginViewController.delegate = self
        window?.rootViewController = loginViewController
        window?.makeKeyAndVisible()
    }
}

extension SceneDelegate: LoginViewControllerDelegate {
    func didLoginSuccessfully() {
        let homeViewController = HomeViewController()
        window?.rootViewController = UINavigationController(rootViewController: homeViewController)
    }
}



