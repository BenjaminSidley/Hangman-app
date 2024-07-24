//
//  LocalTwoPlayerView.swift
//  Hangman
//
//  Created by Benjamin Sidley on 6/13/24.
//

import SwiftUI

enum GameOutcomes {
    case none
    case won
    case lost
}

struct LocalTwoPlayerView: View {
    @State private var wordToGuess: String = ""
    @State private var guessedLetters: Set<Character> = []
    @State private var remainingAttempts = 8
    @State private var showingEnterWordPopup = true
    @State private var showingEndGamePopup = false
    @State private var popupTitle = ""
    @State private var popupMessage = ""
    @State private var guessedLetterColors: [Character: Color] = [:]
    @State private var gameOutcomes: GameOutcomes = .none
    @State private var showSettings = false
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var musicManager = MusicManager.shared
    
    let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
        
    ]
    
    
    
    init() {
        self._wordToGuess = State(initialValue: "")
    }
    
    var body: some View {
        ZStack {
            
            
            
            Image("HM20")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            
            
            // Hangman figure
            HangmanView2(remainingAttempts: remainingAttempts)
                .frame(width: 200, height: 300)
                .position(x: 135, y: 214)
            
            VStack {
                
                HStack {
                    Button(action: {
                        musicManager.playSoundEffect(named: "back")
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "house")
                            .resizable()
                            .frame(width: 27, height: 27)
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .offset(x: -120,y: -10)
                    
                    Button(action: {
                        musicManager.playSoundEffect(named: "menu")
                        showSettings = true
                        
                    }) {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 27, height: 27)
                            .padding(10)
                            .background(Color(red: 224 / 255, green: 224 / 255, blue: 224 / 255))
                            .clipShape(Circle())
                    }
                    
                    .offset(x: 130,y: -10)
                    
                }
                
                HStack {
                    Spacer()
                    HStack(spacing: 1) {
                        Image(systemName: remainingAttempts == 0 ? "heart.slash.fill" : "heart.fill")
                            .foregroundColor(.red)
                            .font(.title)
                        Text(" \(remainingAttempts)")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        
                    }
                    
                    .offset(x: -60,y: 0)
                }
                
                GeometryReader { geometry in
                    VStack {
                        Spacer(minLength: geometry.size.height * 0.7)
                        FixedWidthTextView2(words: displayedWords, availableWidth: geometry.size.width)
                        Spacer(minLength: geometry.size.height * 0.2)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                }
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(letters, id: \.self) { letter in
                        Button(action: {
                            self.letterTapped(letter)
                        }) {
                            Text(String(letter))
                                .font(Font.custom("'-RonySiswadi-Architect-5", size:40))
                                .padding(.top, 9)
                                .frame(width: 35, height: 55)
                                .background(guessedLetters.contains(letter) ? guessedLetterColors[letter, default: Color.gray] : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            
                        }
                        .disabled(self.guessedLetters.contains(letter))
                    }
                }
                .padding()
                
                Spacer()
            }
            
            if showingEnterWordPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                EnterWordPopupView(isPresented: $showingEnterWordPopup, wordToGuess: $wordToGuess)
                    .frame(width: 300, height: 200)
                    .transition(.scale)
                    .zIndex(1)
            }
            
            
            
            if showSettings {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                                
                SettingsPopupView(isPresented: $showSettings)
                    .frame(width: 300, height: 300)
                    .transition(.scale)
                    .zIndex(1)
            }
            
            if showingEndGamePopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                EndGamePopupView(
                    gameOutcome: gameOutcomes,
                    wordToGuess: wordToGuess,
                    playAgainAction: {
                        self.startNewGame()
                    },
                    exitAction: {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                )
                .frame(width: 300, height: 200)
                .transition(.scale)
                .zIndex(1)
            }
                
        }
        .navigationBarBackButtonHidden(true)
    }

    var displayedWords: [String] {
        let words = wordToGuess.split(separator: " ").map { String($0) }
        return words.map { word in
            var display = ""
            for letter in word {
                if guessedLetters.contains(letter) || letter == "-" || letter == "'" || letter == "?"{
                    display += "\(letter) "
                } else {
                    display += "_ "
                }
            }
            return display.trimmingCharacters(in: .whitespaces)
        }
    }

   

    func letterTapped(_ letter: Character) {
        guessedLetters.insert(letter)

        if wordToGuess.contains(letter) {
            musicManager.playSoundEffect(named: "scrib2")
            guessedLetterColors[letter] = Color.green.opacity(0.29)
        } else {
            musicManager.playSoundEffect(named: "nope")
            guessedLetterColors[letter] = Color.red.opacity(0.29)
            remainingAttempts -= 1
        }

        if remainingAttempts == 0 {
            gameOutcomes = .lost
            showingEndGamePopup = true
        } else if !displayedWords.joined().contains("_") {
            gameOutcomes = .won
            showingEndGamePopup = true
            
        }
    }

    func startNewGame() {
        guessedLetters = []
        remainingAttempts = 8
        showingEnterWordPopup = true
        showingEndGamePopup = false
        wordToGuess = ""
    }
    
}

struct EnterWordPopupView: View {
    @Binding var isPresented: Bool
    @Binding var wordToGuess: String
    @State private var inputText: String = ""
    @Environment(\.dismiss) var dismiss
    @ObservedObject var musicManager = MusicManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter a word or phrase")
                .font(.title)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Enter a word or phrase to have your friend try and guess it!")
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)

            TextField("Word or Phrase", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: inputText) { newValue in
                    inputText = validateInput(newValue.uppercased())
                }
                
            HStack{
                Button("Start Game") {
                    musicManager.playSoundEffect(named: "menu")
                    wordToGuess = inputText
                    isPresented = false
                }
                .padding()
                .fontWeight(.bold)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .frame(maxWidth: .infinity)
                
                Button("Exit") {
                    musicManager.playSoundEffect(named: "back")
                    dismiss()
                }
                .padding()
                .fontWeight(.bold)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(red: 80 / 255, green: 181 / 255, blue: 225 / 255))
        .cornerRadius(20)
        .shadow(radius: 20)
    }
    
    private func validateInput(_ input: String) -> String {
        let allowedCharacters = CharacterSet.uppercaseLetters.union(CharacterSet.whitespaces)
        let filteredInput = input.filter { String($0).rangeOfCharacter(from: allowedCharacters) != nil }
            
        let spaceCount = filteredInput.filter { $0 == " " }.count
        if spaceCount > 5 {
            return String(filteredInput.prefix { $0 != " " || spaceCount <= 5 })
        } else {
            return filteredInput
        }
    }
}

struct EndGamePopupView: View {
    @ObservedObject var musicManager = MusicManager.shared
    let gameOutcome: GameOutcomes
    let wordToGuess: String
    let playAgainAction: () -> Void
    let exitAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(gameOutcome == .won ? "You Got It!" : "Good Try")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)

            Text("The word was \(wordToGuess).")
                .multilineTextAlignment(.center)
                .padding(2)
                .frame(maxWidth: .infinity)
                .foregroundColor(.black)
                .lineLimit(2)
                .minimumScaleFactor(0.5)

            HStack {
                Button(action: {
                    musicManager.playSoundEffect(named: "back")
                    playAgainAction()
                }) {
                    Text("Play Again")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }

                Button(action: {
                    musicManager.playSoundEffect(named: "back")
                    exitAction()
                }) {
                    Text("Exit")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(gameOutcome == .won ? Color(red: 204 / 255, green: 229 / 255, blue: 255 / 255) : Color(red: 255 / 255, green: 120 / 255, blue: 120 / 255))
        .cornerRadius(20)
        .shadow(radius: 20)
    }
}


struct FixedWidthTextView2: View {
    let words: [String]
    let availableWidth: CGFloat
    
    var body: some View {
        let fontSize = calculatefontSize(for: words, availableWidth: availableWidth)
        
        VStack {
            ForEach(words, id: \.self) { word in
                Text(word)
                    .font(Font.custom("'-RonySiswadi-Architect-5", size:fontSize))
                    .fontWeight(.bold)
                    .fixedSize(horizontal: true, vertical: false)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func calculatefontSize(for word: [String], availableWidth: CGFloat) -> CGFloat {
        let baseFontSize: CGFloat = 74
        var maxWidth: CGFloat = availableWidth * 1.8
        if word.count == 1 {
            maxWidth = availableWidth * 0.9
        }
        let longestWord = words.max(by: { $0.widthOfString2(usingFont: UIFont(name: "'-RonySiswadi-Architect-5", size: baseFontSize) ?? UIFont.systemFont(ofSize: baseFontSize)) < $1.widthOfString2(usingFont: UIFont(name: "'-RonySiswadi-Architect-5", size: baseFontSize) ?? UIFont.systemFont(ofSize: baseFontSize)) }) ?? ""
        let textWidth: CGFloat = longestWord.widthOfString2(usingFont: UIFont(name: "'-RonySiswadi-Architect-5", size: baseFontSize) ?? UIFont.systemFont(ofSize: baseFontSize))

        if textWidth > maxWidth {
            return baseFontSize * (maxWidth / textWidth)
        } else {
            return min(baseFontSize, maxWidth / CGFloat(longestWord.count) * 2)
        }
    }
    
    
}

extension String {
    func widthOfString2(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

struct HangmanView2: View {
    let remainingAttempts: Int

    var body: some View {
        ZStack {
            if remainingAttempts <= 8{
                Path { path in // Left Arm
                    path.move(to: CGPoint(x: 175, y: 187))
                    path.addLine(to: CGPoint(x: 35, y: 187))

                }
                .stroke(Color.black, lineWidth: 8)
                
                Path { path in // Left Arm
                    path.move(to: CGPoint(x: 75, y: 187))
                    path.addLine(to: CGPoint(x: 75, y:-42))

                }
                .stroke(Color.black, lineWidth: 5)
                
                Path { path in // Left Arm
                    path.move(to: CGPoint(x: 73, y: -42))
                    path.addLine(to: CGPoint(x: 167, y:-42))

                }
                .stroke(Color.black, lineWidth: 5)
                
                Path { path in // Left Arm
                    path.move(to: CGPoint(x: 165, y: -43))
                    path.addLine(to: CGPoint(x: 165, y:-13))

                }
                .stroke(Color.black, lineWidth: 2)
                
                Path { path in // Left Arm
                    path.move(to: CGPoint(x: 75, y: -7))
                    path.addLine(to: CGPoint(x: 105, y:-42))

                }
                .stroke(Color.black, lineWidth: 4)
                
                
            }
            
            if remainingAttempts <= 7 {
                Circle() // Head
                    .stroke(Color.black, lineWidth: 5)
                    .frame(width: 50, height: 50)
                    .offset(x: 66, y: -137)
            }
            if remainingAttempts <= 6 {
                Rectangle() // Body
                    .fill(Color.black)
                    .frame(width: 5, height: 93)
                    .offset(x: 66, y: -65)
            }
            if remainingAttempts <= 5 {
                Path { path in // Left Arm
                    path.move(to: CGPoint(x: 165, y: 47))
                    path.addLine(to: CGPoint(x: 135, y: 81))

                }
                .stroke(Color.black, lineWidth: 5)
                
                Circle() // Head
                    .stroke(Color.black, lineWidth: 5)
                    .frame(width: 2, height: 50)
                    .offset(x: 35, y: -69)
            }
            if remainingAttempts <= 4 {
                Path { path in // Left Arm
                    path.move(to: CGPoint(x: 165, y: 44))
                    path.addLine(to: CGPoint(x: 197, y: 81))

                }
                .stroke(Color.black, lineWidth: 5)
                
                Circle() // Head
                    .stroke(Color.black, lineWidth: 5)
                    .frame(width: 2, height: 50)
                    .offset(x: 96, y: -70)
            }
            if remainingAttempts <= 3 {
                Path { path in // Left Leg
                    path.move(to: CGPoint(x: 166, y: 129))
                    path.addLine(to: CGPoint(x: 135, y: 160))
                }
                .stroke(Color.black, lineWidth: 5)
            }
            if remainingAttempts <= 2 {
                Path { path in // Right Leg
                    path.move(to: CGPoint(x: 165, y: 128))
                    path.addLine(to: CGPoint(x: 195, y: 160))
                }
                .stroke(Color.black, lineWidth: 5)
            }
            
            if remainingAttempts <= 1 {
                Path { path in // Right Leg
                    path.move(to: CGPoint(x: 170, y: 14))
                    path.addLine(to: CGPoint(x: 181, y: 2))
                }
                .stroke(Color.black, lineWidth: 3)
                
                Path { path in // Right Leg
                    path.move(to: CGPoint(x: 181, y: 14))
                    path.addLine(to: CGPoint(x: 170, y: 2))
                }
                .stroke(Color.black, lineWidth: 3)
                
                Path { path in // Right Leg
                    path.move(to: CGPoint(x: 153, y: 14))
                    path.addLine(to: CGPoint(x: 164, y: 2))
                }
                .stroke(Color.black, lineWidth: 3)
                
                Path { path in // Right Leg
                    path.move(to: CGPoint(x: 164, y: 14))
                    path.addLine(to: CGPoint(x: 153, y: 2))
                }
                .stroke(Color.black, lineWidth: 3)
            }
            
            if remainingAttempts == 0 {
                Path { path in // Right Leg
                    path.move(to: CGPoint(x: 154, y: 28))
                    let controlPoint1 = CGPoint(x: 160, y: 20)
                    let controlPoint2 = CGPoint(x: 175, y: 20)
                    let endPoint = CGPoint(x:180, y:28)
                    path.addCurve(to: endPoint, control1: controlPoint1, control2: controlPoint2)
                }
                .stroke(Color.black, lineWidth: 3)
                
                Path { path in // Right Leg
                    path.move(to: CGPoint(x: 164, y: 24))
                    let controlPoint1 = CGPoint(x: 165, y: 38)
                    let controlPoint2 = CGPoint(x: 174, y: 35)
                    let endPoint = CGPoint(x:172, y:25)
                    path.addCurve(to: endPoint, control1: controlPoint1, control2: controlPoint2)
                }
                .stroke(Color(red: 179 / 255, green: 76 / 255, blue: 73 / 255), lineWidth: 5)
                
                Path { path in // Right Leg
                    path.move(to: CGPoint(x: 168, y: 24))
                    path.addLine(to: CGPoint(x: 168, y: 32))
                }
                .stroke(Color(red: 179 / 255, green: 76 / 255, blue: 73 / 255), lineWidth: 7)
                
                
                Path { path in // Right Leg
                    path.move(to: CGPoint(x: 162, y: 26))
                    let controlPoint1 = CGPoint(x: 165, y: 23)
                    let controlPoint2 = CGPoint(x: 174, y: 26)
                    let endPoint = CGPoint(x:175, y:27)
                    path.addCurve(to: endPoint, control1: controlPoint1, control2: controlPoint2)
                }
                .stroke(Color(red: 179 / 255, green: 76 / 255, blue: 73 / 255), lineWidth: 3)
                
                
                
            }
        }
    }
}




