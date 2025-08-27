//
//  AudioViewModel.swift
//  Arca
//
//  Created by Gede Pramananda Kusuma Wisesa on 27/08/25.
//

import Foundation
import AVFoundation

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
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
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
    
    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
        currentAudioURL = nil
        completionHandler = nil
    }
    
    deinit {
        stopAudio()
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
