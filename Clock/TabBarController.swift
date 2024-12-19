//
//  TabBarController.swift
//  Clock
//
//  Created by 김상민 on 2023/08/20.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let vc = self.viewControllers else { return }
        
        guard let stopWatchVC = vc[2] as? StopWatchViewController else { return }
        stopWatchVC.tabBarItem.image = UIImage(systemName: "stopwatch")
        stopWatchVC.tabBarItem.title = "StopWatch"
       
        let appearance = UITabBar.appearance()

        appearance.backgroundImage = UIImage().withTintColor(.black, renderingMode: .alwaysOriginal)
        appearance.shadowImage = UIImage().withTintColor(.black)
        appearance.clipsToBounds = true
        
        guard let timerVC = vc[3] as? TimerViewController else { return }
        timerVC.tabBarItem.image = UIImage(systemName: "timer")
        timerVC.tabBarItem.title = "Timer"
    }
    

   

}
