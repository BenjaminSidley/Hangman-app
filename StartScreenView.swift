import SwiftUI

struct StartScreenView: View {
    @ObservedObject var musicManager = MusicManager.shared
    @State private var highestLevelUnlocked: Int = UserDefaults.standard.integer(forKey: "highestLevelUnlocked")
    @State private var selectedTab = 0
    @State private var showSettings = false
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            Image("HANGMAN-3-2")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Button(action: {
                        musicManager.playSoundEffect(named: "back")
                        path.removeLast()
                    }) {
                        Image(systemName: "arrow.backward")
                            .resizable()
                            .frame(width: 27, height: 27)
                            .padding(10)
                            .background(Color(red: 80 / 255, green: 181 / 255, blue: 225 / 255))
                            .foregroundColor(.black)
                            .cornerRadius(15)
                    }
                    .padding(.leading)
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
                    .offset(x: -20, y: 0)
                }

                Spacer(minLength: 25)
                TabView(selection: $selectedTab) {
                    LevelGridView(levelRange: 1..<51, highestLevelUnlocked: $highestLevelUnlocked)
                        .tag(0)

                    LevelGridView(levelRange: 51..<101, highestLevelUnlocked: $highestLevelUnlocked)
                        .tag(1)

                    LevelGridView(levelRange: 101..<151, highestLevelUnlocked: $highestLevelUnlocked)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onAppear {
                    if UserDefaults.standard.integer(forKey: "highestLevelUnlocked") == 0 {
                        UserDefaults.standard.set(1, forKey: "highestLevelUnlocked")
                        highestLevelUnlocked = 1
                    }
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(index == selectedTab ? .blue : .gray)
                    }
                }
                .padding(.top, 8)
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
    }

    struct LevelGridView: View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        let levelRange: Range<Int>
        @Binding var highestLevelUnlocked: Int

        var body: some View {
            VStack {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(levelRange, id: \.self) { level in
                        NavigationLink(destination: ContentView(level: level, highestLevelUnlocked: $highestLevelUnlocked)) {
                            Text("\(level)")
                                .font(.title2)
                                .frame(width: 45, height: 35)
                                .padding(5)
                                .background(level <= highestLevelUnlocked ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.bottom, 10)
                        }
                        .disabled(level > highestLevelUnlocked)
                    }
                }
                .padding()
                Spacer()
            }
        }
    }

   
}

