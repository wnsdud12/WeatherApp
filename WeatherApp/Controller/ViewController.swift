//
//  ViewController.swift
//  WeatherApp 주륵주륵
//
//  Created by sumwb on 2022/02/17.
//

import UIKit
/// - 해야 할 것
///     - 지역 변경 기능 추가
///     - lblSKY(하늘상태, 강수형태) -> 이미지뷰로 바꾸기
///     - 최저, 최고기온 표시
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
            self.timeArray = weather.timeArray
            self.valueArray = weather.valueArray
            
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(error: Error) {
        print(error.localizedDescription)
    }
}
