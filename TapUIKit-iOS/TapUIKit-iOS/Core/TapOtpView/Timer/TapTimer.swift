//
//  TapTimer.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/13/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//

/// Protocol to communicate between the parent viewmodel to manage time events
protocol TapTimerDelegate: class {
    /// Inform the parent view that the time is finished
    func onTimeFinish()
    /**
     Inform the parent view when time got updated with the remaining minutes and seconds to expire
     - Parameter minutes: the remaining minutes to expire
     - Parameter seconds: the remaining seconds to expire
     */
    func onTimeUpdate(minutes: Int, seconds: Int)
}

/// Timer control to manage a count down timer by minutes and seconds
class TapTimer {
    /// The total remaining seconds
    private var seconds: Int
    
    weak var delegate: TapTimerDelegate? {
        didSet {
            self.delegate?.onTimeUpdate(minutes: seconds / 60, seconds: seconds % 60)
        }
    }
    
    /// Timer used to manage the count down seconds
    private var timer: Timer?
    
    init(minutes: Int, seconds: Int) {
        self.seconds = seconds + minutes * 60
    }
    
    /// Start counting down from the initial minutes and seconds to zero
    func start() {
        if timer == nil {
            timer = Timer()
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(didUpdateTime), userInfo: nil, repeats: true)
    }
    
    /// Invalidate the timer and set to nil
    internal func reset() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Called by the timer every second to fire the callback deleagate events
    @objc private func didUpdateTime() {
        //print("time now: \(self.seconds)")
        if seconds < 1 {
            self.reset()
            self.delegate?.onTimeFinish()
        } else {
            self.seconds -= 1
        }
        self.delegate?.onTimeUpdate(minutes: seconds / 60, seconds: seconds % 60)
    }
}
