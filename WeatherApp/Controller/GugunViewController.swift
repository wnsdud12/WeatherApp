//
//  GugunViewController.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/04/05.
//

import UIKit

class GugunViewController: UIViewController {
    @IBOutlet weak var gunguTable: UITableView!
    var selectedSido: String?
    var filteredLocales = [WeatherLocale]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        gunguTable.delegate = self
        gunguTable.dataSource = self

    }
    override func viewWillAppear(_ animated: Bool) {
        filteredLocales = WeatherLocales.locales.filter({ (locale: WeatherLocale) -> Bool in
            return locale.sido.contains(selectedSido!)
        })
    }
    
}
extension GugunViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLocales.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gunguCell", for: indexPath)
        let locale = filteredLocales[indexPath.row]
        cell.textLabel?.text = locale.address
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let MainVC = MainViewController()
//        present(MainVC, animated: true)

    }
}

