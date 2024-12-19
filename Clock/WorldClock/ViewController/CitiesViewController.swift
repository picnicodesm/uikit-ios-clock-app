//
//  CitiesViewController.swift
//  Clock
//
//  Created by 김상민 on 2023/08/14.
//

import UIKit

class CitiesViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    var delegate: WorldClockDelegate?
    var cities = Cities.cities
    var dataSource: DataSource!
    var searchingDataSource: UITableViewDiffableDataSource<SearchingResult, Item>!
    
    typealias Item = String
    enum Section: Int, CaseIterable {
        case A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z
    }
    enum SearchingResult {
        case searching
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.prompt = "Choose a city"
        self.navigationController?.navigationBar.tintColor = .orange
        self.tableview.sectionIndexColor = .orange
        configureDataSource()
        embedSearchBar()
        tableview.delegate = self
    }
    
    private func configureDataSource() {
        dataSource = DataSource (tableView: tableview, cellProvider: { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell") as? CityCell else { return UITableViewCell() }
            cell.configure(item)
            return cell
        })
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        for section in Section.allCases {
            snapshot.appendItems(Cities.citiesByType[section.rawValue], toSection: section)
        }
        dataSource.apply(snapshot)
    }
    
    private func embedSearchBar() {
        let searchBar = UISearchBar()
        self.navigationItem.titleView = searchBar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        searchBar.delegate = self
    }
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true)
    }

    private func getDateComponents(at city: String) -> [DateComponents] {
        var targetCalendar = Calendar.current
        targetCalendar.timeZone = TimeZone(identifier: city.replacingOccurrences(of: ", ", with: "/"))!
        let targetDateComponent = targetCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        
        let currentCalendar = Calendar.current
        let currentDateComponent = currentCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        // 여기서의 Date()는 따로 찍으면 dateFormatter에 의해 해당 나라의 시간이 나오지만 calendar가 current라 현재 Date()로 찍히는 듯 하다.
        
        let compareComponent = currentCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDateComponent, to: targetDateComponent)
        
        let dateComponents = [targetDateComponent, currentDateComponent, compareComponent]
        return dateComponents
    }
    
    private func getDateDiff(from currentDateComponent: DateComponents, target targetDateComponent: DateComponents) -> String {
        var dateDiff = ""
        if currentDateComponent.year! == targetDateComponent.year! {
            if currentDateComponent.month! == targetDateComponent.month! {
                if currentDateComponent.day! == targetDateComponent.day! {
                    dateDiff = "Today"
                } else {
                    // 일이 다를 때
                    dateDiff = currentDateComponent.day! > targetDateComponent.day! ? "Yesterday" : "Tomorrow"
                }
            } else {
                // 월이 다를 때
                dateDiff = currentDateComponent.month! > targetDateComponent.month! ? "Yesterday" : "Tomorrow"
            }
        } else {
            // 연도가 다를 때
            dateDiff = currentDateComponent.year! > targetDateComponent.year! ? "Yesterday" : "Tomorrow"
        }
        return dateDiff
    }
    
    private func getTimeDiff(dateComponent compareComponent: DateComponents) -> String {
        var timeDiff = ""
        let min = abs(compareComponent.minute!)
        let hour = compareComponent.hour!
        if hour == 0 && min == 0 {
            timeDiff = "+0HRS"
        } else {
            if hour == 0 {
                timeDiff = String(min) + "MINS"
                if min > 0 { timeDiff = "+" + timeDiff }
            } else if hour == 1 || hour == -1 {
                if min != 0 { timeDiff = String(hour) + ":" + String(min) }
                else { timeDiff = String(hour) + "HR" }
                if hour == 1 { timeDiff = "+" + timeDiff }
            } else {
                // hour > 1 hour < -1
                if min != 0 { timeDiff = String(hour) + ":" + String(min) }
                else { timeDiff = String(hour) + "HRS" }
                if hour > 1 { timeDiff = "+" + timeDiff}
            }
        }
        return timeDiff
    }
}

extension CitiesViewController {
    class DataSource: UITableViewDiffableDataSource<Section, Item> {
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return String(UnicodeScalar(section + 65)!)
        }
        
        override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
            let indexString = (0..<26).map { String(UnicodeScalar($0 + 65)!) }
            return indexString
        }
    }
}

extension CitiesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            cities = Cities.cities
            configureDataSource()
            return
        } else {
            cities = Cities.cities.filter{ $0.contains(searchText) }
            searchingDataSource = UITableViewDiffableDataSource<SearchingResult, Item>(tableView: tableview, cellProvider: { tableView, indexPath, item in
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell") as? CityCell else { return UITableViewCell() }
                    cell.configure(item)
                    return cell
            })
            
            var snapshot = NSDiffableDataSourceSnapshot<SearchingResult, Item>()
            snapshot.appendSections([.searching])
            snapshot.appendItems(cities, toSection: .searching)
            
            searchingDataSource.apply(snapshot, animatingDifferences: false)
        }
    }
}

extension CitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = cities[indexPath.item]
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.timeZone = TimeZone(identifier: city.replacingOccurrences(of: ", ", with: "/"))
        dateFormatter.dateFormat = "H:mm"
        
        let dateComponents = getDateComponents(at: city)
        let targetDateComponent = dateComponents[0]
        let currentDateComponent = dateComponents[1]
        let compareComponent = dateComponents[2]
        
        let cityName = String(city.split(separator: ", ").last!)
        let time = String(dateFormatter.string(from: Date()))
        let dateDiff = getDateDiff(from: currentDateComponent, target: targetDateComponent)
        let timeDiff = getTimeDiff(dateComponent: compareComponent)
        
        let clock = WorldClock(dateDiff: dateDiff, timeDiff: timeDiff, cityName: cityName, time: time)
        
        self.delegate?.worldClock(dataReceived: clock)
        self.dismiss(animated: true)
    }
}

protocol WorldClockDelegate {
    func worldClock(dataReceived data: WorldClock)
}
