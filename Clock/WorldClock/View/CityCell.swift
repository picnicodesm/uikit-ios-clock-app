//
//  CityCell.swift
//  Clock
//
//  Created by 김상민 on 2023/08/14.
//

import UIKit

class CityCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(_ name: String) {
        self.nameLabel.text = name
    }
}
