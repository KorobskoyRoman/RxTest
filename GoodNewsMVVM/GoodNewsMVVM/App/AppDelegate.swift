//
//  AppDelegate.swift
//  GoodNewsMVVM
//
//  Created by Roman Korobskoy on 23.09.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        UINavigationBar.appearance().standardAppearance = configureNavBarAppearence()
        UINavigationBar.appearance().compactAppearance = configureNavBarAppearence()
        UINavigationBar.appearance().scrollEdgeAppearance = configureNavBarAppearence()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    private func configureNavBarAppearence() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        let color = UIColor(displayP3Red: 108/255, green: 92/255, blue: 231/255, alpha: 1.0)
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = color
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 26, weight: .bold)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 35, weight: .bold)]

        let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]

        appearance.backButtonAppearance = backButtonAppearance
        UINavigationBar.appearance().tintColor = .white

        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        return appearance
    }
}

