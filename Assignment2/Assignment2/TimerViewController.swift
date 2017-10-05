//
//  TimerViewController.swift
//  Assignment2
//
//  Adapted from David Eyers' timer lecture example project by Rory O'Connor
//

import Cocoa

class TimerViewController: NSViewController, TimerModelDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    // Outlet to the label that displays the formatted timer value
    @IBOutlet weak var timerDisplay: NSTextField!
    
    // Outlet to the label that displays the formatted system time value
    @IBOutlet weak var systemTimeDisplay: NSTextField!
    
    // Outlets to the buttons at the bottom of the window
    @IBOutlet weak var startStopButton: NSButton!
    @IBOutlet weak var resetButton: NSButton!
    
    // Timer state is now in an instance of the model
    var timer:TimerModel? = nil
    
    //date formatter to format system time
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create an instance of a TimerModel and reset it
        timer = TimerModel()
        timer!.delegate = self
        timer!.reset()
        
        // Create a timer object that calls the updateSystemTime method every second
        let systemTimer = Foundation.Timer(timeInterval: 1, target: self, selector: #selector(self.updateSystemTime(_:)), userInfo: nil, repeats: true)
        
        //get a reference to the current run loop
        let loop = RunLoop.current
        
        //attach timer to the event loop
        loop.add(systemTimer, forMode: RunLoopMode.commonModes)
        
        //format the time
        dateFormatter.timeStyle = .medium
    }
    
    //update the system time display
    func updateSystemTime(_ theTimer:Foundation.Timer){
        systemTimeDisplay.stringValue = "\(dateFormatter.string(from: Date()))"
    }
    
    // Update the label to show the current time, formatted for display
    // callback target from TimerModel
    func secondsChanged(_ seconds: Int) {
        // Take the total number of seconds the timer has run for
        var s = seconds
        // Determine how many hours and minutes this represents
        let h = s/3600
        s %= 3600
        let m = s/60
        s %= 60
        
        // Update the label with the formatted timer value
        // (Rather ObjCly!)
        timerDisplay.stringValue = String(format:"%02ld:%02ld:%02ld", h,m,s)
    }
    
    // Start the timer
    func startTimer() {
        timer!.start()
        
        // Update the Start/Stop button label and state of the reset button
        //startStopButton.title = "Stop"
        startStopButton.image = NSImage(named: "pause")
        resetButton.isEnabled = false
    }
    
    // Stop the timer
    func stopTimer() {
        timer!.stop()
        
        // Update the Start/Stop button label and state of the reset button
        //startStopButton.title = "Start"
        startStopButton.image = NSImage(named: "play")
        resetButton.isEnabled = true
    }
    
    // Toggle the state of the timer
    @IBAction func startStopAction(_ sender:AnyObject) {
        if(timer!.running) {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    // The reset action zeros the counter
    @IBAction func resetAction(_ sender:AnyObject){
        timer!.reset()
    }
}
