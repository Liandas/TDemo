//
//  SceneDelegate.swift
//  TDemo
//
//  Created by Arda Doğantemur on 29.04.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navController = storyboard.instantiateInitialViewController() as! UINavigationController

        let network = NetworkImp(urlSession: .shared)
        let repository = ProductRepositoryImp(network: network, persistence: PersistenceCoreDataImp.shared)
        let homeViewModel = HomeViewModel(repository: repository)
        let homeVC = HomeViewController.instantiate(with: homeViewModel)

        navController.pushViewController(homeVC, animated: false)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navController
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

