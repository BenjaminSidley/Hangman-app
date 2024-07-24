//
//  HowToPlayView.swift
//  Hangman
//
//  Created by Benjamin Sidley on 6/13/24.
//

import Foundation
import SwiftUI

struct HowToPlayView: View {
    @ObservedObject var musicManager = MusicManager.shared
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How to Play")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Hangman is a classic word-guessing game where your goal is to correctly guess the hidden word or phrase before running out of attempts. At the start of the game, the word or phrase to guess is represented by a series of dashes, each dash indicating a letter in the word. You can guess one letter at a time by clicking on the letters displayed on the screen. If the letter is in the word, it will appear in its correct position(s). If the letter is not in the word, you lose an attempt, and a part of the hangman figure is drawn. You have a limited number of attempts to guess the entire word. If you guess the word before using all your attempts, you win and move on to the next level. If you run out of attempts, the game is over, and you can try again. Remember to think carefully and choose your letters wisely!")
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
    }
}
