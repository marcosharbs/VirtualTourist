//
//  AppDelegate.swift
//  TuristaVirtual
//
//  Created by Marcos Harbs on 18/08/18.
//  Copyright © 2018 Marcos Harbs. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let dataController = DataController(modelName: "TuristaVirtual")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        self.dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let travelLocationsMapView = navigationController.topViewController as! TravelLocationsMapView
        travelLocationsMapView.dataController = self.dataController
        
        return true
    }
    
}
