//
//  LapModel.swift
//  Clock
//
//  Created by 김상민 on 2023/08/27.
//

import Foundation
import UIKit

struct TimeItem: Hashable {
    let id: Int
    var timeText: String
    var state = State.normal
    var color: UIColor {
        get {
            switch state {
            case .normal:
                return .white
            case .min:
                return .green
            case .max:
                return .red
            }
        }
    }
    
    enum State {
        case normal
        case min
        case max
    }
}
