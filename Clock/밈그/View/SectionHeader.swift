//
//  SectionHeader.swift
//  Clock
//
//  Created by 김상민 on 2023/08/17.
//

import Foundation
import UIKit

class SectionHeader: UITableViewHeaderFooterView {
    var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(systemName: "bed.double.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .label
        return imageView
    }()
    
    var sectionTitleLabel: UILabel = {
        var sectionTitleLabel = UILabel()
        sectionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionTitleLabel.text = "Sleep | Wake UP"
        sectionTitleLabel.font = .boldSystemFont(ofSize: 18)
        return sectionTitleLabel
    }()
    
    override init(reuseIdentifier: String?) {
        super .init(reuseIdentifier: reuseIdentifier)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        self.addSubview(imageView)
        self.addSubview(sectionTitleLabel)
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 28),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
            sectionTitleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    func configure(imageName: String, title: String) {
        self.imageView.image = UIImage(systemName: "")
        self.sectionTitleLabel.text = title
    }
}
