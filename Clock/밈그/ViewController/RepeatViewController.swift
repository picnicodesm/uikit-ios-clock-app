//
//  RepeatViewController.swift
//  Clock
//
//  Created by 김상민 on 2023/08/18.
//

import UIKit

class RepeatViewController: UIViewController {
    
    var dataSource: DataSource!
    typealias Item = String
    enum Section {
        case main
    }
    var delegate: AlarmDelegate?
    
    var initialDay: String = "Never"
    let shortDays: [String] = [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    var isDaySelected: [Bool] = [false, false, false, false, false, false, false]
    var days: [String] = [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"].map { return "Every " + $0 }

    var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DayCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Repeat"
        tableView.delegate = self
        setTableView()
        setSelectedDay()
        configureDataSource()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        makeDayLabel()
    }
    
    private func setSelectedDay() {
        switch initialDay {
        case "Never":
            isDaySelected = isDaySelected.map { _ in return false }
        case "Every Day":
            isDaySelected = isDaySelected.map { _ in return true }
        default:
            let selectedDayArr: [String] = initialDay.components(separatedBy: " ")
            print(selectedDayArr)
            for (index, day) in shortDays.enumerated() {
                if selectedDayArr.contains(day) {
                    isDaySelected[index] = true
                }
            }
        }
    }
    
    private func setTableView() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func configureDataSource() {
        dataSource = DataSource(tableView: tableView, cellProvider: { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell") else { return UITableViewCell() }
            var config = cell.defaultContentConfiguration()
            config.text = item
            cell.tintColor = .orange
            cell.contentConfiguration = config
            if self.isDaySelected[indexPath.item] {
                cell.accessoryType = .checkmark
            }
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(days, toSection: .main)
        dataSource.apply(snapshot)
    }
    
    private func makeDayLabel() {
        var selectedDayArray: [String] = []
        for (index, day) in shortDays.enumerated() {
            if isDaySelected[index] {
                selectedDayArray.append(day)
            }
        }
        var text = selectedDayArray.joined(separator: " ")
        switch text {
        case "Sun Mon Tue Wed Thu Fri Sat":
            text = "Every Day"
        case "":
            text = "Never"
        default:
            break
        }
        print(text)
        self.delegate?.setAlarm(dayLabel: text)
    }

}

extension RepeatViewController {
    class DataSource: UITableViewDiffableDataSource<Section, Item> { }
}

extension RepeatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.visibleCells[indexPath.item]
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            isDaySelected[indexPath.item] = false
        } else {
            cell.accessoryType = .checkmark
            isDaySelected[indexPath.item] = true
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
