//
//  ViewController.swift
//  WeatherApp 주륵주륵
//
//  Created by sumwb on 2022/02/17.
//

import UIKit
/// - 해야 할 것
///     - 지역 변경 기능 추가
///     - 받아온 데이터 화면에 출력
class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var weatherManager = WeatherManager()
    
    var timeArray: [String] = []
    var valueArray: [ItemValue] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("start APP")
        weatherManager.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        weatherManager.fetchWeather()
        
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as! WeatherCell
        
        cell.lblTime.text = timeArray[indexPath.row]
        cell.lblPOP.text = valueArray[indexPath.row]["POP"]
        cell.lblTMP.text = valueArray[indexPath.row]["TMP"]
        cell.lblPCPSNO.text = valueArray[indexPath.row]["PCP"]
        
        return cell
    }
    
    
}
extension ViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.sync {
            self.timeArray = weather.timeArray
            self.valueArray = weather.valueArray
        }
    }

    func didFailWithError(error: Error) {
       print(error.localizedDescription)
    }


}
