//
//  ViewController.swift
//  AudioRecorder
//
//  Created by Paul Solt on 10/1/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorderController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
	
	private lazy var timeFormatter: DateComponentsFormatter = {
		let formatting = DateComponentsFormatter()
		formatting.unitsStyle = .positional // 00:00  mm:ss
		// NOTE: DateComponentFormatter is good for minutes/hours/seconds
		// DateComponentsFormatter not good for milliseconds, use DateFormatter instead)
		formatting.zeroFormattingBehavior = .pad
		formatting.allowedUnits = [.minute, .second]
		return formatting
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()


        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeLabel.font.pointSize,
                                                          weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize,
                                                                   weight: .regular)
        
        loadAudio()
	}
    
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    func play() {
        audioPlayer?.play()
        updateViews()
        startTimer()
    }
    
    func pause() {
        audioPlayer?.pause()
        updateViews()
        cancelTimer()
    }
    
    func playPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    private func startTimer() {
        cancelTimer() // to make sure only one timer is running and no others
        timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(updateTimer(timer:)), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTimer(timer: Timer) {
        updateViews()
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }


    //Playback APIs
    //What are functions needed for playback?
    // - get audio file
    // - play
    // - pause
    // - timestamp (current time?)
    // - is it playing?
    
    private func loadAudio() {
        // piano.mp3
        // App Bundle - readonly
        // Documents - are only readwrite
        
        let songURL = Bundle.main.url(forResource: "piano", withExtension: "mp3")!
        
        audioPlayer = try! AVAudioPlayer(contentsOf: songURL)  // FIXME: catch error and print
    }
    

    
    @IBAction func playButtonPressed(_ sender: Any) {
        playPause()
	}
    
    // Record APIs
    
    @IBAction func recordButtonPressed(_ sender: Any) {
    
    }
    
    // Update UI
    
    private func updateViews() {
        
        let playButtonTitle = isPlaying ? "Pause" : "Play"
        playButton.setTitle(playButtonTitle, for: .normal)
        
        let elapsedTime = audioPlayer?.currentTime ?? 0
        timeLabel.text = timeFormatter.string(from: elapsedTime)
    }
}

