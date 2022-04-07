//
//  AppDelegate.swift
//  WeatherApp
//
//  Created by sumwb on 2022/02/17.
//

import UIKit
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("start - appDelegate_didFinishLaunchingWithOptions")
        // Override point for customization after application launch.
        locationManager.delegate = self

        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
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
}

extension AppDelegate: CLLocationManagerDelegate {
    // MARK: - CLLocation Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            locationManager.stopUpdatingLocation()
            print("location1")
            print(location)
            print("location2")
            print(CLLocation(latitude: CLLocationDegrees(37.462627), longitude: CLLocationDegrees(126.725397)))
            let lat = location.coordinate.latitude // 현재 위치의 위도
            let lon = location.coordinate.longitude // 현재 위치의 경도
            var address: String = ""
            // 현재 위치 지명 표시
            CLGeocoder().reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "Ko-kr")) {
                (placemarks, error) -> Void in
                if let pm = placemarks?.last {
                    if error != nil {
                        print("현재 위치를 받아올 수 없음 \(error.debugDescription)")
                    }
                    if pm.administrativeArea != nil {
                        address += pm.administrativeArea!
                    }
                    if pm.locality != nil {
                        address += " " + pm.locality!
                    }
                }
            }
            let mapConvert = MapConvert(lon: lon, lat: lat) // 현재 위치의 위/경도를 격자 X/Y로 변환
            print("address")
            print(findAddress(point: (mapConvert.x, mapConvert.y)))
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location Error - \(error)")
    }
}
