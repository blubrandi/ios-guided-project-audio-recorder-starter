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
        updateViews()
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
        audioPlayer?.delegate = self
    }
    

    
    @IBAction func playButtonPressed(_ sender: Any) {
        playPause()
	}
    
    // Record APIs
    
    var audioRecorder: AVAudioRecorder?
    
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    func record() {
        // get documents dir
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // file name
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        
        //create file by appending two things together
        let file = documents.appendingPathComponent(name).appendingPathExtension("caf")
        
        print("record: \(file)")
        
        //create a new format to control audio quality
        // 44.1 KHz 44,100 samples per second, 1 microphone
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        // ^^^^ add error handling so we don't have to force unwrap
        audioRecorder = try! AVAudioRecorder(url: file, format: format)
        audioRecorder?.record()
    }
    
    func stop() {
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    func recordToggle() {
        if isRecording {
            stop()
        } else {
            record()
        }
    }
    
    
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        recordToggle()
    }
    
    // Update UI
    
    private func updateViews() {
        
        let playButtonTitle = isPlaying ? "Pause" : "Play"
        playButton.setTitle(playButtonTitle, for: .normal)
        
        let elapsedTime = audioPlayer?.currentTime ?? 0
        timeLabel.text = timeFormatter.string(from: elapsedTime)
        
        // reset the slider - per asset, ex: per different audio file
        
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(audioPlayer?.duration ?? 0)
        timeSlider.value = Float(elapsedTime)
    }
}

extension AudioRecorderController: AVAudioPlayerDelegate {
    
    // Resets when it's finished playing
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio Player error: \(error)")
        }
    }
}

