//
//  SceneDelegate.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import GoogleSignInSwift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        setupWindow(scene)
        
        if !Current.isSignedIn {
            showLoginViewController()
        } else {
            showHomeViewController()
        }
        window?.makeKeyAndVisible()
        guard let url = connectionOptions.urlContexts.first?.url else {
            return
        }
        handleDeepLink(url)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        handleDeepLink(urlContext.url)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

// MARK: - Setup
extension SceneDelegate {
    private func setupWindow(_ windowScene: UIWindowScene) {
        window = UIWindow(windowScene: windowScene)
        window?.tintColor = .systemRed
    }

    private func showLoginViewController() {
        let loginVC = LoginInteractor.build()
        window?.transitionTo(loginVC)
    }

    func showHomeViewController() {
        let homeVC = UINavigationController(rootViewController: HomeInteractor.build())
        let subscriptionsVC = UINavigationController(rootViewController: SubscriptionsInteractor.build())
        let settingsVC = UINavigationController(rootViewController: SettingsInteractor.build())
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [homeVC, subscriptionsVC, settingsVC]

        window?.transitionTo(tabBarController)
    }
}

// MARK: - Deep Linking
extension SceneDelegate {
    private func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        handleAppDeepLink(components)
    }

    private func handleAppDeepLink(_ components: URLComponents) {
        let pathComponents = components.path.components(separatedBy: "/")
        let channelId = pathComponents[0]
        let videoId = pathComponents[1]

        guard let tabVC = window?.rootViewController as? UITabBarController, let navVC = tabVC.viewControllers?[1] as? UINavigationController else { return }
        navVC.popToRootViewController(animated: false)
        let channelVC = ChannelInteractor.build(channelId: channelId)
        navVC.pushViewController(channelVC, animated: false)
        let videoVC = VideoInteractor.build(videoId: videoId, channelId: channelId)
        navVC.pushViewController(videoVC, animated: false)
        tabVC.selectedIndex = 1
    }
}

extension UIWindow {
    func transitionTo(_ destinationViewController: UIViewController) {
        let overlayView = UIScreen.main.snapshotView(afterScreenUpdates: false)
        destinationViewController.view.addSubview(overlayView)
        rootViewController = destinationViewController

        UIView.animate(withDuration: 0.4, delay: 0, options: .transitionCrossDissolve, animations: {
            overlayView.alpha = 0
        }, completion: { finished in
            overlayView.removeFromSuperview()
        })
    }
}
