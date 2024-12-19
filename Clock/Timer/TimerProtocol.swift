//
//  TimerProtocol.swift
//  Clock
//
//  Created by 김상민 on 2023/08/28.
//

import Foundation

protocol TimerDelegate {
    func timer(ring: String)
    func finishTimer()
}
