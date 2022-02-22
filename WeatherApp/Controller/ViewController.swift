//
//  ViewController.swift
//  WeatherApp 주륵주륵
//
//  Created by sumwb on 2022/02/17.
//

import UIKit
/// - 해야 할 것
///     - 지역 변경 기능 추가  - 만들기만 하고 실행은 안해봄
///             -> 혹시 API 신청할 때 받은 엑셀 파일로 할 수 있는게 있나 확인해봐야할듯(격자 데이터를 보고 매칭되는 지역 표기 / 위경도만 받아오면 엑셀 파일로 매칭해서 바꿔주기 등)
///     - lblSKY(하늘상태, 강수형태) -> 이미지뷰로 바꾸기
///     - UI 꾸미기
///     - 백그라운드에서 계속 업데이트 해서 눈/비 알림
class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var lblTMPNow: UILabel!
    @IBOutlet weak var lblTMN: UILabel!
    @IBOutlet weak var lblTMX: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var weatherManager = WeatherManager()
    
    var timeArray: [String] = []
    var valueArray: [ItemValue] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("start APP")
        weatherManager.delegate = self
        tableView.dataSource = self
        
        weatherManager.fetchWeather()
    }
    
//    // 나중에 다른 뷰에 갔다가 다시 돌아오는 상황을 만들게 되면 viewWillAppear에 코딩
//    override func viewWillAppear(_ animated: Bool) {
//        weatherManager.fetchWeather()
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WeatherTableViewCell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherTableViewCell
    
        cell.lblTime.text = self.timeArray[indexPath.row]
        cell.lblTMP.text = self.valueArray[indexPath.row]["TMP"]
        cell.lblSKY.text = self.valueArray[indexPath.row]["SKY"]
        cell.lblPOP.text = self.valueArray[indexPath.row]["POP"]
        cell.lblPCP.text = self.valueArray[indexPath.row]["PCP"]
        
        return cell
    }
}
extension ViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            // TableView에 보여질 데이터
            self.timeArray = weather.timeArray
            self.valueArray = weather.valueArray
            // 일일 최저/최고 기온, 현재 기온 데이터
            self.lblTMPNow.text = weather.nowTMP
            self.lblTMN.text = weather.todayTMPArray[0].1["TMN"] ?? "-"
            self.lblTMX.text = weather.todayTMPArray[0].1["TMX"] ?? "-"
            
            self.tableView.reloadData() // 데이터가 다 들어오면 테이블뷰 reload -> API를 받아오는 것보다 테이블뷰가 로딩되는 속도가 더 빠르기 때문에 이 코드가 없으면 테이블뷰에 표시할 데이터를 받아와서 가공하기 전에 테이블뷰가 먼저 만들어져서 화면에 표시가 안됨
        }
    }
    
    func didFailWithError(error: Error) {
        print(error.localizedDescription)
    }
}
