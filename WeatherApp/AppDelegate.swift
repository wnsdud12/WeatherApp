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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("start - appDelegate_didFinishLaunchingWithOptions")
        // Override point for customization after application launch.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // 앱 최초 실행여부 확인
        print("")
        print("==============")
        print("\(UserDefaults.isFirst == nil ? "첫 실행" : "실행한 적 있음")")
        print("==============")
        print("")
        if UserDefaults.isFirst == nil {
            locationManager.requestWhenInUseAuthorization()
            UserDefaults.isFirst = true
        } else {
            print("")
            print("==============\nauthorizationStatus")
            print("""
                authorizationStatus.rawValue
                0 - notDetermined
                1 - restricted
                2 - denied
                3 - authorizedAlways
                4 - authorizedWhenInUse
                """)
            print("value => \(locationManager.authorizationStatus.rawValue)")
            print("==============")
            print("")
            switch locationManager.authorizationStatus {
                case .authorizedAlways, .authorizedWhenInUse:
                    break
                case .notDetermined, .restricted:
                    locationManager.requestWhenInUseAuthorization()
                case .denied:
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let sidoVC = storyboard.instantiateViewController(withIdentifier: "sidoView") as! SidoViewController
//                    window?.rootViewController = sidoVC
//                    window?.makeKeyAndVisible()
                    window?.rootViewController?.dismiss(animated: true)
                    window?.rootViewController?.present(sidoVC, animated: true)
                @unknown default:
                    break
            }
        }

        print("end - appDelegate_didFinishLaunchingWithOptions")
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
        print("start - locationManager")
        if let location = locations.last{
            self.locationManager.stopUpdatingLocation()
            UserDefaults.degree_lat = location.coordinate.latitude // 현재 위치의 위도
            UserDefaults.degree_lon = location.coordinate.longitude // 현재 위치의 경도
            //lamcproj(lat: UserDefaults.degree_lat, lon: UserDefaults.degree_lon, isWantGrid: true)
            lamcproj(lon_x: UserDefaults.degree_lon, lat_y: UserDefaults.degree_lat, isWantGrid: true) // 현재 위치의 위/경도를 격자 X/Y로 변환
            searchAddress()
            UserDefaults.printAll()
            NotificationCenter.default.post(name: .end_didUpdateLocations, object: nil)
        }
        print("end - locationManager")
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
                UserDefaults.isDenied = true
                UserDefaults.grid_x = 55
                UserDefaults.grid_y = 127
            @unknown default:
                break
        }
    }
}
