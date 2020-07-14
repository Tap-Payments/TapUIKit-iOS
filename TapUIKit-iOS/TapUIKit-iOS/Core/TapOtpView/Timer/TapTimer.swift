//
//  TapTimer.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/13/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//
protocol TapTimerDelegate: class {
    func onTimeFinish()
    func onTimeUpdate(minutes: Int, seconds: Int)
}

class TapTimer {
    private var seconds: Int
    private weak var delegate: TapTimerDelegate?
    private lazy var timer: Timer = {
        return Timer()
    }()
    
    init(minutes: Int, seconds: Int) {
        self.seconds = seconds + minutes * 60
    }
    
    func start() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(didUpdateTime), userInfo: nil, repeats: false)
    }
    
    func reset() {
        timer.invalidate()
    }
    
    @objc private func didUpdateTime() {
        if seconds < 1 {
            timer.invalidate()
            self.delegate?.onTimeFinish()
        } else {
            self.seconds -= 1
        }
        self.delegate?.onTimeUpdate(minutes: seconds / 60, seconds: seconds % 60)
    }
}
