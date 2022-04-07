//
//  GunguViewController.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/04/05.
//

import UIKit

class GunguViewController: UIViewController {

    @IBOutlet weak var gunguTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        gunguTable.delegate = self
        gunguTable.dataSource = self

    }
    
}
extension GunguViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gunguCell", for: indexPath)
        cell.textLabel?.text = "test"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let MainVC = MainViewController()
//        present(MainVC, animated: true)

    }
}
