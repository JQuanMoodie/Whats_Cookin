//
//  SceneDelegate.swift
//  What's Cookin'
//
//  Created by Jevon Williams on 7/16/24.
//
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var logoutTimer: Timer?
    let logoutTimeInterval: TimeInterval = 300 // 5 minutes

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
        if isLoggedIn {
            let homeViewController = HomeViewController()
            rootViewController = UINavigationController(rootViewController: homeViewController)
            startLogoutTimer()
        } else {
            let loginViewController = LoginViewController()
            loginViewController.delegate = self
            rootViewController = loginViewController
        }
        self.window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()
    }

    func startLogoutTimer() {
        logoutTimer?.invalidate()
        logoutTimer = Timer.scheduledTimer(timeInterval: logoutTimeInterval, target: self, selector: #selector(logoutUser), userInfo: nil, repeats: false)
    }

    @objc func logoutUser() {
        UserDefaults.standard.removeObject(forKey: "username")
        let loginViewController = LoginViewController()
        loginViewController.delegate = self
        self.window?.rootViewController = loginViewController
        self.window?.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        logoutTimer?.invalidate()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if UserDefaults.standard.string(forKey: "username") != nil {
            startLogoutTimer()
        }
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
        startLogoutTimer()
    }
}

