//
//  TimerModel.swift
//
//  Designed by Lech Szymanski in 2014.
//  Swift implementation by David Eyers in 2015.
//  Updated for Swift 3.x / Xcode 8.3 in 2017 by David Eyers.
//  Adapted for project by Rory O'Connor
//

import Foundation

// classes implement this protocol to receive callbacks from the TimerModel
public protocol TimerModelDelegate {
    func secondsChanged(_ second:Int)
}

public class TimerModel: NSObject {
    var seconds:Int = 0
    var stopping:Bool = false
    
    public fileprivate(set) var running:Bool = false
    public var delegate:TimerModelDelegate? = nil
    
    func alertDelegate() {
        // if a delegate isn't defined, do nothing
        delegate?.secondsChanged(seconds)
    }
    
    // the OS's NSTimer will callback here
    @objc func countUp(_ theTimer:Foundation.Timer) {
        if(!stopping) {
            seconds += 1
            alertDelegate()
        } else {
            theTimer.invalidate()
            running = false
            stopping = false
        }
    }
    
    public func start() {
        if(running) { return }
        
        // Create a timer object that calls the countUp method every second
        let timer = Foundation.Timer(timeInterval: 1, target: self, selector: #selector(TimerModel.countUp(_:)), userInfo: nil, repeats: true)
        
        // Get a reference to the current event loop
        let loop = RunLoop.current
        
        // Attach the above timer to the event loop:
        // it will then actually start firning
        loop.add(timer, forMode: RunLoopMode.commonModes)
        
        // Change our internal state to running
        running = true
    }
    public func stop() {
        stopping = true
    }
    public func reset() {
        seconds = 0
        alertDelegate()
    }
}
