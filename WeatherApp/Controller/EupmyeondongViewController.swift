//
//  EupmyeondongViewController.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/04/12.
//

import UIKit

class EupmyeondongViewController: UIViewController {

    var selectGugun: String?
    @IBOutlet weak var eupmyeondongTable: UITableView!
    var eupmyeondongArray = [WeatherLocale]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        eupmyeondongTable.delegate = self
        eupmyeondongTable.dataSource = self
    }
}
extension EupmyeondongViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eupmyeondongCell", for: indexPath)
        cell.textLabel?.text = "1"
        return cell
    }


}
