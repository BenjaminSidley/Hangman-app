//
//  SettingsPopupView.swift
//  Hangman
//
//  Created by Benjamin Sidley on 6/12/24.
//

import SwiftUI

struct CustomToggleStyle: ToggleStyle {
    var labelColor: Color

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .foregroundColor(labelColor)
            Spacer()
            Toggle("", isOn: configuration.$isOn)
                .labelsHidden()
        }
        .padding()
    }
}

struct SettingsPopupView: View {
    @Binding var isPresented: Bool
    @ObservedObject var musicManager = MusicManager.shared
    @State private var showHowToPlay = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Toggle("Music", isOn: Binding(
                get: { musicManager.isPlaying },
                set: { musicManager.toggleMusic(isOn: $0)
                    musicManager.playSoundEffect(named: "switch")
                }
            ))
            .toggleStyle(CustomToggleStyle(labelColor: .black))
            .padding()
            
            Slider(value: $musicManager.musicVolume, in: 0...1) {
                Text("Music Volume")
            }
            .padding()
            
            Toggle("Sound Effects", isOn: Binding(
                get: { musicManager.areSoundEffectsEnabled },
                set: { musicManager.toggleSoundEffects(isOn: $0)
                    musicManager.playSoundEffect(named: "switch")
                }
            ))
            .toggleStyle(CustomToggleStyle(labelColor: .black))
            .padding()
            
            Slider(value: $musicManager.soundEffectsVolume, in: 0...1) {
                Text("Sound Effects Volume")
            }
            .padding()
            
            Button("How to Play") {
                musicManager.playSoundEffect(named: "menu")
                showHowToPlay = true
            }
            .padding()
            
            Button("Close") {
                musicManager.playSoundEffect(named: "back")
                isPresented = false
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.red)
            .cornerRadius(10)
        }
        .padding()
        .background(Color(red: 224 / 255, green: 224 / 255, blue: 224 / 255))
        .cornerRadius(20)
        .shadow(radius: 20)
        if showHowToPlay {
            HowToPlayView(isPresented: $showHowToPlay)
                .frame(width: 350, height: 700) // Adjust the width and height here
                .cornerRadius(20)
                .shadow(radius: 20)
                .padding()
        }
    }
}
