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
        let controller = buildMainMenuController()
        let nav = UINavigationController(rootViewController: controller)
        window.rootViewController = nav
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    private func buildMainMenuController() -> UIViewController {
        let builder = MainMenuBuilder()
        let router = MainMenuRouter(builder: builder)
        return MainMenuViewController(router: router)
    }

}

extension UINavigationController {
    
  open override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    navigationBar.topItem?.backButtonDisplayMode = .minimal
  }
    
}
