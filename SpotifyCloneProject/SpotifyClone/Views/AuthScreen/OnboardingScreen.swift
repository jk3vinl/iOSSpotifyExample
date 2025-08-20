//
//  OnboardingScreen.swift
//  SpotifyClone
//
//  Created by Assistant on 12/19/24.
//

import SwiftUI

struct OnboardingScreen: View {
    @ObservedObject var onboardingVM: OnboardingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.03303453139, green: 0.03028165377, blue: 0.03578740901, alpha: 1)), Color(#colorLiteral(red: 0.06192958647, green: 0.05548349203, blue: 0.06590141785, alpha: 1))]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with progress indicator
                    headerView(geometry: geometry)
                    
                    // Content area
                    contentView(geometry: geometry)
                    
                    // Bottom navigation
                    bottomNavigationView(geometry: geometry)
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: onboardingVM.isOnboardingComplete) { isComplete in
            if isComplete {
                // Navigate to home screen
                dismiss()
            }
        }
    }
    
    private func headerView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            // Spotify logo
            Image("spotify-full-logo")
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width / 4)
                .padding(.top, 20)
            
            // Progress indicator
            HStack(spacing: 8) {
                ForEach(0..<OnboardingViewModel.OnboardingStep.allCases.count, id: \.self) { index in
                    Rectangle()
                        .fill(index <= onboardingVM.currentStep.rawValue ? Color.spotifyGreen : Color.gray.opacity(0.3))
                        .frame(height: 3)
                        .animation(.easeInOut(duration: 0.3), value: onboardingVM.currentStep)
                }
            }
            .padding(.horizontal, Constants.paddingLarge)
        }
        .padding(.bottom, 30)
    }
    
    private func contentView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 30) {
            // Title and subtitle
            VStack(spacing: 12) {
                Text(onboardingVM.currentStep.title)
                    .font(.avenir(.black, size: geometry.size.width / 15))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(onboardingVM.currentStep.subtitle)
                    .font(.avenir(.book, size: geometry.size.width / 25))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.paddingLarge)
            }
            
            // Step-specific content
            switch onboardingVM.currentStep {
            case .email:
                emailStepView
            case .password:
                passwordStepView
            case .age:
                ageStepView
            case .name:
                nameStepView
            case .artists:
                artistsStepView(geometry: geometry)
            }
            
            Spacer()
        }
        .padding(.horizontal, Constants.paddingLarge)
    }
    
    private var emailStepView: some View {
        VStack(spacing: 20) {
            TextField("Enter your email", text: $onboardingVM.email)
                .textFieldStyle(OnboardingTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
    }
    
    private var passwordStepView: some View {
        VStack(spacing: 20) {
            SecureField("Create a password", text: $onboardingVM.password)
                .textFieldStyle(OnboardingTextFieldStyle())
            
            Text("Password must be at least 8 characters")
                .font(.avenir(.book, size: 12))
                .foregroundColor(.gray)
        }
    }
    
    private var ageStepView: some View {
        VStack(spacing: 20) {
            TextField("Enter your age", text: $onboardingVM.age)
                .textFieldStyle(OnboardingTextFieldStyle())
                .keyboardType(.numberPad)
        }
    }
    
    private var nameStepView: some View {
        VStack(spacing: 20) {
            TextField("Enter your name", text: $onboardingVM.name)
                .textFieldStyle(OnboardingTextFieldStyle())
                .autocapitalization(.words)
        }
    }
    
    private func artistsStepView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            Text("Selected: \(onboardingVM.selectedArtists.count)/3")
                .font(.avenir(.medium, size: 14))
                .foregroundColor(.spotifyGreen)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(onboardingVM.availableArtists, id: \.self) { artist in
                        ArtistSelectionCard(
                            artist: artist,
                            isSelected: onboardingVM.selectedArtists.contains(artist),
                            action: { onboardingVM.toggleArtist(artist) }
                        )
                    }
                }
                .padding(.horizontal, 10)
            }
            .frame(maxHeight: geometry.size.height * 0.4)
        }
    }
    
    private func bottomNavigationView(geometry: GeometryProxy) -> some View {
        HStack {
            // Back button
            if onboardingVM.currentStep.rawValue > 0 {
                Button("Back") {
                    onboardingVM.previousStep()
                }
                .font(.avenir(.medium, size: 16))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(25)
            }
            
            Spacer()
            
            // Next/Complete button
            Button(onboardingVM.currentStep == .artists ? "Complete" : "Next") {
                onboardingVM.nextStep()
            }
            .font(.avenir(.heavy, size: 16))
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(onboardingVM.canProceed() ? Color.spotifyGreen : Color.gray.opacity(0.3))
            .cornerRadius(25)
            .disabled(!onboardingVM.canProceed())
        }
        .padding(.horizontal, Constants.paddingLarge)
        .padding(.bottom, 30)
    }
}

struct OnboardingTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(.white)
            .font(.avenir(.book, size: 16))
    }
}

struct ArtistSelectionCard: View {
    let artist: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(artist)
                    .font(.avenir(.medium, size: 14))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.spotifyGreen)
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color.spotifyGreen.opacity(0.2) : Color.white.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.spotifyGreen : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingScreen(onboardingVM: OnboardingViewModel())
}
