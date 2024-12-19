//
//  StopWatchViewController.swift
//  Clock
//
//  Created by 김상민 on 2023/08/20.
//

import UIKit


class StopWatchViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var startTime: Date = Date()
    var lapTime: Date = Date()
    var currentInterval: TimeInterval = 0.0
    var pauseTimeInterval: TimeInterval = 0.0
    var currentLapTimeInterval: TimeInterval = 0.0
    var pauseLapTimeInterval: TimeInterval = 0.0
    var timer: Timer!
    var lapTimer: Timer!
    var timeText = ""
    var lapTimeText = ""
    var status = Status.stop
    var laps: [TimeItem] = []
    let timeInterval = 0.03
    
    enum Status {
        case run
        case puase
        case stop
    }
    
    //MARK: - dataSource
    var dataSource: DataSource!
    typealias Item = AnyHashable
    enum Section: Int {
        case lapTime
        case recordTime
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        configureDataSource()
    }
    
    private func setLayout() {
        drawCircle()
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 83, weight: .regular)
        rightButton.layer.cornerRadius = 45.0
        leftButton.layer.cornerRadius = 45.0
        rightButton.setTitle("Start", for: .normal)
        leftButton.setTitle("Lap", for: .normal)
        rightButton.setTitleColor(.green, for: .normal)
        rightButton.tintColor = .green.withAlphaComponent(0.2)
        leftButton.tintColor = .gray.withAlphaComponent(0.2)
        leftButton.isEnabled = false
    }
    
    private func configureDataSource() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LapCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecordCell")
        
        dataSource = DataSource(tableView: tableView, cellProvider: { tableView, indexPath, item in
            let sectionKind = Section(rawValue: indexPath.section)
            
            switch sectionKind {
            case .lapTime:
                let cell = self.configureLapCell()
                return cell
            case .recordTime:
                let cell = self.configureRecordCell(item: item)
                return cell
            default: return UITableViewCell()
            }
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.lapTime, .recordTime])
        snapshot.appendItems([], toSection: .lapTime)
        snapshot.appendItems([], toSection: .recordTime)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func configureLapCell() -> UITableViewCell {
        let cell =  UITableViewCell(style: .value1, reuseIdentifier: "LapCell")
        cell.clipsToBounds = true
        var config = cell.defaultContentConfiguration()
        config.text = "Lap " + "\(String(self.laps.count + 1))"
        config.secondaryText = "\(self.lapTimeText)"
        config.secondaryTextProperties.color = .white
        config.secondaryTextProperties.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .light)
        
        cell.contentConfiguration = config
        return cell
    }
    
    private func configureRecordCell(item: AnyHashable) -> UITableViewCell {
        guard let timeItem = item as? TimeItem else { return UITableViewCell() }
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "RecordCell")
        cell.clipsToBounds = true
        var config = cell.defaultContentConfiguration()
        config.text = "Lap " + "\(timeItem.id)"
        config.textProperties.color = timeItem.color
        config.secondaryText = "\(timeItem.timeText)"
        config.secondaryTextProperties.color = timeItem.color
        config.secondaryTextProperties.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .light)
        
        cell.contentConfiguration = config
        return cell
    }
    
    private func setMaxMinLaps() {
        let temp = laps.map { return TimeItem(id: $0.id, timeText: $0.timeText, state: .normal)}
        var minCell = temp.min { $0.timeText < $1.timeText }
        var maxCell = temp.max { $0.timeText < $1.timeText }
        minCell!.state = .min
        maxCell!.state = .max
        
        var newLaps: [TimeItem] = []
        for item in temp {
            if item.id == minCell!.id {
                newLaps.append(minCell!)
            } else if item.id == maxCell!.id {
                newLaps.append(maxCell!)
            } else {
                newLaps.append(item)
            }
        }
        laps = newLaps
    }
    
    func drawCircle() {
        let circle = UIBezierPath(ovalIn: CGRect(x: 4, y: 4, width: 82, height: 82))
        let rightCircleLayer = CAShapeLayer()
        rightCircleLayer.path = circle.cgPath
        rightCircleLayer.fillColor = UIColor.clear.cgColor
        rightCircleLayer.strokeColor = UIColor.black.cgColor
        rightCircleLayer.lineWidth = 2.5
        
        let leftCircleLayer = CAShapeLayer()
        leftCircleLayer.path = circle.cgPath
        leftCircleLayer.fillColor = UIColor.clear.cgColor
        leftCircleLayer.strokeColor = UIColor.black.cgColor
        leftCircleLayer.lineWidth = 2.5
        
        rightButton.layer.addSublayer(rightCircleLayer)
        leftButton.layer.addSublayer(leftCircleLayer)
    }
    
    
    //MARK: - Control Stopwatch
    private func runStopWatch() {
        startTime = Date()
        lapTime = Date()
        timer = Timer(timeInterval: timeInterval, target: self, selector: #selector(timerProc), userInfo: nil, repeats: true)
        lapTimer = Timer(timeInterval: timeInterval, target: self, selector: #selector(lapTimerProc), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer, forMode: .common)
        RunLoop.main.add(self.lapTimer, forMode: .common)
        
        status = .run
        rightButton.tintColor = .red.withAlphaComponent(0.2)
        rightButton.setTitle("Stop", for: .normal)
        rightButton.setTitleColor(.red, for: .normal)
        leftButton.setTitle("Lap", for: .normal)
        leftButton.isEnabled = true
    }
    
    private func pauseStopWatch() {
        pauseTimeInterval = currentInterval
        pauseLapTimeInterval = currentLapTimeInterval
        timer.invalidate()
        lapTimer.invalidate()
        status = .puase
        rightButton.tintColor = .green.withAlphaComponent(0.2)
        rightButton.setTitle("Start", for: .normal)
        rightButton.setTitleColor(.green, for: .normal)
        leftButton.setTitle("Reset", for: .normal)
    }
    
    private func restartStopWatch() {
        startTime = Date()
        lapTime = Date()
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerProc), userInfo: nil, repeats: true)
        lapTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(lapTimerProc), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer, forMode: .common)
        RunLoop.main.add(self.lapTimer, forMode: .common)
        
        status = .run
        rightButton.tintColor = .red.withAlphaComponent(0.2)
        rightButton.setTitle("Stop", for: .normal)
        rightButton.setTitleColor(.red, for: .normal)
        leftButton.setTitle("Lap", for: .normal)
    }
    
    private func resetStopWatch() {
        timer.invalidate()
        pauseTimeInterval = 0.0
        pauseLapTimeInterval = 0.0
        leftButton.isEnabled = false
        rightButton.tintColor = .green.withAlphaComponent(0.2)
        rightButton.setTitle("Start", for: .normal)
        rightButton.setTitleColor(.green, for: .normal)
        timeLabel.text = "00:00.00"
        status = .stop
        laps.removeAll()
        
        guard let dataSource = self.dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.lapTime, .recordTime])
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func lapStopWatch() {
        guard let dataSource = self.dataSource else { return }
        var snapshot = dataSource.snapshot()
        
        let timeItem = TimeItem(id: laps.count + 1, timeText: lapTimeText)
        
        if laps.last != nil {
            laps.append(timeItem)
            setMaxMinLaps()
            snapshot.deleteSections([.recordTime])
            snapshot.appendSections([.recordTime])
            snapshot.appendItems(laps.reversed(), toSection: .recordTime)
            
            dataSource.apply(snapshot, animatingDifferences: false)
            
            lapTime = Date()
            pauseLapTimeInterval = 0.0
        } else {
            laps.append(timeItem)
            snapshot.appendItems([timeItem], toSection: .recordTime)
            
            dataSource.apply(snapshot, animatingDifferences: false)
            
            lapTime = Date()
            pauseLapTimeInterval = 0.0
        }
    }
    
    //MARK: - Timer
    @objc func timerProc() {
        currentInterval = pauseTimeInterval + Date().timeIntervalSince(startTime)
        let intInterval = Int(currentInterval)
        
        let ms = Int((currentInterval.truncatingRemainder(dividingBy: 1)) * 100)
        let seconds = intInterval % 60
        let minutes = (intInterval / 60) % 60
        let hours = (intInterval / 3600)
        
        if hours == 0 {
            timeText = String(format: "%02d:%02d.%02d", minutes,seconds,ms)
        } else {
            timeText = String(format: "%2d:%02d:%02d.%02d", hours, minutes,seconds,ms)
        }
        
        self.timeLabel.text = timeText
    }
    
    @objc func lapTimerProc() {
        currentLapTimeInterval = pauseLapTimeInterval + Date().timeIntervalSince(lapTime)
        let intInterval = Int(currentLapTimeInterval)
        
        let ms = Int((currentLapTimeInterval.truncatingRemainder(dividingBy: 1)) * 100)
        let seconds = intInterval % 60
        let minutes = (intInterval / 60) % 60
        let hours = (intInterval / 3600)
        
        if hours == 0 {
            lapTimeText = String(format: "%02d:%02d.%02d", minutes,seconds,ms)
        } else {
            lapTimeText = String(format: "%2d:%02d:%02d.%02d", hours, minutes,seconds,ms)
        }
        
        guard let dataSource = self.dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.deleteSections([.lapTime])
        snapshot.insertSections([.lapTime], beforeSection: .recordTime)
        snapshot.appendItems([lapTimeText], toSection: .lapTime)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        if status == .stop {
            runStopWatch()
        } else if status == .run {
            pauseStopWatch()
        } else {
            restartStopWatch()
        }
    }
    
    @IBAction func leftButtonTapped(_ sender: UIButton) {
        if self.status == .run {
            lapStopWatch()
        } else if status == .puase {
            resetStopWatch()
        }
    }
}

extension StopWatchViewController {
    class DataSource: UITableViewDiffableDataSource<Section, Item> {}
}

