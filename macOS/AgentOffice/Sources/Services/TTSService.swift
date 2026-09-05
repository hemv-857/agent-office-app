// TTSService.swift
import AVFoundation
import Combine

class TTSService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    static let shared = TTSService()

    @Published var isSpeaking = false
    @Published var currentVoice: String = "default"
    @Published var rate: Float = AVSpeechUtteranceDefaultSpeechRate
    @Published var pitch: Float = 1.0
    @Published var volume: Float = 1.0
    @Published var availableVoices: [AVSpeechSynthesisVoice] = []

    private let synthesizer = AVSpeechSynthesizer()

    private override init() {
        super.init()
        synthesizer.delegate = self
        loadVoices()
    }

    func loadVoices() {
        availableVoices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en") }
            .sorted { $0.name < $1.name }
    }

    func speak(_ text: String, voiceId: String? = nil) {
        stop()

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.volume = volume

        if let voiceId = voiceId, let voice = AVSpeechSynthesisVoice(identifier: voiceId) {
            utterance.voice = voice
        } else if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }

        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }

    func pause() {
        synthesizer.pauseSpeaking(at: .word)
    }

    func resume() {
        synthesizer.continueSpeaking()
    }

    func speakAgentResponse(_ text: String, agentName: String) {
        let intro = "\(agentName) says: "
        speak(intro + text)
    }

    func savePreferences() {
        UserDefaults.standard.set(currentVoice, forKey: "ttsVoice")
        UserDefaults.standard.set(rate, forKey: "ttsRate")
        UserDefaults.standard.set(pitch, forKey: "ttsPitch")
        UserDefaults.standard.set(volume, forKey: "ttsVolume")
    }

    func loadPreferences() {
        currentVoice = UserDefaults.standard.string(forKey: "ttsVoice") ?? "default"
        rate = UserDefaults.standard.float(forKey: "ttsRate")
        pitch = UserDefaults.standard.float(forKey: "ttsPitch")
        volume = UserDefaults.standard.float(forKey: "ttsVolume")
        if rate == 0 { rate = AVSpeechUtteranceDefaultSpeechRate }
        if pitch == 0 { pitch = 1.0 }
        if volume == 0 { volume = 1.0 }
    }

    // MARK: - AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = true }
    }
}
