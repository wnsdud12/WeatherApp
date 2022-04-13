//
//  EupmyeondongViewController.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/04/12.
//

import UIKit

class EupmyeondongViewController: UIViewController {

    var selectedGugun: String?
    var gugunArray: [WeatherLocale]?

    @IBOutlet weak var eupmyeondongTable: UITableView!
    var eupmyeondongArray = [WeatherLocale]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        eupmyeondongTable.delegate = self
        eupmyeondongTable.dataSource = self


    }
    override func viewWillAppear(_ animated: Bool) {
        eupmyeondongArray = gugunArray!.filter({ (locale: WeatherLocale) -> Bool in
            return locale.gugun.contains(selectedGugun!)
        })
    }
}
extension EupmyeondongViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eupmyeondongArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eupmyeondongCell", for: indexPath)
        let locale = eupmyeondongArray[indexPath.row]
        cell.textLabel?.text = locale.eupmyeondong
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locale: WeatherLocale
        locale = eupmyeondongArray[indexPath.row]
//        lamcproj(lat: locale.point.x, lon: locale.point.y, isWantGrid: false)
        lamcproj(lon_x: locale.point.x, lat_y: locale.point.y, isWantGrid: false)
        UserDefaults.grid_x = locale.point.x
        UserDefaults.grid_y = locale.point.y
        UserDefaults.address = locale.address

        let nextVC = self.storyboard?.instantiateViewController(identifier: "mainView") as! MainViewController
        UserDefaults.printAll()
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true)
    }
}
