//
//  AlarmViewController.swift
//  Clock
//
//  Created by 김상민 on 2023/08/15.
//

import UIKit

class AlarmViewController: UIViewController {
    
    var dataSource: DataSource!
    typealias Item = AlarmModel
    enum Section: Int, CaseIterable {
        case sleep
        case other
    }
    
    var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.sectionHeaderTopPadding = 8
        tableView.allowsSelectionDuringEditing = true
        tableView.register(SleepCell.self, forCellReuseIdentifier: SleepCell.identifier)
        tableView.register(AlarmCell.self, forCellReuseIdentifier: AlarmCell.identifier)
        tableView.backgroundColor = .clear
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        configureView()
        setConstraint()
        configureDataSource()
    }

    private func configureDataSource() {
        dataSource = DataSource(tableView: tableView, cellProvider: { tableView, indexPath, item in
            let sectionIndex = Section(rawValue: indexPath.section)
            switch sectionIndex {
            case .sleep:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SleepCell.identifier) as? SleepCell
                else { return UITableViewCell() }
                cell.selectionStyle = .none
                return cell
            case .other:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmCell.identifier) as? AlarmCell else { return UITableViewCell() }
                cell.editingAccessoryType = .disclosureIndicator
                cell.configure(alarm: item)
                cell.delegate = self
                cell.itemId = item.uuid
                cell.timeLabel.textColor = item.snooze ? .label : .darkGray
                cell.descriptionLabel.textColor = item.snooze ? .label : .darkGray
                return cell
            default:
                return UITableViewCell()
            }
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([AlarmModel()], toSection: .sleep)
        snapshot.appendItems(AlarmModel.alarms, toSection: .other)
        dataSource.apply(snapshot)
    }
    
    private func configureView() {
        self.navigationController?.navigationBar.topItem?.title = "Alarm"
        self.navigationController?.navigationBar.tintColor = .orange
        self.navigationItem.leftBarButtonItem = editButtonItem
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    }
    
    private func setConstraint() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    @objc func addButtonTapped() {
        self.setEditing(false, animated: true)
        let makeAlarmVC = MakeAlarmViewController()
        makeAlarmVC.delegate = self
        let navigationController = UINavigationController(rootViewController: makeAlarmVC)
        self.present(navigationController, animated: true)
    }
}

extension AlarmViewController {
    class DataSource: UITableViewDiffableDataSource<Section, Item> {
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            let sectionKind = Section(rawValue: indexPath.section)
            switch sectionKind {
            case .sleep:
                return false
            case .other:
                return true
            default:
                return false
            }
        }
        
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                guard let identifierToDelete = itemIdentifier(for: indexPath) else { return }
                AlarmModel.alarms = AlarmModel.alarms.filter { $0 != identifierToDelete }
                var snapshot = self.snapshot()
                snapshot.deleteItems([identifierToDelete])
                apply(snapshot)
            }
        }
    }
}

extension AlarmViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionKind = Section(rawValue: section)
        switch sectionKind {
        case .sleep:
            let header = SectionHeader()
            return header
        case .other:
            let header = SectionHeader()
            header.configure(imageName: "", title: "Other")
            return header
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionKind = Section(rawValue: indexPath.section)
        switch sectionKind {
        case .sleep:
            return
        case .other:
            self.setEditing(false, animated: true)
            let item = AlarmModel.alarms[indexPath.item]
            let makeAlarmVC = MakeAlarmViewController()
            makeAlarmVC.isEditView = true
            makeAlarmVC.selectedAlarm = item
            makeAlarmVC.delegate = self
            let navigationController = UINavigationController(rootViewController: makeAlarmVC)
            self.present(navigationController, animated: true)
        default: return
        }
    }
}

extension AlarmViewController: AlarmDelegate {
    func setAlarm(alarm alarmModel: AlarmModel) {
        AlarmModel.alarms.append(alarmModel)
        updateDataSource()
    }
    
    func updateDataSource() {
        guard let dataSource = self.dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.deleteSections([.other])
        snapshot.appendSections([.other])
        snapshot.appendItems(AlarmModel.alarms, toSection: .other)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func updateSwitchData(isOn: Bool, id itemId: UUID) {
        var tempAlarms: [AlarmModel] = []
        
        tempAlarms = AlarmModel.alarms.map { currentAlarm in
            var tempAlarm = currentAlarm
            if currentAlarm.uuid == itemId {
                tempAlarm.snooze = isOn
                return tempAlarm
            } else {
                return currentAlarm
            }
        }
        
        AlarmModel.alarms = tempAlarms
        updateDataSource()
    }
}
