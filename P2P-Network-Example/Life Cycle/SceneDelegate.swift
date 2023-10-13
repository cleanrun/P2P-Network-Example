//
//  SceneDelegate.swift
//  P2P-Network-Example
//
//  Created by cleanmac on 05/10/23.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: RoleChooserViewController())
        window?.makeKeyAndVisible()
    }
}

