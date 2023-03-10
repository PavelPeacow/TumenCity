//
//  SceneDelegate.swift
//  TumenCity
//
//  Created by Павел Кай on 15.02.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let nav = UINavigationController(rootViewController: MainMenuViewController())
        window.rootViewController = nav
        window.makeKeyAndVisible()
        
        self.window = window
    }

}

