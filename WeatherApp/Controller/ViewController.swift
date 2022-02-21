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
class ViewController: UIViewController, UITableViewDataSource {
    let group = DispatchGroup()
    
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
        //weatherManager.fetchWeather()
        print(self.timeArray[indexPath.row])
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
            print(weather.timeArray[0])
            
            self.timeArray = weather.timeArray
            self.valueArray = weather.valueArray
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(error: Error) {
        print(error.localizedDescription)
    }
}
