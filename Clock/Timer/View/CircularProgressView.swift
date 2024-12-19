//
//  CircularProgressView.swift
//  Clock
//
//  Created by 김상민 on 2023/08/28.
//

import Foundation
import UIKit

// reference from https://ios-development.tistory.com/952

class CircularProgressView: UIView {
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 75, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let afterTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        return label
    }()
    private let vStack: UIStackView = {
       let vStack = UIStackView()
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        vStack.spacing = 10
        vStack.alignment = .center
        return vStack
    }()
    
    var delegate: TimerDelegate?
    private let backgroundLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let animationName = "progressAnimation"
    private var timer: Timer?
    private var startDate: Date = Date()
    private var duration: TimeInterval = 0.0
    private var pauseStrokeEnd: CGFloat = 0.0
    private var remainingSeconds: TimeInterval? {
        didSet {
            guard let remainingSeconds = self.remainingSeconds else { return }
            let intInterval = Int(remainingSeconds)
            
            let seconds = intInterval % 60
            let minutes = (intInterval / 60) % 60
            let hours = (intInterval / 3600)
            
            if hours == 0 {
                self.timeLabel.text = String(format: "%02d:%02d", minutes,seconds)
            } else {
                self.timeLabel.text = String(format: "%2d:%02d:%02d", hours, minutes,seconds)
            }
        }
    }
    private var circularPath: UIBezierPath {
        UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0),
                     radius: self.frame.size.width / 2.0 - 20,
                     startAngle: CGFloat(-Double.pi / 2),
                     endAngle: CGFloat(3 * Double.pi / 2),
                     clockwise: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        
        self.vStack.addArrangedSubview(timeLabel)
        self.vStack.addArrangedSubview(afterTimeLabel)
        
        self.addSubview(self.vStack)
        NSLayoutConstraint.activate([
            self.vStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.vStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
        
        self.backgroundLayer.path = self.circularPath.cgPath
        self.backgroundLayer.fillColor = UIColor.clear.cgColor
        self.backgroundLayer.lineCap = .round
        self.backgroundLayer.lineWidth = 7.0
        self.backgroundLayer.strokeEnd = 1.0
        self.backgroundLayer.strokeColor = UIColor.gray.cgColor
        self.layer.addSublayer(self.backgroundLayer)
        
        self.progressLayer.path = self.circularPath.cgPath
        self.progressLayer.fillColor = UIColor.clear.cgColor
        self.progressLayer.lineCap = .round
        self.progressLayer.lineWidth = 7.0
        self.progressLayer.strokeEnd = 0.0
        self.progressLayer.strokeColor = UIColor.orange.cgColor
        self.layer.addSublayer(self.progressLayer)
    }
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        // circularPath는 autolayout이 아닌 frame값을 이용하므로 런타임시에 변하는 frame값을 적용하기 위해서 layoutSublayer(of:)에서 호출
        // UIBezierPath는 런타임마다 바뀌는 frame값을 참조하여 원의 윤곽 레이아웃을 알아야 하므로 이곳에 적용
        self.backgroundLayer.path = self.circularPath.cgPath
        self.progressLayer.path = self.circularPath.cgPath
    }
    
    @objc func timerProc() {
        self.remainingSeconds! = duration - round(abs(self.startDate.timeIntervalSinceNow))
        guard remainingSeconds! > 0 else {
            self.stop()
            return
        }
    }
    
    func setTimeAfterTimer() {
        let currentDate = Date()
        let afterTime = currentDate.addingTimeInterval(remainingSeconds!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm"
        let dateString = dateFormatter.string(from: afterTime)
        let attributedString = NSMutableAttributedString()
        let imageAttatchment = NSTextAttachment(image: UIImage(systemName: "bell.fill")!)
        attributedString.append(NSAttributedString(attachment: imageAttatchment))
        attributedString.append(NSAttributedString(string: " " + dateString))
        self.afterTimeLabel.attributedText = attributedString
    }
    
    func makeProgressAnimation(fromeValue value: Any? = 1) {
        self.progressLayer.removeAnimation(forKey: self.animationName)
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = 0
        circularProgressAnimation.fromValue = value
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        self.progressLayer.add(circularProgressAnimation, forKey: self.animationName)
    }
    
    func start(duration: TimeInterval) {
        self.remainingSeconds = duration
        self.duration = duration
        
        setTimeAfterTimer()
        
        // timer
        self.timer?.invalidate()
        self.startDate = Date()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerProc), userInfo: nil, repeats: true)
        
        // animation
        makeProgressAnimation()
    }
    
    func pause() {
        self.duration = remainingSeconds!
        self.afterTimeLabel.textColor = .darkGray
        
        self.pauseStrokeEnd = self.progressLayer.presentation()!.strokeEnd
        self.progressLayer.strokeEnd = self.pauseStrokeEnd
        
        self.progressLayer.removeAnimation(forKey: self.animationName)
        self.timer?.invalidate()
    }
    
    func restart() {
        self.startDate = Date()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerProc), userInfo: nil, repeats: true)
        self.afterTimeLabel.textColor = .lightGray
        
        setTimeAfterTimer()
        makeProgressAnimation(fromeValue: pauseStrokeEnd)
    }
    
    func stop() {
        self.timer?.invalidate()
        self.progressLayer.removeAnimation(forKey: self.animationName)
        self.removeFromSuperview()
        delegate?.finishTimer()
    }
    
}
