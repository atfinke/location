//
//  AppDelegate.swift
//  location
//
//  Created by Andrew Finke on 1/24/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

// One file to rule them all...

import UIKit
import CoreLocation
import BackgroundTasks
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    
    // MARK: - Properties -
    
    private let manager = CLLocationManager()
    private var locationQueue = [Location]()
    private let locationModifyQueue = DispatchQueue(label: "com.andrewfinke.location.modify")
    
    private let backgroundTaskIdentifier = "com.andrewfinke.location.background"
    
    // MARK: - UIApplicationDelegate -
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        os_log("%{public}s: called", log: .updates, type: .info, #function)
        
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = true
        manager.startUpdatingLocation()
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
            os_log("%{public}s: register", log: .updates, type: .info, #function)
            self.manager.stopUpdatingLocation()
            self.manager.startUpdatingLocation()
            
            self.submitBackgroundTask()
            task.setTaskCompleted(success: true)
        }
        
        NotificationCenter.default.addObserver(forName: SceneDelegate.activeNotification, object: nil, queue: nil) { notification in
            os_log("%{public}s: active", log: .updates, type: .info, #function)
            self.syncLocations()
        }
        
        NotificationCenter.default.addObserver(forName: SceneDelegate.resignNotification, object: nil, queue: nil) { notification in
            os_log("%{public}s: resign", log: .updates, type: .info, #function)
            self.submitBackgroundTask()
        }
        
        return true
    }
    
    // MARK: - CLLocationManagerDelegate -
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        os_log("%{public}s: called, count: %{public}d", log: .updates, type: .info, #function, locations.count)
        let codableLocations = locations.map { Location($0) }
        
        locationModifyQueue.async {
            os_log("%{public}s: modifying queue", log: .updates, type: .info, #function)
            self.locationQueue.append(contentsOf: codableLocations)
            self.locationQueue = self.filter(locations: self.locationQueue)
            
            if self.locationQueue.count >= 10 {
                self.syncLocations()
            }
            
            let queueCountKey = "queueCount"
            let totalCountKey = "totalCount"
            let totalCount = UserDefaults.standard.integer(forKey: totalCountKey)
            UserDefaults.standard.set(self.locationQueue.count, forKey: queueCountKey)
            UserDefaults.standard.set(totalCount + locations.count, forKey: totalCountKey)
            
            os_log("%{public}s: queue count: %{public}d", log: .updates, type: .info, #function, self.locationQueue.count)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        os_log("%{public}s: called, error: %{public}s", log: .updates, type: .error, #function, error.localizedDescription)
        
        let key = "Errors"
        var errors = UserDefaults.standard.array(forKey: key) as? [String] ?? []
        errors.append(error.localizedDescription)
        UserDefaults.standard.set(errors, forKey: key)
    }
    
    func filter(locations: [Location]) -> [Location] {
        os_log("%{public}s: called", log: .filtering, type: .info, #function)
        
        if locations.count < 3 {
            return locations
        }
        
        var previousLocation = locations[0]
        var filteredLocations = [previousLocation]
        let locationsToFilter = Array(locations.dropFirst())
        
        for (index, location) in locationsToFilter.enumerated() {
            
            // If last index, we don't know if next will sig differ, so keep
            if index == locationsToFilter.count - 1 {
                filteredLocations.append(location)
                break
            }
            
            let nextLocation = locationsToFilter[index + 1]
            let isNextLocationSigDifferent = nextLocation.isSigDifferent(from: location)
            let isSigDifferentFromPrevious = location.isSigDifferent(from: previousLocation)
            
            if !isNextLocationSigDifferent && !isSigDifferentFromPrevious {
                os_log("location: filtered", log: .filtering, type: .debug)
            } else {
                os_log("location: sig diff from next/prev", log: .filtering, type: .debug)
                previousLocation = location
                filteredLocations.append(location)
            }
        }
        return filteredLocations
    }
    
    func syncLocations() {
        os_log("%{public}s: called", log: .updates, type: .info, #function)
        locationModifyQueue.async {
            os_log("%{public}s: starting", log: .updates, type: .info, #function)
            let group = DispatchGroup()
            group.enter()
            
            var request = URLRequest(url: Config.url)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue(UIDevice.current.identifierForVendor!.uuidString, forHTTPHeaderField: "Auth")
            request.httpMethod = "POST"
            request.httpBody = try? JSONEncoder().encode(self.locationQueue)
            
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    os_log("%{public}s: networkError: %{public}s", log: .updates, type: .error, #function, error.localizedDescription)
                    self.showNetworkError(message: error.localizedDescription)
                } else if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        os_log("%{public}s: success", log: .updates, type: .info, #function)
                        self.locationQueue = self.locationQueue.suffix(3)
                    } else {
                         os_log("%{public}s: networkStatusError: %{public}d", log: .updates, type: .error, #function, response.statusCode)
                        self.showNetworkError(message: "status: \(response.statusCode)")
                    }
                }
                group.leave()
            }
            task.resume()
            group.wait()
        }
    }
    
    private func showNetworkError(message: String) {
        DispatchQueue.main.async {
            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                let alert = UIAlertController(title: "network error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
                rootVC.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Background Tasks -
    
    private func submitBackgroundTask() {
        os_log("%{public}s: called", log: .updates, type: .info, #function)
        DispatchQueue.global().async {
            let request = BGAppRefreshTaskRequest(identifier: self.backgroundTaskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 30)
            do {
                try BGTaskScheduler.shared.submit(request)
                os_log("%{public}s: submitted", log: .updates, type: .info, #function)
            } catch {
                os_log("%{public}s: error: %{public}s", log: .updates, type: .error, #function, error.localizedDescription)
            }
        }
    }
    
    // MARK: - UISceneSession Lifecycle-
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        os_log("%{public}s: called", log: .updates, type: .info, #function)
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }
    
}
