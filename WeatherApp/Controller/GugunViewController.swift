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
    var sortedGugunArray: [String] = []
    
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
        sortedGugunArray = removeDuplicate(gugunArray.map{$0.gugun}).sorted{$0 < $1}

    }
    
}
extension GugunViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedGugunArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gunguCell", for: indexPath)
        cell.textLabel?.text = sortedGugunArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gugun: String
        gugun = sortedGugunArray[indexPath.row]
        
        let nextVC = self.storyboard?.instantiateViewController(identifier: "eupmyeondongView") as! EupmyeondongViewController
        nextVC.selectedGugun = gugun
        nextVC.gugunArray = gugunArray
        self.present(nextVC, animated: true)
    }
}

