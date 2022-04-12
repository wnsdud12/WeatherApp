//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/04/04.
//

import UIKit

class SidoViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    let searchController = UISearchController(searchResultsController: nil)

    var locales = WeatherLocales.locales
    var filteredLocales = [WeatherLocale]()

    var sortedSidoArray = removeDuplicate(WeatherLocales.locales.map{$0.sido}).sorted{$0 < $1}
    override func viewDidLoad() {
        print("start sido-viewDidLoad")
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self

        // Setup the Search Controller
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "지역 검색"
        //navigationItem.searchController = searchController
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = false

    }
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    func filterContentForSearchText(_ searchText: String) {
        filteredLocales = locales.filter({ (locale: WeatherLocale) -> Bool in
            return locale.address.contains(searchText)
        })
        tableView.reloadData()
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

}
extension SidoViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredLocales.count
        }
        return sortedSidoArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "localeCell", for: indexPath)
        if isFiltering() {
            let locale: WeatherLocale
            locale = filteredLocales[indexPath.row]
            cell.textLabel?.text = locale.address
        } else {
            let sido: String
            sido = sortedSidoArray[indexPath.row]
            cell.textLabel?.text = sido
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("sido - tableView.didSelectRowAt")
        if isFiltering() { // 검색으로 지역을 찾았을 때, 셀을 선택하면 위치의 위경도 반환 후 메인으로
            let locale: WeatherLocale
            locale = filteredLocales[indexPath.row]
            UserDefaults.grid_x = locale.point.x
            UserDefaults.grid_y = locale.point.y
            UserDefaults.address = locale.address

            print(locale)
            let nextVC = self.storyboard?.instantiateViewController(identifier: "mainView") as! MainViewController
            UserDefaults.printAll()
            dismiss(animated: true)
            nextVC.modalPresentationStyle = .fullScreen
            self.present(nextVC, animated: true)
        } else { // 검색 없이 셀을 선택 했을 시, 선택한 시/도의 구/군 테이블
            let sido: String
            sido = sortedSidoArray[indexPath.row]
            print(sido)
            let nextVC = self.storyboard?.instantiateViewController(identifier: "gugunView") as! GugunViewController
            nextVC.selectedSido = sido
            self.present(nextVC, animated: true)
        }
    }
}
extension SidoViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    // MARK: - UISeearchBar Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
