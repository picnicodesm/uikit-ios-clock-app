//
//  MakeAlarmViewController.swift
//  Clock
//
//  Created by 김상민 on 2023/08/18.
//

import UIKit

class MakeAlarmViewController: UIViewController {

    let makeAlarmView = MakeAlarmView()
    var isEditView: Bool = false
    var selectedAlarm: AlarmModel? = nil
    lazy var tableView = makeAlarmView.tableView
    var dataSource: DataSource!
    var delegate: AlarmDelegate?
    
    
    typealias Item = String
    enum Section {
        case main
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .orange
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        self.navigationItem.title = isEditView ? "Edit Alarm" : "Add Alarm"
        tableView.delegate = self
        setLayout()
        configureDataSource()
    }
    
    
    private func setLayout() {
        if isEditView {
            makeAlarmView.setEditLayout()
            makeAlarmView.deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        }
        
        view.addSubview(makeAlarmView)
        
        NSLayoutConstraint.activate([
            makeAlarmView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            makeAlarmView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            makeAlarmView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            makeAlarmView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])
    }
    
    
    private func configureDataSource() {
        dataSource = DataSource(tableView: tableView, cellProvider: { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SetAlarmCell.identifier) as? SetAlarmCell else { return UITableViewCell() }
            cell.setDetail(index: indexPath.item, alarm: self.selectedAlarm)
            if let selectedAlarm = self.selectedAlarm {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "H:mm"
                self.makeAlarmView.timePicker.date = dateFormatter.date(from: selectedAlarm.time)!
            }
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(["Repeat", "Label", "Sound", "Snooze"])
        dataSource.apply(snapshot)
    }
    
    
    private func focusTextField(indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SetAlarmCell else { return }
        cell.textField.becomeFirstResponder()
    }
    
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    
    @objc func saveButtonTapped() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm"
        guard let repeatCell = self.tableView.visibleCells[0] as? SetAlarmCell else { return }
        guard let labelCell = self.tableView.visibleCells[1] as? SetAlarmCell else { return }
        guard let soundCell = self.tableView.visibleCells[2] as? SetAlarmCell else { return }
        guard let snoozeCell = self.tableView.visibleCells[3] as? SetAlarmCell else { return }
        
        let time = dateFormatter.string(from: self.makeAlarmView.timePicker.date)
        let repeatDay = repeatCell.descriptionLabel.text!
        let labelText = labelCell.textField.text! == "" ? "Alarm" : labelCell.textField.text!
        let sound = soundCell.descriptionLabel.text!
        let snooze = snoozeCell.snoozeSwitch.isOn
        
        let alarm = AlarmModel(time: time, repeatDay: repeatDay, labelText: labelText, sound: sound, snooze: snooze)
        if isEditView {
            var tempAlarms: [AlarmModel] = []
            tempAlarms = AlarmModel.alarms.map { currentAlarm in
                if currentAlarm.uuid == selectedAlarm!.uuid {
                    return alarm
                } else {
                    return currentAlarm
                }
            }
            AlarmModel.alarms = tempAlarms
            delegate?.updateDataSource()
        } else {
            delegate?.setAlarm(alarm: alarm)
        }
        self.dismiss(animated: true)
    }

    
    @objc func deleteButtonTapped() {
        AlarmModel.alarms = AlarmModel.alarms.filter { $0 != selectedAlarm }
        delegate?.updateDataSource()
        self.dismiss(animated: true)
    }
}

extension MakeAlarmViewController {
    class DataSource: UITableViewDiffableDataSource<Section, Item> {
    }
}

extension MakeAlarmViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowIndex = indexPath.item
        switch rowIndex {
        case 0:
            self.navigationItem.backButtonTitle = "Back"
            let repeatVC = RepeatViewController()
            repeatVC.delegate = self
            guard let repeatCell = self.tableView.cellForRow(at: indexPath) as? SetAlarmCell else { return }
            repeatVC.initialDay = repeatCell.descriptionLabel.text!
            self.navigationController?.pushViewController(repeatVC, animated: true)
        case 1:
            focusTextField(indexPath: indexPath)
        case 2:
            self.navigationItem.backButtonTitle = "Back"
            let soundVC = SoundViewController()
            soundVC.delegate = self
            guard let soundCell = self.tableView.cellForRow(at: indexPath) as? SetAlarmCell else { return }
            soundVC.selectedSound = soundCell.descriptionLabel.text!
            self.navigationController?.pushViewController(soundVC, animated: true)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension MakeAlarmViewController: AlarmDelegate {
    func setAlarm(dayLabel text: String) {
        guard let cell1 = self.tableView.visibleCells[0] as? SetAlarmCell else { return }
        cell1.descriptionLabel.text = text
    }
    
    
    func setAlarm(sound soundText: String) {
        guard let soundCell = self.tableView.visibleCells[2] as? SetAlarmCell else { return }
        soundCell.descriptionLabel.text = soundText
    }
}
