//
//  MusicManager.swift
//  Hangman
//
//  Created by Benjamin Sidley on 6/12/24.
//

import AVFoundation

class MusicManager: ObservableObject {
    static let shared = MusicManager()
    private var audioPlayer: AVAudioPlayer?
    private var soundEffectPlayer: AVAudioPlayer?
    
    @Published var isPlaying = false
    @Published var areSoundEffectsEnabled = true
    @Published var musicVolume: Float = 1.0 {
        didSet {
            audioPlayer?.volume = musicVolume
        }
    }
    @Published var soundEffectsVolume: Float = 1.0
    
    private init() {
        // Load the music file
        guard let url = Bundle.main.url(forResource: "island-breeze-214305", withExtension: "mp3") else {
            print("Background music file not found.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = musicVolume
        } catch {
            print("Error loading music file: \(error)")
        }
    }
    
    func play() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    func stop() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func toggleMusic(isOn: Bool) {
        if isOn {
            play()
        } else {
            stop()
        }
    }
    
    func playSoundEffect(named soundFileName: String) {
        guard areSoundEffectsEnabled else { return }
        guard let url = Bundle.main.url(forResource: soundFileName, withExtension: "mp3") else {
            print("Sound effect file not found.")
            return
        }

        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            soundEffectPlayer?.volume = soundEffectsVolume
            soundEffectPlayer?.play()
        } catch {
            print("Error loading sound effect file: \(error)")
        }
    }

    func toggleSoundEffects(isOn: Bool) {
        areSoundEffectsEnabled = isOn
    }
    
    func setMusicVolume(_ volume: Float) {
        musicVolume = volume
    }
        
    func setSoundEffectsVolume(_ volume: Float) {
        soundEffectsVolume = volume
    }
}
