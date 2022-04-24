//
//  ViewController.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/03/16.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {

    @IBOutlet weak var lblAddress: UILabel?
    @IBOutlet weak var nowWeather: NowWeatherView?
    @IBOutlet weak var weatherTable: UITableView?

    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()

    // TableView 관련 데이터
    var sections: [String] = []
    var weatherArray: [WeatherModel]?
    var headerData: WeatherModel?

    // 현재 시간의 날씨 데이터
    var nowWeatherData: WeatherModel?


    let nowDate: String = {
        let date = Date.now
        let formater = DateFormatter()
        formater.dateFormat = "yyyyMMdd"
        let nowDate = formater.string(from: date)
        return nowDate
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        lblAddress?.adjustsFontSizeToFitWidth = true // 글씨 잘릴 때 자동으로 조정
        
        weatherManager.delegate = self
        
        let weatherTableXib = UINib(nibName: "WeatherTableViewCell", bundle: nil)
        weatherTable?.register(weatherTableXib, forCellReuseIdentifier: "weatherCell")

        // MARK: - TableView Setup
        weatherTable?.delegate = self
        weatherTable?.dataSource = self
        weatherTable?.backgroundColor = UIColor.systemGray6
        weatherTable?.register(UINib(nibName: "WeatherTableHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "WeatherTableHeader")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await self.weatherManager.fetchWeather(nx: UserDefaults.grid_x, ny: UserDefaults.grid_y)

            self.lblAddress?.text = UserDefaults.address
        }
    }
    @objc func fetch() async {
        await self.weatherManager.fetchWeather(nx: UserDefaults.grid_x, ny: UserDefaults.grid_y)
    }

}
// MARK: - TableView Delegate
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    // tableView footer 제거
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    // section header data
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = weatherTable?.dequeueReusableHeaderFooterView(withIdentifier: "WeatherTableHeader") as! WeatherTableHeader
        header.headerDate.text = convertDateString(fcstDate: sections[section])

        // 기상청에서 제공하는 데이터에서 특정 시간(최저기온 - 오전6시, 최고기온 - 오후3시)에만 최저/최고기온 데이터를 제공해주기 때문에 데이터를 받아올 수 없는 시간대면 - 표시
        header.headerTMX.text = self.weatherArray!.filter{ $0.date == sections[section]}.filter{ $0.value["TMX"] != nil}.first?.value["TMX"] ?? "-"
        header.headerTMN.text = self.weatherArray!.filter{ $0.date == sections[section]}.filter{ $0.value["TMN"] != nil}.first?.value["TMN"] ?? "-"
        return header
    }
    // section 높이
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    // section별 데이터 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dates = self.weatherArray!.filter{ $0.date == sections[section] }.count
        return dates
    }
    // section 갯수
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    // tableView에 들어갈 데이터 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherTableViewCell
        let row = self.weatherArray!.filter{ $0.date == sections[indexPath.section]}[indexPath.row]
        let skyAndPTY = setWeatherIcon(time: convertTimeString(fcstTime: row.time), state: row.value)
        cell.lblTime.text = convertTimeString(fcstTime: row.time)
        cell.lblTMP.text = row.value["TMP"]
        cell.lblPCP.text = row.value["PCP"]
        cell.lblPOP.text = row.value["POP"]
        cell.lblSKY.text = skyAndPTY.label
        cell.imgSKY.image = skyAndPTY.image
        return cell
    }
}

// MARK: - WeatherManager Delegate
extension MainViewController: WeatherManagerDelegate {
    func didUpdateWeatherTable(_ weatherManager: WeatherManager, weather: [WeatherModel]) {
        DispatchQueue.main.async {
            self.weatherArray = weather
            // 중복제거를 위해 세트로 변환했다가 배열로 다시 변환하기 때문에 순서가 섞여버려서 정렬까지 해준 후 대입
            self.sections = removeDuplicate(weather.map { $0.date }).sorted { $0 < $1 }
            self.weatherTable?.reloadData()
        }
    }
    func didUpdateNowWeatherData(_ weatherManager: WeatherManager, nowWeatherData: WeatherModel?) {
        DispatchQueue.main.async {
            if let nowWeatherData = nowWeatherData {
                self.nowWeather?.lblNowT1H.text = setNowWeatherData(model: nowWeatherData, key: "T1H")
                self.nowWeather?.lblNowRN1.text = setNowWeatherData(model: nowWeatherData, key: "RN1")
                self.nowWeather?.imgNowPTY.image = UIImage(named: setNowWeatherData(model: nowWeatherData, key: "PTY"))
            }
        }
    }
}
// 자료구분문자(category)의 코드값을 확인하고 구분에 맞는 예보 값(fcstValue)을 반환해주는 함수(초단기실황조회 전용)
private func setNowWeatherData(model: WeatherModel, key: String) -> String {
    var value: String = ""
    switch key {
        case "T1H": // 현재온도
            value = model.value[key]! + "º"
        case "RN1": // 1시간 강수량
            switch model.value[key]!.toDouble {
                case 0:
                    value = "강수없음"
                case (0.1 ..< 1.0):
                    value = "1.0mm 미만"
                case (1.0 ..< 30.0):
                    value = model.value[key]! + "mm"
                case (30.0 ..< 50.0):
                    value = "30.0~50.0mm"
                case (50.0 ... Double.infinity) :
                    value = "50.0mm 이상"
                default:
                    break
            }
        case "PTY": // 강수형태, 강수가 없을 시 맑음 아이콘 사용
            switch model.value[key]!.toInt {
                case 0: // 없음
                    if (600...2000).contains(model.time.toInt) {
                        value = "sunny.png"
                    } else {
                        value = "night.png"
                    }
                case 1: // 비
                    fallthrough
                case 5: // 빗방울
                    value = "rain.png"
                case 2: // 비/눈
                    fallthrough
                case 6: // 빗방울눈날림
                    value = "rainORsnowy.png"
                case 3: // 눈
                    fallthrough
                case 7: // 눈날림
                    value = "snow.png"
                default:
                    break
            }
        default:
            break
    }
    return value
}

// 날씨에 맞는 아이콘과 날씨 상태 받아오기
// rain.png(비)와 rain_shower.png(소나기)의 이미지가 비슷해서 앱 이용자가 구분하기 힘들 가능성이 있어 텍스트도 같이 반환함
private func setWeatherIcon(time: String, state: WeatherValue) -> (image: UIImage, label: String) {
    var isDay: Bool
    let time = time.dropLast()
    var iconName: String = ""
    var stateName: String = ""
    if (6...20).contains(time.description.toInt) {
        // 6~20시는 해, 그 외 시간에는 달로 표기
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
