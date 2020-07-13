//
//  TapTimer.swift
//  TapUIKit-iOS
//
//  Created by Kareem Ahmed on 7/13/20.
//  Copyright © 2020 Tap Payments. All rights reserved.
//
protocol TapTimerDelegate {
    func onTimeFinish()
    func onTimeUpdate()
}

class TapTimer {
    private var maxMinutes: Int
    private var maxSeconds: Int
    
    private lazy var timer: Timer = {
        return Timer()
    }()
    
    init(maxMinutes: Int, maxSeconds: Int) {
        self.maxMinutes = maxMinutes
        self.maxSeconds = maxSeconds
    }
    
    func start() {
        
    }
    
    func reset() {
//        self.currentMinutes = self.maxMinutes
//        self.currentSeconds = self.maxSeconds
    }
}
