//
//  OnboardingViewModel.swift
//  SpotifyClone
//
//  Created by Assistant on 12/19/24.
//

import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .email
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var age: String = ""
    @Published var name: String = ""
    @Published var selectedArtists: Set<String> = []
    @Published var isOnboardingComplete = false
    
    private let analyticsManager = AnalyticsManager.shared
    private let startTime = Date()
    
    init() {
        // Track onboarding start
        analyticsManager.trackOnboardingStarted()
    }
    
    // Sample artists for selection
    let availableArtists = [
        "Taylor Swift", "Drake", "The Weeknd", "Bad Bunny", "Ed Sheeran",
        "Ariana Grande", "Post Malone", "Billie Eilish", "Dua Lipa", "Justin Bieber",
        "Beyoncé", "Kendrick Lamar", "Lady Gaga", "Bruno Mars", "Rihanna",
        "Coldplay", "Imagine Dragons", "Maroon 5", "The Chainsmokers", "Calvin Harris"
    ]
    
    enum OnboardingStep: Int, CaseIterable {
        case email = 0
        case password = 1
        case age = 2
        case name = 3
        case artists = 4
        
        var title: String {
            switch self {
            case .email: return "What's your email?"
            case .password: return "Create a password"
            case .age: return "What's your age?"
            case .name: return "What should we call you?"
            case .artists: return "Pick 3 artists you love"
            }
        }
        
        var subtitle: String {
            switch self {
            case .email: return "You'll use this to sign in to Spotify"
            case .password: return "Create a password to keep your account safe"
            case .age: return "This helps us provide you with the right content"
            case .name: return "This appears on your profile"
            case .artists: return "We'll use this to personalize your experience"
            }
        }
    }
    
    func nextStep() {
        // Track step completion
        analyticsManager.trackOnboardingStepCompleted(step: currentStep, stepData: getStepData())
        
        // Track specific events
        if currentStep == .email && !email.isEmpty {
            analyticsManager.trackAccountCreated(email: email)
        }
        
        if currentStep == .artists && selectedArtists.count == 3 {
            analyticsManager.trackArtistSelectionCompleted(selectedArtists: Array(selectedArtists))
        }
        
        if currentStep.rawValue < OnboardingStep.allCases.count - 1 {
            currentStep = OnboardingStep(rawValue: currentStep.rawValue + 1) ?? .email
        } else {
            completeOnboarding()
        }
    }
    
    func previousStep() {
        if currentStep.rawValue > 0 {
            currentStep = OnboardingStep(rawValue: currentStep.rawValue - 1) ?? .email
        }
    }
    
    func canProceed() -> Bool {
        switch currentStep {
        case .email:
            return isValidEmail(email)
        case .password:
            return password.count >= 8
        case .age:
            return isValidAge(age)
        case .name:
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .artists:
            return selectedArtists.count == 3
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidAge(_ age: String) -> Bool {
        guard let ageInt = Int(age) else { return false }
        return ageInt >= 13 && ageInt <= 120
    }
    
    private func completeOnboarding() {
        // Track onboarding completion
        let completionTime = Date().timeIntervalSince(startTime)
        let userData = OnboardingUserData(
            email: email,
            age: age,
            name: name,
            selectedArtists: Array(selectedArtists),
            completionTime: completionTime
        )
        
        analyticsManager.trackOnboardingCompleted(userData: userData)
        
        // Here you would typically save the user data to your backend
        // For now, we'll just mark onboarding as complete
        isOnboardingComplete = true
    }
    
    private func getStepData() -> [String: Any] {
        switch currentStep {
        case .email:
            return ["email_length": email.count]
        case .password:
            return ["password_length": password.count, "has_special_chars": password.rangeOfCharacter(from: .punctuationCharacters) != nil]
        case .age:
            return ["age": age]
        case .name:
            return ["name_length": name.count]
        case .artists:
            return ["selected_count": selectedArtists.count]
        }
    }
    
    func toggleArtist(_ artist: String) {
        if selectedArtists.contains(artist) {
            selectedArtists.remove(artist)
        } else if selectedArtists.count < 3 {
            selectedArtists.insert(artist)
        }
    }
}
