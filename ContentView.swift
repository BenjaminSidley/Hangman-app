//
//  ContentView.swift
//  Hangman
//
//  Created by Benjamin Sidley on 5/27/24.
//
import SwiftUI

enum GameOutcome {
    case none
    case won
    case lost
}

struct ContentView: View {
    @ObservedObject var musicManager = MusicManager.shared
    @State private var level: Int
    @State private var wordToGuess: String
    @State private var guessedLetters: Set<Character> = []
    @State private var remainingAttempts = 8
    @State private var showingPopup = false
    @State private var popupTitle = ""
    @State private var popupMessage = ""
    @State private var guessedLetterColors: [Character: Color] = [:]
    @State private var gameOutcome: GameOutcome = .none
    @State private var showSettings = false
    
    @Binding var highestLevelUnlocked: Int
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject private var wordProvider = WordProvider()
    
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
    
    
    
    init(level: Int, highestLevelUnlocked: Binding<Int>) {
        self._level = State(initialValue: level)
        self._highestLevelUnlocked = highestLevelUnlocked
        self._wordToGuess = State(initialValue: "")
    }
    
    var body: some View {
        ZStack {
            
            
            
            Image("background_level_\(level%10)")
                .resizable()
            
                .edgesIgnoringSafeArea(.all)
            
            
            
            // Hangman figure
            HangmanView(remainingAttempts: remainingAttempts)
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
                    .offset(x: 20, y: 10)

                    Spacer()

                    Text("Level \(level)")
                        .font(.title)
                        .foregroundColor((level%10 == 5 || level%10 == 4 || level%10 == 6 || level%10 == 7 || level%10 == 8 || level%10 == 0 ? .black : .white))
                        .offset(x: 65, y: 10)

                    Spacer()

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
                    .offset(x: -20, y: 10)
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
                    
                    .offset(x: -60,y: 50)
                }
                
                GeometryReader { geometry in
                    VStack {
                        Spacer(minLength: geometry.size.height * 0.7)
                        FixedWidthTextView(words: displayedWords, availableWidth: geometry.size.width, level: level)
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
            
            
            if showingPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                ZStack{
                    if gameOutcome == .lost {
                        LosePopupView(
                            title: "Good Try",
                            message: "The word was \(wordToGuess).",
                            homeButtonAction: {
                                self.presentationMode.wrappedValue.dismiss()
                            },
                            restartButtonAction: {
                                self.showingPopup = false
                                self.startNewGame()
                            }
                        )
                        .transition(.scale)
                    } else if gameOutcome == .won {
                        WinPopupView(
                            title: "Nice Job!",
                            message: "Next Level Unlocked!",
                            homeButtonAction: {
                                self.presentationMode.wrappedValue.dismiss()
                            },
                            restartButtonAction: {
                                self.showingPopup = false
                                self.startNewGame()
                            },
                            nextLevelButtonAction: {
                                self.showingPopup = false
                                self.goToNextLevel()
                            }
                        )
                        .transition(.scale)
                    }
                    
                }
                
                
                    
            }
            if showSettings {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                                
                SettingsPopupView(isPresented: $showSettings)
                    .frame(width: 300, height: 300)
                    .transition(.scale)
                    .zIndex(1)
            }
                
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            wordToGuess = wordProvider.getRandomWord()
        }
        
        
    }

    var displayedWords: [String] {
        let words = wordToGuess.split(separator: " ").map { String($0) }
        return words.map { word in
            var display = ""
            for letter in word {
                if guessedLetters.contains(letter) || letter == "-" || letter == "'" || letter == "?" || letter == "!" || letter == "’"{
                    display += "\(letter) "
                } else {
                    display += "_ "
                }
            }
            return display.trimmingCharacters(in: .whitespaces)
        }
    }

    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

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
            popupTitle = "Game Over"
            popupMessage = "The word was \(wordToGuess)."
            gameOutcome = .lost
            showingPopup = true
        } else if !displayedWords.joined().contains("_") {
            popupTitle = "Congratulations!"
            popupMessage = "You've guessed the word."
            gameOutcome = .won
            showingPopup = true
            
            if level == highestLevelUnlocked {
                highestLevelUnlocked += 1
                UserDefaults.standard.set(highestLevelUnlocked, forKey: "highestLevelUnlocked")
            }
        }
    }

    func startNewGame() {
        guessedLetters = []
        remainingAttempts = 8
        wordToGuess = wordProvider.getRandomWord()
    }
    
    func goToNextLevel() {
            // Increment the level
        level += 1

            // Check if the new level exceeds the highest unlocked level
        if level > highestLevelUnlocked {
            highestLevelUnlocked = level
            UserDefaults.standard.set(highestLevelUnlocked, forKey: "highestLevelUnlocked")
        }

            // Reset the game state for the new level
        guessedLetters = []
        remainingAttempts = 8
        wordToGuess = wordProvider.getRandomWord()
        }
}

struct FixedWidthTextView: View {
    let words: [String]
    let availableWidth: CGFloat
    let level: Int
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
                    
                    .foregroundColor(level%10 == 5 || level%10 == 4 || level%10 == 6 || level%10 == 7 || level%10 == 8 || level%10 == 0 ? .black : .white)
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
        let longestWord = words.max(by: { $0.widthOfString(usingFont: UIFont(name: "'-RonySiswadi-Architect-5", size: baseFontSize) ?? UIFont.systemFont(ofSize: baseFontSize)) < $1.widthOfString(usingFont: UIFont(name: "'-RonySiswadi-Architect-5", size: baseFontSize) ?? UIFont.systemFont(ofSize: baseFontSize)) }) ?? ""
        let textWidth: CGFloat = longestWord.widthOfString(usingFont: UIFont(name: "'-RonySiswadi-Architect-5", size: baseFontSize) ?? UIFont.systemFont(ofSize: baseFontSize))

        if textWidth > maxWidth {
            return baseFontSize * (maxWidth / textWidth)
        } else {
            return min(baseFontSize, maxWidth / CGFloat(longestWord.count) * 2)
        }
    }
    
    
}

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

struct HangmanView: View {
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

struct WinPopupView: View {
    @ObservedObject var musicManager = MusicManager.shared
    var title: String
    var message: String
    var homeButtonAction: () -> Void
    var restartButtonAction: () -> Void
    var nextLevelButtonAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(message)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.black)
            
            HStack {
                Button(action: {
                    musicManager.playSoundEffect(named: "back") 
                    homeButtonAction()
                }) {
                    Text("Level\nSelection")
                        .foregroundColor(.white)
                        .frame(width: 100, height: 80)
                        .background(Color(red: 0 / 255, green: 0 / 255, blue: 253 / 255))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    musicManager.playSoundEffect(named: "menu")
                    restartButtonAction()
                }) {
                    Text("Try a\n new word!")
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(width: 100, height: 80)
                        .background(Color(red: 255 / 255, green: 51 / 255, blue: 51 / 255))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    musicManager.playSoundEffect(named: "menu")
                    nextLevelButtonAction()
                }) {
                    Text("Next\nLevel")
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(width: 100, height: 80)
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }

        }
        .padding()
        .background(Color(red: 204 / 255, green: 229 / 255, blue: 255 / 255))
        .cornerRadius(20)
        .shadow(radius: 20)
        .frame(width: 300, height: 400)
    }
}

struct LosePopupView: View {
    @ObservedObject var musicManager = MusicManager.shared
    var title: String
    var message: String
    var homeButtonAction: () -> Void
    var restartButtonAction: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(message)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.black)
            
            HStack {
                Button(action: {
                    musicManager.playSoundEffect(named: "back") // Replace with your sound file name
                    homeButtonAction()
                }) {
                    Text("Level\nSelection")
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 120, height: 80)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    musicManager.playSoundEffect(named: "menu") // Replace with your sound file name
                    restartButtonAction()
                }) {
                    Text("Try\nAgain!")
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(width: 120, height: 80)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                
                
                
            }
        }
        .padding()
        .background(Color(red: 255 / 255, green: 120 / 255, blue: 120 / 255))
        .cornerRadius(20)
        .shadow(radius: 20)
        .frame(width: 300, height: 400)
    }
}




