//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by 박준영 on 2022/04/04.
//

import UIKit

class SearchViewController: UIViewController {
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
        navigationItem.searchController = searchController
        definesPresentationContext = true

    }
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    func filterContentForSearchText(_ searchText: String) {
        filteredLocales = locales.filter({ (locale: WeatherLocale) in
            return locale.sido.rawValue.contains(searchText)
        })
        tableView.reloadData()
    }

}
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locales.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "localeCell", for: indexPath)
        cell.textLabel?.text = locales[indexPath.row].sido.rawValue
        return cell
    }


}
extension SearchViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
