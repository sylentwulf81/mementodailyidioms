//
//  AudioService.swift
//  memento
//
//  Created by Damien on 7/30/25.
//

import Foundation
import AVFoundation
import AVFAudio

class AudioService: NSObject, ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    @Published var isPlaying = false
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("AudioService: Audio session setup successful")
        } catch {
            print("AudioService: Failed to setup audio session: \(error)")
        }
    }
    
    func playAudio(for idiom: Idiom) {
        print("AudioService: Attempting to play audio for idiom: \(idiom.title)")
        print("AudioService: localAudioFile = \(idiom.localAudioFile ?? "nil")")
        
        // First try to play the MP3 file if available
        if let audioFileName = idiom.localAudioFile {
            // Try to load from Resources folder
            if let audioURL = Bundle.main.url(forResource: audioFileName, withExtension: "mp3") {
                print("AudioService: Found audio file at \(audioURL)")
                playMP3(from: audioURL)
                return
            }
            
            print("AudioService: Audio file not found in bundle: \(audioFileName)")
        }
        
        print("AudioService: No audio file found, falling back to speech synthesis")
        // Fallback to speech synthesis
        playSpeechSynthesis(for: idiom.title)
    }
    
    private func playMP3(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Error playing MP3: \(error)")
            // Fallback to speech synthesis if MP3 fails
            playSpeechSynthesis(for: "")
        }
    }
    
    private func playSpeechSynthesis(for text: String) {
        print("AudioService: Starting speech synthesis for text: '\(text)'")
        
        // Check if text is empty
        guard !text.isEmpty else {
            print("AudioService: Text is empty, cannot synthesize speech")
            return
        }
        
        // Get available voices
        let voices = AVSpeechSynthesisVoice.speechVoices()
        print("AudioService: Available voices: \(voices.count)")
        
        // Try to get a good English voice
        let utterance = AVSpeechUtterance(string: text)
        
        // Try to find a good English voice
        if let englishVoice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = englishVoice
            print("AudioService: Using English voice: \(englishVoice.name)")
        } else {
            print("AudioService: English voice not available, using default")
        }
        
        utterance.rate = 0.4  // Slower rate for better clarity
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0  // Full volume
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.1
        
        // Set the synthesizer delegate to track completion
        speechSynthesizer.delegate = self
        
        speechSynthesizer.stopSpeaking(at: .immediate)
        speechSynthesizer.speak(utterance)
        isPlaying = true
        
        print("AudioService: Speech synthesis started")
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        speechSynthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
    }
    
    // Test method to verify speech synthesis is working
    func testSpeechSynthesis() {
        print("AudioService: Testing speech synthesis...")
        playSpeechSynthesis(for: "Hello, this is a test of speech synthesis")
    }
}

extension AudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}

extension AudioService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("AudioService: Speech synthesis started")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("AudioService: Speech synthesis finished")
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("AudioService: Speech synthesis cancelled")
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        // Optional: Track speech progress
    }
} 