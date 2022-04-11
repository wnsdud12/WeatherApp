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

    var sidoArr = removeDuplicate(WeatherLocales.locales.map{$0.sido}).sorted{$0 < $1}
    override func viewDidLoad() {
        super.viewDidLoad()
        print(sidoArr)
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
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

    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

}
extension SidoViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sidoArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "localeCell", for: indexPath)

        cell.textLabel?.text = sidoArr[indexPath.row]
        return cell
    }
}
extension SidoViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    // MARK: - UISeearchBar Delegate
    func updateSearchResults(for searchController: UISearchController) {

    }
}
