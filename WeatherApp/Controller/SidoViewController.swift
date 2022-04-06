//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/04/04.
//

import UIKit

class SidoViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var locales = [WeatherLocale]()
    var filteredLocales = [WeatherLocale]()
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        searchController.delegate = self
        locales = weatherLocaleInit()
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
        filteredLocales = locales.filter({ (locale: WeatherLocale) in
            return (locale.sido.rawValue.contains(searchText)) || (locale.gungu.keys.description.contains(searchText))
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
        return locales.count
    }

    // 1. 검색 창에 시/도 표시 ex) 인천, 서울, 경기
    // 2. 선택기능 사용 시 검색 필요 없음
    // 2-1. 시/도 선택하면 군/구 표시 ex-인천 선택) 남동구, 연수구, 부평구
    // 2-2. 군/구 선택하면 그 지역 날씨 검색
    // 3-1. 검색하면 지역 전체 이름 표시 ex-인 검색) 인천시 남동구, 강원도 인제군, 경기도 용인시
    // 3-2. 표시된 지역 이름 선택하면 날씨 검색
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "localeCell", for: indexPath)
        let locale: WeatherLocale
        if isFiltering() {
            locale = filteredLocales[indexPath.row]
        } else {
            // 여기서 선택하면 군/구 테이블 표시 및 검색기능 끄기
            locale = locales[indexPath.row]
        }
        cell.textLabel?.text = locale.sido.rawValue
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locale = locales[indexPath.row]
        UserDefaults.standard.set(locale.gungu.first?.value.x, forKey: "x")
        UserDefaults.standard.set(locale.gungu.first?.value.y, forKey: "y")
        UserDefaults.standard.set(locale.sido.rawValue, forKey: "address")
        guard let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "mainView") else { return }
        mainVC.modalPresentationStyle = .fullScreen
        present(mainVC, animated: true)
    }
}
extension SidoViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    // MARK: - UISeearchBar Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        print(filteredLocales)
    }
}
