//
//  AppDelegate.swift
//  location
//
//  Created by Andrew Finke on 1/24/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit
import CoreLocation
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    
    // MARK: - Properties -
    
    private let manager = CLLocationManager()
    private var lastLocation: CLLocation?
    private let backgroundTaskIdentifier = "com.andrewfinke.location.background"
    
    
    // MARK: - UIApplicationDelegate -
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = true
        manager.startUpdatingLocation()
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
            self.manager.stopUpdatingLocation()
            self.manager.startUpdatingLocation()
            
            self.submitBackgroundTask()
            task.setTaskCompleted(success: true)
        }
        
        NotificationCenter.default.addObserver(forName: SceneDelegate.resignNotification, object: nil, queue: nil) { notification in
            self.submitBackgroundTask()
        }
        
        return true
    }
    
    // MARK: - CLLocationManagerDelegate -
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let key = "Locations"
        var existingLocations = UserDefaults.standard.array(forKey: key) as? [String] ?? []
        let newLocations = locations.map { $0.description }
        
        existingLocations.append(contentsOf: newLocations)
        UserDefaults.standard.set(existingLocations, forKey: key)
        // Do something with the location.
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let key = "Errors"
        var errors = UserDefaults.standard.array(forKey: key) as? [String] ?? []
        errors.append(error.localizedDescription)
        UserDefaults.standard.set(errors, forKey: key)
    }
    
    // MARK: - Background Tasks -
    
    private func submitBackgroundTask() {
        DispatchQueue.global().async {
            let request = BGAppRefreshTaskRequest(identifier: self.backgroundTaskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 10)
            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - UISceneSession Lifecycle-
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }
    
}
