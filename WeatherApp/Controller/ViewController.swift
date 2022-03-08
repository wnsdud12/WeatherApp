//
//  ViewController.swift
//  WeatherApp 주륵주륵
//
//  Created by sumwb on 2022/02/17.
//
// 제발 되어라

import UIKit
import CoreLocation

/* 필요한 아이콘
 SKY(PTY가 없음일 때) 맑음(낮v,밤v), 구름많음(낮v,밤v), 흐림v
 PTY 비v, 비/눈, 눈v, 소나기
 */


/// - 해야 할 것
///     1. 지역 검색 기능
///        - 전화번호 입력화면 같은 버튼 여러 개로 만들 생각
///        - juso.go.kr의 공공데이터 사용 필요할지 고민중
///     2. lblSKY(하늘상태, 강수형태) -> 이미지뷰로 바꾸기
///     3. UI 꾸미기
///     4. 백그라운드에서 계속 업데이트 해서 눈/비 알림
///     5. baseTime의 한 시간 후부터의 데이터만 받아옴
///         - 검색한 시간이 02:20(baseTime = 0200)일 때 받아온 데이터의 제일 처음 값은 03시의 값
///     6. 검색한 날짜의 최저/최고 기온이 확인이 안될 때가 있음(API상에서는 tmn-오전6시, tmx-오후3시에만 검색되는 듯함)
///         - 오전 6시 이전에 데이터를 검색하면 오늘의 최저/최고 기온이 모두 확인 가능하지만 다른 시간대엔 최고 기온만 확인 혹은 최저/최고 둘 다 확인 불가할 때가 있음
///     5, 6 완성은 했으나 수정 전 코드를 지우지 않았고 새 코드도 조금 다듬어야 할듯
class ViewController: UIViewController, UITableViewDataSource {
    
    
    
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblTMPNow: UILabel!
    @IBOutlet weak var lblTMN: UILabel!
    @IBOutlet weak var lblTMX: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    var timeArray: [[String]] = []
    var valueArray: [[ItemValue]] = []
    var sections: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        weatherManager.delegate = self
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
        
        tableView.dataSource = self
    }
    
    //    // 나중에 다른 뷰에 갔다가 다시 돌아오는 상황을 만들게 되면 viewWillAppear에 코딩
    //    override func viewWillAppear(_ animated: Bool) {
    //        weatherManager.fetchWeather()
    //    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WeatherTableViewCell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherTableViewCell
        //if sections[indexPath.section] != nil {
            cell.lblTime.text = self.timeArray[indexPath.section][indexPath.row]
            cell.lblTMP.text = self.valueArray[indexPath.section][indexPath.row]["TMP"]
            cell.lblSKY.text = self.valueArray[indexPath.section][indexPath.row]["SKY"]
            cell.lblPOP.text = self.valueArray[indexPath.section][indexPath.row]["POP"]
            cell.lblPCP.text = self.valueArray[indexPath.section][indexPath.row]["PCP"]
        //}
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if sections[section] != nil {
//            return timeArray[section].count
//        } else {
//            return 0
//        }
        return timeArray[section].count
    }
}
extension ViewController: WeatherManagerDelegate {
    
    func didUpdateWeatherTable(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            // TableView에 보여질 데이터 - WeatherModel
            self.timeArray = weather.timeArray
            self.valueArray = weather.valueArray
            self.sections = weather.sections
            
            
            //print(self.valueArray)
            
            self.tableView.reloadData() // 데이터가 다 들어오면 테이블뷰 reload -> API를 받아오는 것보다 테이블뷰가 로딩되는 속도가 더 빠르기 때문에 이 코드가 없으면 테이블뷰에 표시할 데이터를 받아와서 가공하기 전에 테이블뷰가 먼저 만들어져서 화면에 표시가 안됨
        }
    }
    func didUpdateWeatherTMPs(_ weatherManager: WeatherManager, tmp: WeatherTMPModel) {
        DispatchQueue.main.async {
            // 일일 최저/최고 기온, 현재 기온 데이터 - WeatherTMPModel
            self.lblTMPNow.text = tmp.nowTMP
            self.lblTMN.text = tmp.todayTMPArray[0].1["TMN"] ?? "-"
            self.lblTMX.text = tmp.todayTMPArray[0].1["TMX"] ?? "-"
        }
    }
    
    func didFailWithError(error: Error, errorMsg: String) {
        print(error.localizedDescription)
        print(errorMsg)
    }
}
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            locationManager.stopUpdatingLocation()
            
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
                    self.lblAddress.text = address
                    print("현재 위치 : \(address)")
                }
            }
            
            let mapConvert = MapConvert(lon: lon, lat: lat) // 현재 위치의 위/경도를 격자 X/Y로 변환
            weatherManager.fetchWeather(nx: mapConvert.x, ny: mapConvert.y)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location Error - \(error)")
    }
}
