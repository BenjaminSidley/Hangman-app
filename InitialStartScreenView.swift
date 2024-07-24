import SwiftUI

struct InitialStartScreenView: View {
    @State private var showSettings = false
    @ObservedObject var musicManager = MusicManager.shared
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Image("HANGMAN-3-2")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                    Button(action: {
                        musicManager.playSoundEffect(named: "menu")
                        path.append("StartScreen")
                    }) {
                        Text("Level Selection")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color(red: 80 / 255, green: 181 / 255, blue: 225 / 255))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 20)
                    
                    Button(action: {
                        musicManager.playSoundEffect(named: "menu")
                        path.append("LocalTwoPlayerView")
                    }) {
                        Text("Local 2 Player")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color(red: 103 / 255, green: 214 / 255, blue: 116 / 255))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 20)

                    Button(action: {
                        musicManager.playSoundEffect(named: "menu")
                        showSettings.toggle()
                    }) {
                        Text("Settings")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color(red: 178 / 255, green: 182 / 255, blue: 184 / 255))
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .padding()
                .offset(x: 0, y: -80)

                if showSettings {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    SettingsPopupView(isPresented: $showSettings)
                        .frame(width: 300, height: 300)
                        .transition(.scale)
                        .zIndex(1)
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "StartScreen" {
                    StartScreenView(path: $path)
                } else if value == "LocalTwoPlayerView" {
                    LocalTwoPlayerView()
                }
            }
        }
        .navigationBarHidden(true)
    }
}


