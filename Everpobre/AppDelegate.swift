//
//  AppDelegate.swift
//  Everpobre
//
//  Created by Rafael Lujan on 8/3/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        let noteVC = NoteListViewController()
        let emptyVC = UIViewController()
        emptyVC.view.backgroundColor = .white
        let splitVC = UISplitViewController()
        splitVC.delegate = self
        splitVC.viewControllers = [noteVC.wrappedNavigation(), emptyVC]
        //window?.rootViewController = UINavigationController(rootViewController:NoteListViewController())
        window?.rootViewController = splitVC
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
}

extension AppDelegate: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
