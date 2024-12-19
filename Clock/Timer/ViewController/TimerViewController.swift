//
//  TimerViewController.swift
//  Clock
//
//  Created by 김상민 on 2023/08/27.
//

/*
 할 것:
 Radar (Default)일 경우 Radar로 보이게
 코드 정리
 */


import UIKit

class TimerViewController: UIViewController {
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    enum TimerCase {
        case stop
        case run
        case pause
    }
    var circularView: CircularProgressView? = nil
    var state: TimerCase = .stop
    var hours: [Int] = Array(0...23)
    var minutes: [Int] = Array(0...59)
    var seconds: [Int] = Array(0...59)
    
    var selectedHour: Int = 0
    var selectedMinute: Int = 0
    var selectedSecond: Int = 0
    
    //MARK: - DataSource
    var dataSource: UITableViewDiffableDataSource<Section, Item>!
    typealias Item = RingModel
    enum Section {
        case main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        setPicker()
        setButtonLayout()
        setTableView()
        configureDataSource()
    }
    
    private func setButtonLayout() {
        drawCircle()
        rightButton.layer.cornerRadius = 45.0
        leftButton.layer.cornerRadius = 45.0
        rightButton.setTitle("Start", for: .normal)
        leftButton.setTitle("Cancel", for: .normal)
        rightButton.setTitleColor(.green, for: .normal)
        rightButton.tintColor = .green.withAlphaComponent(0.2)
        leftButton.tintColor = .gray.withAlphaComponent(0.2)
        leftButton.isEnabled = false
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
    
    private func setPicker() {
        selectedHour = hours.first!
        selectedMinute = minutes.first!
        selectedSecond = seconds.first!
        setLabelsToPicker(with: ["hours", "min", "sec"])
    }
    
    private func setTableView() {
        tableView.alwaysBounceVertical = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SelectRingToneCell")
    }
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView, cellProvider: { tableView, indexPath, item in
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "SelectRingToneCell")
            
            cell.accessoryType = .disclosureIndicator
            
            var config = cell.defaultContentConfiguration()
            config.text = "When Timer Ends"
            config.secondaryText = "\(RingModel.shared.ring)"
            cell.contentConfiguration = config
            
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems([RingModel.shared])
        dataSource.apply(snapshot)
        
    }
    
    // reference from https://gyuios.tistory.com/136
    private func setLabelsToPicker(with labels: [String]) {
        let columCount = labels.count
        let fontSize: CGFloat = 20
        
        var labelList: [UILabel] = []
        for index in 0..<columCount {
            let label = UILabel()
            label.text = labels[index]
            label.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
            labelList.append(label)
        }
        
        let pickerWidth: CGFloat = pickerView.frame.width
        let labelY: CGFloat = (pickerView.frame.height / 2) + 35
        
        for (index, label) in labelList.enumerated() {
            let labelX: CGFloat = (pickerWidth / CGFloat(columCount)) * CGFloat(index + 1) - fontSize * 1.7
            label.frame = CGRect(x: labelX, y: labelY, width: 0, height: 0)
            label.sizeToFit()
            pickerView.addSubview(label)
        }
    }
    
    func startButtonTapped() {
        let selectedHourToSec = selectedHour * 3600
        let selectedMinToSec = selectedMinute * 60
        
        let duration = selectedHourToSec + selectedMinToSec + selectedSecond
        
        if duration == 0 { return }
        
        state = .run
        pickerView.isHidden = true
        leftButton.isEnabled = true
        rightButton.setTitle("Pause", for: .normal)
        rightButton.setTitleColor(.orange, for: .normal)
        rightButton.tintColor = .orange.withAlphaComponent(0.2)
        circularView = CircularProgressView()
        guard let circularView = circularView else { return }
        circularView.delegate = self
        circularView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(circularView)
        NSLayoutConstraint.activate([
            circularView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            circularView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            circularView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            circularView.bottomAnchor.constraint(equalTo: self.pickerView.bottomAnchor)
        ])
        
        circularView.start(duration: TimeInterval(duration))
    }
    
    func puaseButtonTapped() {
        state = .pause
        rightButton.setTitle("Resume", for: .normal)
        rightButton.setTitleColor(.green, for: .normal)
        rightButton.tintColor = .green.withAlphaComponent(0.2)
        guard let circularView = circularView else { return }
        circularView.pause()
    }
    
    func restartbuttonTapped() {
        state = .run
        rightButton.setTitle("Pause", for: .normal)
        rightButton.setTitleColor(.orange, for: .normal)
        rightButton.tintColor = .orange.withAlphaComponent(0.2)
        guard let circularView = circularView else { return }
        circularView.restart()
    }
    
    @IBAction func rightButtonTapped(_ sender: Any) {
        switch state {
        case .stop:
            startButtonTapped()
        case .run:
            puaseButtonTapped()
        case .pause:
            restartbuttonTapped()
        }
        
    }
    
    @IBAction func leftButtonTapped(_ sender: Any) {
        state = .stop
        guard let circularView = circularView else { return }
        circularView.stop()
//        self.circularView = nil
        pickerView.isHidden = false
        leftButton.isEnabled = false
        rightButton.setTitle("Start", for: .normal)
        rightButton.setTitleColor(.green, for: .normal)
        rightButton.tintColor = .green.withAlphaComponent(0.2)
    }
    
}

extension TimerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return hours.count
        case 1:
            return minutes.count
        case 2:
            return seconds.count
        default:
            return 0
        }
    }
}

extension TimerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(hours[row])"
        case 1:
            return "\(minutes[row])"
        case 2:
            return "\(seconds[row])"
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            selectedHour = hours[row]
        case 1:
            selectedMinute = minutes[row]
        case 2:
            selectedSecond = seconds[row]
        default:
            break
        }
        print(selectedHour, selectedMinute, selectedSecond)
    }
}

extension TimerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let timerAlarmVC = TimerAlarmViewController()
        timerAlarmVC.selectedRing = RingModel.shared.ring
        timerAlarmVC.delegate = self
        timerAlarmVC.navigationItem.title = "When Timer Ends"
        
        let navigationVC = UINavigationController(rootViewController: timerAlarmVC)
        navigationVC.navigationBar.tintColor = .orange
        
        self.present(navigationVC, animated: true)
    }
}

extension TimerViewController: TimerDelegate {
    func timer(ring: String) {
        var ringString = ring
        if ringString == "Radar (Default)" {
            ringString = "Radar"
        }
        
        RingModel.shared.ring = ringString
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems([RingModel.shared])
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func finishTimer() {
        self.pickerView.isHidden = false
        self.state = .stop
        pickerView.isHidden = false
        leftButton.isEnabled = false
        rightButton.setTitle("Start", for: .normal)
        rightButton.setTitleColor(.green, for: .normal)
        rightButton.tintColor = .green.withAlphaComponent(0.2)
    }
}
