//
//  GugunViewController.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/04/05.
//

import UIKit

class GugunViewController: UIViewController {
    @IBOutlet weak var gugunTable: UITableView!
    var selectedSido: String?
    var gugunArray = [WeatherLocale]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        gugunTable.delegate = self
        gugunTable.dataSource = self

    }
    override func viewWillAppear(_ animated: Bool) {
        gugunArray = WeatherLocales.locales.filter({ (locale: WeatherLocale) -> Bool in
            return locale.sido.contains(selectedSido!)
        })
    }
    
}
extension GugunViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gugunArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gunguCell", for: indexPath)
        let locale = gugunArray[indexPath.row]
        cell.textLabel?.text = locale.address
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gugun: String
        gugun = gugunArray[indexPath.row].gugun
        print(gugun)
        let nextVC = self.storyboard?.instantiateViewController(identifier: "eupmyeondongView") as! EupmyeondongViewController
        nextVC.selectGugun = gugun
        self.present(nextVC, animated: true)
    }
}

