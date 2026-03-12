//
//  App.swift
//  CareAssistance
//
//  Created by Lara Dubs on 01/08/2022.
//

import SwiftUI
import RealmSwift
import SDWebImageSVGCoder

@main
struct CareAssistanceApp: SwiftUI.App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    init() {
        var configuration = Realm.Configuration.defaultConfiguration
        configuration.deleteRealmIfMigrationNeeded = true
        let realmURL = configuration.fileURL!
        let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("default.realm") ?? realmURL
        configuration.fileURL = url
        Realm.Configuration.defaultConfiguration = configuration
        AppStatusManager.load()

        // For back button customization, setup the custom image for UINavigationBar.
        let barAppearance = UINavigationBar.appearance()
        barAppearance.backIndicatorImage = UIImage(named: "back")
        barAppearance.backIndicatorTransitionMaskImage = UIImage(named: "back")
        
        setUpDependencies() // Initialize SVGCoder
        #if CareAssistance
        print("The realm is stored \(Realm.Configuration.defaultConfiguration.fileURL!)")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}

private extension CareAssistanceApp {
    
    func setUpDependencies() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }
}
