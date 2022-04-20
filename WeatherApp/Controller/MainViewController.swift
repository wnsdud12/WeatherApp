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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    // tableView footer 제거
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    // section header data
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = weatherTable?.dequeueReusableHeaderFooterView(withIdentifier: "WeatherTableHeader") as! WeatherTableHeader
        header.headerDate.text = convertDateString(fcstDate: sections[section])
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
        let times = self.weatherArray!.filter{ $0.date == sections[section] }.count
        print(times)
        return times
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


extension MainViewController: WeatherManagerDelegate {
    func didUpdateWeatherTable(_ weatherManager: WeatherManager, weather: [WeatherModel]) {
        DispatchQueue.main.async {

            self.weatherArray = weather
            self.sections = removeDuplicate(weather.map { $0.date }).sorted { $0 < $1 }
            self.weatherTable?.reloadData()
        }
    }
    func didUpdateNowWeatherData(_ weatherManager: WeatherManager, nowWeatherData: WeatherModel?) {
        DispatchQueue.main.async {
            if let nowWeatherData = nowWeatherData {
                var image: UIImage?

                for item in nowWeatherData.value {
                    switch item.key {
                        case "T1H":
                            self.nowWeather?.lblNowTMP.text = item.value + "º"
                        case "RN1":
                            switch item.value.toDouble {
                                case 0:
                                    self.nowWeather?.lblNowSKY.text = "강수없음"
                                case (0.1 ..< 1.0):
                                    self.nowWeather?.lblNowSKY.text = "1.0mm 미만"
                                case (1.0 ..< 30.0):
                                    self.nowWeather?.lblNowSKY.text = item.value + "mm"
                                case (30.0 ..< 50.0):
                                    self.nowWeather?.lblNowSKY.text = "30.0~50.0mm"
                                case (50.0 ... Double.infinity) :
                                    self.nowWeather?.lblNowSKY.text = "50.0mm 이상"
                                default:
                                    break
                            }
                            if item.value == "0" {
                                self.nowWeather?.lblNowSKY.text = "강수없음"

                            } else {
                                self.nowWeather?.lblNowSKY.text = "강수량 : " + item.value
                            }
                        case "PTY":
                            switch item.value.toInt {
                                case 0:
                                    if (600...2000).contains(nowWeatherData.time.toInt) {
                                        image = UIImage(named: "sunny.png")
                                    } else {
                                        image = UIImage(named: "night.png")
                                    }
                                case 1:
                                    fallthrough
                                case 5:
                                    image = UIImage(named: "rain.png")
                                case 2:
                                    fallthrough
                                case 6:
                                    image = UIImage(named: "rainORsnowy.png")
                                case 3:
                                    fallthrough
                                case 7:
                                    image = UIImage(named: "snow.png")
                                default:
                                    break
                            }
                            self.nowWeather?.imgNowSKY.image = image
                        default:
                            break
                    }
                }
            }
        }
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
