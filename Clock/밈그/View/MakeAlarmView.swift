//
//  MakeAlarmView.swift
//  Clock
//
//  Created by 김상민 on 2023/08/18.
//

import Foundation
import UIKit

class MakeAlarmView: UIView {
    var timePicker: UIDatePicker = {
       var timePicker = UIDatePicker()
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.datePickerMode = .time
        timePicker.locale = Locale(identifier: "en_GB") // 오전 오후 안나오게
        timePicker.tintColor = .orange
        return timePicker
    }()
    
    var tableView: UITableView = {
        var tableView = UITableView(frame: CGRect(), style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SetAlarmCell.self, forCellReuseIdentifier: SetAlarmCell.identifier)
        tableView.alwaysBounceVertical = false
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    var deleteButton: UIButton = {
        var deleteButton = UIButton()
        var buttonConfig = UIButton.Configuration.bordered()
        buttonConfig.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        buttonConfig.baseBackgroundColor = .secondarySystemGroupedBackground
        deleteButton.configuration = buttonConfig
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle("Delete Alarm", for: .normal)
        deleteButton.tintColor = .red
        return deleteButton
    }()
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("error")
    }
    
    private func setLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .systemGroupedBackground

        self.addSubview(timePicker)
        self.addSubview(tableView)
        
        
        NSLayoutConstraint.activate([
            timePicker.topAnchor.constraint(equalTo: self.topAnchor, constant: 60),
            timePicker.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            timePicker.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 0),
            tableView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            tableView.heightAnchor.constraint(equalToConstant: 220),
        ])
    }
    
    func setEditLayout() {
        self.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            deleteButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
        ])
    }
}
