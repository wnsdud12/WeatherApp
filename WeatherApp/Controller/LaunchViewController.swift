//
//  LaunchViewController.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/04/13.
//



import UIKit
import CoreLocation

class LaunchViewController: UIViewController {

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("// LaunchViewController - viewDidLoad //")

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    override func viewWillAppear(_ animated: Bool) {
        print("// LaunchViewController - viewWillAppear //")
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)

        // 앱 최초 실행여부 확인
        print("")
        print("==============")
        print("\(UserDefaults.isFirst == nil ? "첫 실행" : "실행한 적 있음")")
        print("==============")
        print("")
        if UserDefaults.isFirst == nil {
            locationManager.requestWhenInUseAuthorization()
        } else {
            print("")
            print("==============")
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
                    locationManager.startUpdatingLocation()
                case .notDetermined, .restricted:
                    locationManager.requestWhenInUseAuthorization()
                case .denied:
                    print("denied")
                @unknown default:
                    break
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(endLocation), name: .end_didUpdateLocations, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        print("// LaunchViewController - viewDidAppear //")
        super.viewDidAppear(animated)
    }
    @objc func endLocation() {
        print("addObserver")
        let mainVC = storyboard?.instantiateViewController(identifier: "mainView") as! MainViewController
        mainVC.modalPresentationStyle = .fullScreen
        mainVC.modalTransitionStyle = .crossDissolve
        present(mainVC, animated: true)
    }
}

extension LaunchViewController: CLLocationManagerDelegate {
    // MARK: - CLLocation Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("start update location")
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
                if (UserDefaults.isFirst == nil) || (UserDefaults.grid_x == 0) {
                    UserDefaults.isFirst = true
                    let sidoVC = storyboard?.instantiateViewController(identifier: "sidoView") as! SidoViewController
                    sidoVC.modalPresentationStyle = .fullScreen
                    sidoVC.modalTransitionStyle = .crossDissolve
                    present(sidoVC, animated: true)
                } else {
                    let mainVC = storyboard?.instantiateViewController(identifier: "mainView") as! MainViewController
                    mainVC.modalPresentationStyle = .fullScreen
                    mainVC.modalTransitionStyle = .crossDissolve
                    present(mainVC, animated: true)
                }
            @unknown default:
                break
        }
    }
}
