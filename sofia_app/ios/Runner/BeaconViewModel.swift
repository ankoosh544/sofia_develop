//
//  BeaconViewModel.swift
//  iBeaconTest
//
//  Created by Ganesh Rangnath Shirole on 02/02/24.
//

import Foundation
import CoreLocation
import UserNotifications
import SwiftUI


class BeaconViewModel: NSObject, ObservableObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    private var locationManager: CLLocationManager?
    
    private var callback: ((String) -> Void)? = nil
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.requestPermissions()
    }
    
    private func requestPermissions() {
        locationManager?.requestAlwaysAuthorization()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            UNUserNotificationCenter.current().delegate = self
        }
    }
    
    func startMonitoring(callback: @escaping (String) -> Void) {
        
        self.callback = callback
        
        guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) else { return }
        
        let uuid = UUID(uuidString: "4D6FC88B-BE75-6698-DA48-6866A36EC78E")!
        let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: "com.accretion.iBeaconTest")
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        
        locationManager?.startMonitoring(for: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLBeaconRegion {
            showNotification(title: "Welcome", body: "You've entered the beacon region.")
            callback!("enter")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLBeaconRegion {
            showNotification(title: "Goodbye", body: "You've left the beacon region.")
            callback!("exit")
        }
    }
    
    private func showNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
