//
//  WorldClockCell.swift
//  Clock
//
//  Created by 김상민 on 2023/08/14.
//

import UIKit

class WorldClockCell: UITableViewCell {

    @IBOutlet weak var diffLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(_ item: WorldClock) {
        self.diffLabel.text = item.dateDiff + ", " + item.timeDiff
        self.cityLabel.text = item.cityName
        self.timeLabel.text = item.time
    }
}
