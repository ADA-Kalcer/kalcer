//
//  AudioViewModel.swift
//  Arca
//
//  Created by Gede Pramananda Kusuma Wisesa on 27/08/25.
//

import Foundation
import AVFoundation
import MediaPlayer

class AudioViewModel: NSObject, ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    private var audioSession = AVAudioSession.sharedInstance()
    
    @Published var isPlaying = false
    @Published var currentAudioURL: String?
    
    private var completionHandler: (() -> Void)?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [])
            try audioSession.setActive(true)
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleInterruption),
                name: AVAudioSession.interruptionNotification,
                object: nil
            )
            
            print("Audio session configured successfully")
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey]
                as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            pauseAudio()
        case .ended:
            if let optionsValue =
                userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    resumeAudio()
                }
            }
        @unknown default:
            break
        }
    }
    
    func playAudio(from urlString: String, completion: @escaping () ->
                   Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid audio URL: \(urlString)")
            completion()
            return
        }
        
        completionHandler = completion
        currentAudioURL = urlString
        
        // Download and play audio
        URLSession.shared.dataTask(with: url) { [weak self] data,
            response, error in
            guard let self = self,
                  let data = data,
                  error == nil else {
                print("Failed to download audio: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
            
            DispatchQueue.main.async {
                self.playAudioData(data)
            }
        }.resume()
        
        
    }
    
    private func playAudioData(_ data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Failed to play audio: \(error)")
            completionHandler?()
            completionHandler = nil
        }
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func resumeAudio() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
        currentAudioURL = nil
        completionHandler = nil
    }
    
    deinit {
        stopAudio()
        NotificationCenter.default.removeObserver(self)
    }
}

extension AudioViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
            self?.currentAudioURL = nil
            self?.completionHandler?()
            self?.completionHandler = nil
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio decode error: \(error?.localizedDescription ?? "Unknown error")")
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
            self?.currentAudioURL = nil
            self?.completionHandler?()
            self?.completionHandler = nil
        }
    }
}
