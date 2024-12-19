//
//  SetAlarmCell.swift
//  Clock
//
//  Created by 김상민 on 2023/08/18.
//

import UIKit

class SetAlarmCell: UITableViewCell {
    static let identifier = "SetAlarmCell"
    
    var label: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var descriptionLabel: UILabel = {
        var descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    }()
    
    var textField: UITextField = {
        var textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .right
        textField.clearButtonMode = .whileEditing
        textField.tintColor = .orange
        textField.placeholder = "Alarm"
        return textField
    }()
    
    var snoozeSwitch: UISwitch = {
        var snoozeSwitch = UISwitch()
        snoozeSwitch.translatesAutoresizingMaskIntoConstraints = false
        return snoozeSwitch
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        contentView.addSubview(label)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(textField)
        contentView.addSubview(snoozeSwitch)
        
        label.setContentHuggingPriority(.required, for: .horizontal) // 텍스트 크기에 따라 콘텐츠 크기를 유지하기 위해
        label.setContentCompressionResistancePriority(.required, for: .horizontal) // 텍스트 크기에 따라 콘텐츠 압축을 우선시하지 않도록 설정
        
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            descriptionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 25),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            snoozeSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            snoozeSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    func setDetail(index: Int, alarm: AlarmModel?) {
        var text: String? = nil
        
        if let labelText = alarm?.labelText {
            text = labelText
        }
        
        switch index {
        case 0:
            self.textField.isHidden = true
            self.snoozeSwitch.isHidden = true
            self.label.text = "Repeat"
            self.descriptionLabel.text = alarm?.repeatDay ?? "Never"
            self.accessoryType = .disclosureIndicator
        case 1:
            self.descriptionLabel.isHidden = true
            self.snoozeSwitch.isHidden = true
            self.label.text = "Label"
            self.textField.text = text == "Alarm" ? "" : text ?? ""
        case 2:
            self.textField.isHidden = true
            self.snoozeSwitch.isHidden = true
            self.label.text = "Sound"
            self.descriptionLabel.text = alarm?.sound ?? "Radar"
            self.accessoryType = .disclosureIndicator
        case 3:
            self.descriptionLabel.isHidden = true
            self.textField.isHidden = true
            self.label.text = "Snooze"
            self.snoozeSwitch.isOn = alarm?.snooze ?? true
            self.selectionStyle = .none
        default:
            return
        }
    }
}
