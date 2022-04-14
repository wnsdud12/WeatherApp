//
//  ViewController.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/03/16.
//

import UIKit
import CoreLocation

// test
/// - Todo
///   - 지역 변경 기능 추가
///   - AutoLayout
///
class MainViewController: UIViewController {

    @IBOutlet weak var lblAddress: UILabel?
    @IBOutlet weak var nowWeather: NowWeatherView?
    @IBOutlet weak var weatherTable: UITableView?

    //let appDelegate = UIApplication.shared.delegate as? AppDelegate

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

    var headerData: [WeatherValue] = []

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
//        if UserDefaults.isFirst != nil {
//            self.weatherManager.fetchWeather(nx: UserDefaults.grid_x, ny: UserDefaults.grid_y)
//        }
//        NotificationCenter.default.addObserver(self, selector: #selector(fetch), name: .end_didUpdateLocations, object: nil)
        self.weatherManager.fetchWeather(nx: UserDefaults.grid_x, ny: UserDefaults.grid_y)

    }
    @objc func fetch() {
        self.weatherManager.fetchWeather(nx: UserDefaults.grid_x, ny: UserDefaults.grid_y)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    @IBAction func btnTest(_ sender: Any) {
//        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "sidoView") else { return }
//        nextVC.modalPresentationStyle = .fullScreen
//        self.present(nextVC, animated: true)
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
        header.headerTMX.text = headerData[section]["TMX"] ?? "-"
        header.headerTMN.text = headerData[section]["TMN"] ?? "-"
        return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    // section별 데이터 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTime[section].count
    }
    // section 갯수
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
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


extension MainViewController: WeatherManagerDelegate {
    func didUpdateWeatherTable(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.nowWeatherData = weather.nowWeatherData

            self.sections = weather.sections
            self.cellTime = weather.cellTime
            self.cellTMP = weather.cellTMP
            self.cellSKYPTY = weather.cellSKYPTY
            self.cellPOP = weather.cellPOP
            self.cellPCP = weather.cellPCP

            let nowSKY = setWeatherIcon(time: convertTimeString(fcstTime: weather.nowWeatherData.time), state: weather.nowWeatherData.value)
            self.nowWeather?.lblNowTMP.text = self.nowWeatherData?.value["TMP"]
            self.nowWeather?.imgNowSKY.image = nowSKY.image
            self.nowWeather?.lblNowSKY.text = nowSKY.label
            self.headerData = weather.headerTMXTMN

            self.lblAddress?.text = UserDefaults.address
            
            self.weatherTable?.reloadData()
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
