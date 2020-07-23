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
    weak var delegate: TapTimerDelegate? {
        didSet {
            self.delegate?.onTimeUpdate(minutes: seconds / 60, seconds: seconds % 60)
        }
    }
    private var timer: Timer?
    
    init(minutes: Int, seconds: Int) {
        self.seconds = seconds + minutes * 60
    }
    
    func start() {
        if timer == nil {
            timer = Timer()
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(didUpdateTime), userInfo: nil, repeats: true)
    }
    
    internal func reset() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func didUpdateTime() {
        if seconds < 1 {
            self.reset()
            self.delegate?.onTimeFinish()
        } else {
            self.seconds -= 1
        }
        self.delegate?.onTimeUpdate(minutes: seconds / 60, seconds: seconds % 60)
    }
}
