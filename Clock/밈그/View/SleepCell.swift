//
//  SleepCell.swift
//  Clock
//
//  Created by 김상민 on 2023/08/15.
//

import UIKit

class SleepCell: UITableViewCell {
    static let identifier = "SleepCell"
    
    var sleepLabel: UILabel = {
        var sleepLabel = UILabel()
        sleepLabel.translatesAutoresizingMaskIntoConstraints = false
        sleepLabel.text = "No Alarm"
        sleepLabel.font = UIFont.systemFont(ofSize: 40)
        return sleepLabel
    }()
    
    var changeButton: UIButton = {
        var changeButton = UIButton()
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        changeButton.configuration = buttonConfig
        changeButton.translatesAutoresizingMaskIntoConstraints = false
        changeButton.setTitle("CHANGE", for: .normal)
        changeButton.backgroundColor = .secondarySystemBackground
        changeButton.setTitleColor(.orange, for: .normal)
        changeButton.layer.cornerRadius = 15
        return changeButton
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        contentView.addSubview(sleepLabel)
        contentView.addSubview(changeButton)
        
        NSLayoutConstraint.activate([
            sleepLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sleepLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            sleepLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            changeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            changeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

}

