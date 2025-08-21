//
//  AnalyticsManager.swift
//  SpotifyClone
//
//  Created by Assistant on 12/19/24.
//

import Foundation
import UIKit

class AnalyticsManager: ObservableObject {
    static let shared = AnalyticsManager()
    
    private let userDefaults = UserDefaults.standard
    private let onboardingCompletedKey = "onboarding_completed_date"
    private let hasReturnedAfterOnboardingKey = "has_returned_after_onboarding"
    
    private init() {}
    
    // MARK: - Onboarding Funnel Events
    
    /// Tracks when user enters the onboarding flow
    func trackOnboardingStarted() {
        let event = AnalyticsEvent(
            name: "Onboarding_Started",
            properties: [
                "timestamp": Date().timeIntervalSince1970,
                "platform": "iOS",
                "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
            ]
        )
        sendEvent(event)
        print("📊 Analytics: Onboarding_Started")
    }
    
    /// Tracks when user completes the onboarding flow
    func trackOnboardingCompleted(userData: OnboardingUserData) {
        let event = AnalyticsEvent(
            name: "Onboarding_Completed",
            properties: [
                "timestamp": Date().timeIntervalSince1970,
                "platform": "iOS",
                "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
                "user_age": userData.age,
                "artist_selection_count": userData.selectedArtists.count,
                "completion_time": userData.completionTime
            ]
        )
        sendEvent(event)
        
        // Store completion date for return tracking
        userDefaults.set(Date(), forKey: onboardingCompletedKey)
        userDefaults.set(false, forKey: hasReturnedAfterOnboardingKey)
        
        print("📊 Analytics: Onboarding_Completed")
    }
    
    /// Tracks when user returns to app after completing onboarding
    func trackReturnedAfterOnboarding() {
        let event = AnalyticsEvent(
            name: "Returned_after_onboarding",
            properties: [
                "timestamp": Date().timeIntervalSince1970,
                "platform": "iOS",
                "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
                "days_since_onboarding": getDaysSinceOnboarding()
            ]
        )
        sendEvent(event)
        
        // Mark as returned to prevent duplicate tracking
        userDefaults.set(true, forKey: hasReturnedAfterOnboardingKey)
        
        print("📊 Analytics: Returned_after_onboarding")
    }
    
    /// Tracks account creation step
    func trackAccountCreated(email: String) {
        let event = AnalyticsEvent(
            name: "Account_Created",
            properties: [
                "timestamp": Date().timeIntervalSince1970,
                "platform": "iOS",
                "has_email": !email.isEmpty,
                "email_domain": getEmailDomain(email)
            ]
        )
        sendEvent(event)
        print("📊 Analytics: Account_Created")
    }
    
    /// Tracks artist selection completion
    func trackArtistSelectionCompleted(selectedArtists: [String]) {
        let event = AnalyticsEvent(
            name: "Artist_Selection_Completed",
            properties: [
                "timestamp": Date().timeIntervalSince1970,
                "platform": "iOS",
                "artist_count": selectedArtists.count,
                "artists": selectedArtists
            ]
        )
        sendEvent(event)
        print("📊 Analytics: Artist_Selection_Completed")
    }
    
    // MARK: - Step Tracking
    
    /// Tracks individual onboarding step completion
    func trackOnboardingStepCompleted(step: OnboardingViewModel.OnboardingStep, stepData: [String: Any] = [:]) {
        let event = AnalyticsEvent(
            name: "Onboarding_Step_Completed",
            properties: [
                "timestamp": Date().timeIntervalSince1970,
                "platform": "iOS",
                "step_name": step.title,
                "step_index": step.rawValue,
                "step_data": stepData
            ]
        )
        sendEvent(event)
        print("📊 Analytics: Onboarding_Step_Completed - \(step.title)")
    }
    
    // MARK: - App Lifecycle Tracking
    
    /// Call this when app becomes active to check for return after onboarding
    func checkForReturnAfterOnboarding() {
        guard let completionDate = userDefaults.object(forKey: onboardingCompletedKey) as? Date,
              !userDefaults.bool(forKey: hasReturnedAfterOnboardingKey) else {
            return
        }
        
        let daysSinceOnboarding = Calendar.current.dateComponents([.day], from: completionDate, to: Date()).day ?? 0
        
        if daysSinceOnboarding >= 1 {
            trackReturnedAfterOnboarding()
        }
    }
    
    // MARK: - Helper Methods
    
    private func getDaysSinceOnboarding() -> Int {
        guard let completionDate = userDefaults.object(forKey: onboardingCompletedKey) as? Date else {
            return 0
        }
        return Calendar.current.dateComponents([.day], from: completionDate, to: Date()).day ?? 0
    }
    
    private func getEmailDomain(_ email: String) -> String {
        let components = email.components(separatedBy: "@")
        return components.count > 1 ? components[1] : "unknown"
    }
    
    // MARK: - Event Sending
    
    private func sendEvent(_ event: AnalyticsEvent) {
        // In a real app, you would send this to your analytics service
        // For now, we'll just log it and could add Firebase, Mixpanel, etc.
        
        // Example: Firebase Analytics
        // Analytics.logEvent(event.name, parameters: event.properties)
        
        // Example: Mixpanel
        // Mixpanel.mainInstance().track(event.name, properties: event.properties)
        
        // Store locally for debugging
        storeEventLocally(event)
    }
    
    private func storeEventLocally(_ event: AnalyticsEvent) {
        var events = userDefaults.array(forKey: "analytics_events") as? [[String: Any]] ?? []
        events.append(event.toDictionary())
        
        // Keep only last 100 events to prevent memory issues
        if events.count > 100 {
            events = Array(events.suffix(100))
        }
        
        userDefaults.set(events, forKey: "analytics_events")
    }
}

// MARK: - Supporting Types

struct AnalyticsEvent {
    let name: String
    let properties: [String: Any]
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "properties": properties,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}

struct OnboardingUserData {
    let email: String
    let age: String
    let name: String
    let selectedArtists: [String]
    let completionTime: TimeInterval
    
    init(email: String, age: String, name: String, selectedArtists: [String], completionTime: TimeInterval) {
        self.email = email
        self.age = age
        self.name = name
        self.selectedArtists = selectedArtists
        self.completionTime = completionTime
    }
}
