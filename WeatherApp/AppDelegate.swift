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
    var window: UIWindow?
    let locationManager = CLLocationManager()
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("start - appDelegate_didFinishLaunchingWithOptions")
        // Override point for customization after application launch.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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

        print(locations)
        if let location = locations.last{
            self.locationManager.stopUpdatingLocation()
            //            print("location1 - 현재 위치")
            //            print(location)
            //            print("location2 - 임의로 설정한 새 위치(잘 입력 되나 테스트)")
            //            print(CLLocation(latitude: CLLocationDegrees(37.462627), longitude: CLLocationDegrees(126.725397)))

            UserDefaults.degree_lat = location.coordinate.latitude // 현재 위치의 위도
            UserDefaults.degree_lon = location.coordinate.longitude // 현재 위치의 경도
            lamcproj(lat: UserDefaults.degree_lat, lon: UserDefaults.degree_lon, isWantGrid: true) // 현재 위치의 위/경도를 격자 X/Y로 변환
            _ = searchAddress()
            UserDefaults.printAll()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "end_didUpdateLocations"), object: nil)
        }
    } // locationManager(_:didUpdateLocations:)

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location Error - \(error)")
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
            case .restricted, .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .denied:
                // 권한을 거부하면 SidoVC로 가서 지역 선택
                // 다음에 다시 킬때는 선택했던 지역으로 날씨 정보 표시
                break
            @unknown default:
                break
        }
    }
}
extension AppDelegate {

}
