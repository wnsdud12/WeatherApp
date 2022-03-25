//
//  ViewController.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/03/16.
//

import UIKit
import CoreLocation


class ViewController: UIViewController {


    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var nowWeather: NowWeatherView!
    @IBOutlet weak var weatherTable: UITableView!

    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()

    // TableView 관련 데이터
    var sections: [String] = []
    var cellTime: [[String]] = []
    var cellTMP: [[String]] = []
    var cellImgSKY: [[UIImage]] = []
    var cellSKYPTY: [[WeatherValue]] = []
    var cellPOP: [[String]] = []
    var cellPCP: [[String]] = []

    var nowWeatherData: NowWeather?

    let nowTime: Int = {
        let date = Date.now
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        let nowTime = formatter.string(from: date).toInt
        return nowTime
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        nowWeather.imgNowSKY.image = UIImage(named: "cloud_sun_svg.svg")
        nowWeather.imgNowSKY.frame.size = CGSize(width: 100, height: 100)
        locationManager.delegate = self
        weatherManager.delegate = self
        
        let weatherTableXib = UINib(nibName: "WeatherTableViewCell", bundle: nil)
        weatherTable.register(weatherTableXib, forCellReuseIdentifier: "weatherCell")
        
        weatherTable.delegate = self
        weatherTable.dataSource = self

        weatherTable.backgroundColor = UIColor.lightGray

        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
        
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // section별 데이터 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTime[section].count
    }
    // section 갯수
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    // section 제목 (날짜)
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    // tableView에 들어갈 데이터 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherTableViewCell

        let skyAndPTY = setWeatherIcon(time: self.cellTime[indexPath.section][indexPath.row], state: self.cellSKYPTY[indexPath.section][indexPath.row])
        cell.lblTime.text = self.cellTime[indexPath.section][indexPath.row]
        cell.lblTMP.text = self.cellTMP[indexPath.section][indexPath.row]
        cell.lblSKY.text = skyAndPTY.label
        cell.imgSKY.image = skyAndPTY.image
        cell.lblPOP.text = self.cellPOP[indexPath.section][indexPath.row]
        cell.lblPCP.text = self.cellPCP[indexPath.section][indexPath.row]

        return cell
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

extension ViewController: WeatherManagerDelegate {

    func didUpdateWeatherTable(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            print("didUpdateWeatherTable()")

            self.nowWeatherData = weather.nowWeatherData

            self.sections = weather.sections
            self.cellTime = weather.cellTime
            self.cellTMP = weather.cellTMP
            self.cellSKYPTY = weather.cellSKYPTY
            self.cellPOP = weather.cellPOP
            self.cellPCP = weather.cellPCP

            print(weather.nowWeatherData.value)
            self.nowWeather.lblNowTMP.text = self.nowWeatherData?.value["TMP"]
            self.nowWeather.imgNowSKY.image = setWeatherIcon(time: weather.nowWeatherData.time, state: weather.nowWeatherData.value).image

            self.weatherTable.reloadData()
        }

    }

    func didFailWithError(error: Error, errorMsg: String) {
        print(error)
    }

}

// 날씨에 맞는 아이콘과 날씨 상태 받아오기
// rain.png(비)와 rain_shower.png(소나기)의 이미지가 비슷해서 앱 이용자가 구분하기 힘들 가능성이 있어 텍스트도 같이 반환함
private func setWeatherIcon(time: String, state: WeatherValue) -> (image: UIImage, label: String) {
    var isDay: Bool
    let time = time.dropLast()
    var iconName: String = ""
    var stateName: String = ""
    if (6...20).contains(time.description.toInt) {
        isDay = true
    } else {
        isDay = false
    }

    if state["PTY"] == "없음" {
        stateName = state["SKY"]!
        switch state["SKY"] {
            case "맑음":
                iconName = isDay ? "sunny.png" : "night.png"
            case "구름많음":
                iconName = isDay ? "cloud_sun.png" : "cloud_night.png"
            case "흐림":
                iconName = "cloudy.png"
            default:
                break
        }
    } else {
        stateName = state["PTY"]!
        switch state["PTY"] {
            case "비":
                iconName = "rain.png"
            case "비/눈":
                iconName = "rainyORsnowy.png"
            case "눈":
                iconName = "snow.png"
            case "소나기":
                iconName = "rain_shower.png"
            default:
                break
        }
    }
    let image: UIImage = UIImage(named: iconName) ?? UIImage()
    return (image, stateName)
}
extension String {
    var toInt: Int {
        return Int(self)!
    }
}
