//
//  ViewController.swift
//  WeatherApp 주륵주륵
//
//  Created by sumwb on 2022/02/17.
//

import UIKit
import CoreLocation

/// - 해야 할 것
///     1. 지역 검색 기능
///        - 전화번호 입력화면 같은 버튼 여러 개로 만들 생각
///        - juso.go.kr의 공공데이터 사용 필요할지 고민중
///     2. lblSKY(하늘상태, 강수형태) -> 이미지뷰로 바꾸기, 이미지가 애매하여 옆에 라벨로 무슨 상태인지도 같이 표시
///     3. UI 꾸미기
///     4. 백그라운드에서 계속 업데이트 해서 눈/비 알림
///     5. baseTime의 한 시간 후부터의 데이터만 받아옴
///         - 검색한 시간이 02:20(baseTime = 0200)일 때 받아온 데이터의 제일 처음 값은 03시의 값
///     7. tableView에 표시되는 데이터 중 지난 시간의 데이터가 있음(baseTime이 3시간 간격이기 때문) -> 현재 시각 이후의 데이터만 보이게 수정해야 할듯
class ViewController: UIViewController {
    
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblTMPNow: UILabel!
    @IBOutlet weak var lblTMN: UILabel!
    @IBOutlet weak var lblTMX: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    var table_time: [[String]] = []
    var table_value: [[ItemValue]] = []
    var table_date: [String] = []
    
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
}


extension ViewController: WeatherManagerDelegate {
    
    func didUpdateWeatherTable(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            //TableView에 보여질 데이터 - WeatherModel
            self.table_time = weather.table_time
            self.table_value = weather.table_value
            self.table_date = weather.table_date
            
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


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WeatherTableViewCell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherTableViewCell
        cell.lblTime.text = convertTimeString(fcstTime: self.table_time[indexPath.section][indexPath.row])
        cell.lblTMP.text = self.table_value[indexPath.section][indexPath.row]["TMP"]
        cell.lblSKY.text = self.table_value[indexPath.section][indexPath.row]["SKY"]
        cell.lblPOP.text = self.table_value[indexPath.section][indexPath.row]["POP"]
        cell.lblPCP.text = self.table_value[indexPath.section][indexPath.row]["PCP"]
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return table_date.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return convertDateString(fcstDate: table_date[section])
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return table_time[section].count
    }
    
    // fcstTime로 받아온 시간 문자열의 형식인 HHmm을 HH시로 반환
    // ex) 1600 -> 16시
    private func convertTimeString(fcstTime: String) -> String {
        var timeString: String = ""
        if var intTime = Int(fcstTime) {
            intTime = intTime / 100
            timeString = String(intTime)
        }
        return timeString + "시"
    }
    
    // fcstDate로 받아온 날짜 문자열의 형식인 yyyyMMdd를 M월 d일 (E)로 변환
    // ex) 20220309 -> 3월 9일 (수)
    private func convertDateString(fcstDate: String) -> String {
        var dateString: String = ""
        var date: Date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyyMMdd"
        date = formatter.date(from: fcstDate)!
        
        formatter.dateFormat = "M월 d일 (E)"
        dateString = formatter.string(from: date)
        return dateString
    }
}
