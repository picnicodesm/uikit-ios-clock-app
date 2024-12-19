//
//  AlarmCell.swift
//  Clock
//
//  Created by 김상민 on 2023/08/17.
//

import UIKit

class AlarmCell: UITableViewCell {
    static let identifier = "AlarmCell"
    var delegate: AlarmDelegate?
    var itemId: UUID? = nil
    
    var timeLabel: UILabel = {
        var timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = "6:00"
        timeLabel.font = UIFont.systemFont(ofSize: 60)
        return timeLabel
    }()
    
    var descriptionLabel: UILabel = {
        var descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Alarm"
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        return descriptionLabel
    }()
    
    var alarmSwitch: UISwitch = {
        var alarmSwitch = UISwitch()
        alarmSwitch.translatesAutoresizingMaskIntoConstraints = false
        alarmSwitch.addTarget(self, action: #selector(switchToggle), for: .valueChanged)
        return alarmSwitch
    }()
    
    lazy var vStack: UIStackView = {
        var vStack = UIStackView(arrangedSubviews: [timeLabel, descriptionLabel])
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        vStack.alignment = .leading
        return vStack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        contentView.addSubview(vStack)
        contentView.addSubview(alarmSwitch)
        
        NSLayoutConstraint.activate([
            vStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            vStack.trailingAnchor.constraint(equalTo: alarmSwitch.leadingAnchor, constant: -10),
            alarmSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            alarmSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.alarmSwitch.isHidden = editing
    }
    
    func configure(alarm: AlarmModel) {
        timeLabel.text = alarm.time
        let descriptionText: String = {
            if alarm.repeatDay == "Never" { return alarm.labelText }
            else {
                return alarm.labelText + ", " + alarm.repeatDay
            }
        }()
        descriptionLabel.text = descriptionText
        alarmSwitch.isOn = alarm.snooze
    }
    
    @objc func switchToggle(_ sender: UISwitch ) {
        delegate?.updateSwitchData(isOn: sender.isOn, id: itemId!)
    }
}
