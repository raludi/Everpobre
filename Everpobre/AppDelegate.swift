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
        
        let noteListTVC = NoteTableViewController(style: .plain).wrappedNavigation()
        let noteDetailVC = NoteDetailViewController().wrappedNavigation()
        //NoteViewByCodeGestures2Controller()
        //NoteViewByCodeAnimationsController()
        //NoteViewByCodeWithGesturesController()
        //NoteViewController()
    
        let splitVC = UISplitViewController()
        splitVC.viewControllers = [noteListTVC, noteDetailVC]
        //window?.rootViewController = UINavigationController(rootViewController: NoteController())
        window?.rootViewController = UINavigationController(rootViewController:NoteListViewController())
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
}

