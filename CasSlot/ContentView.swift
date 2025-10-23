import SwiftUI

class MainViewModel: ObservableObject {
    @Published var userData: UserData
    @Published var games: [Game] = [
        Game(id: 1, title: "Number Slots", description: "Classic number slots game.", unlockScore: 0, isUnlocked: true),
        Game(id: 2, title: "Color Spin", description: "Spin the colorful wheel.", unlockScore: 0, isUnlocked: true),
        Game(id: 3, title: "Lucky Lines", description: "Match symbols on lines.", unlockScore: 0, isUnlocked: true),
        Game(id: 4, title: "Coin Toss", description: "Heads or tails with thrilling wins.", unlockScore: 50000, isUnlocked: false),
        Game(id: 5, title: "Number Guess", description: "Guess the number and win.", unlockScore: 70000, isUnlocked: false),
        Game(id: 6, title: "Simple Match", description: "Match symbols and collect rewards.", unlockScore: 90000, isUnlocked: false),
        Game(id: 7, title: "Plinko Drop", description: "Drop the ball and win big prizes.", unlockScore: 110000, isUnlocked: false),
        Game(id: 8, title: "Spin Wheel Deluxe", description: "Enhanced spinning wheel bonus game.", unlockScore: 130000, isUnlocked: false),
        Game(id: 9, title: "Jackpot Madness", description: "Chance to hit the jackpot.", unlockScore: 150000, isUnlocked: false),
        Game(id: 10, title: "Mystery Box", description: "Unlock surprises and bonuses.", unlockScore: 170000, isUnlocked: false),
    ]
    
    init() {
        self.userData = PersistenceManager.shared.loadUserData()
        updateGameUnlocks()
    }
    
    func updateGameUnlocks() {
        for index in games.indices {
            if userData.points >= games[index].unlockScore && !games[index].isUnlocked {
                games[index].isUnlocked = true
                if !userData.unlockedGameIDs.contains(games[index].id) {
                    userData.unlockedGameIDs.append(games[index].id)
                }
            }
        }
        PersistenceManager.shared.saveUserData(userData)
    }
    
    func addPoints(_ points: Int) {
        userData.points += points
        updateGameUnlocks()
    }
    
    func addCoins(_ coins: Int) {
        userData.coins += coins
        PersistenceManager.shared.saveUserData(userData)
    }
}

import SwiftUI

struct MainHubView: View {
    @StateObject var viewModel = MainViewModel()
    
    let buttonTitles = ["Games", "Shop", "Achievements", "Daily Reward"]
    
    var buttonDestinations: [AnyView] {
        [
            AnyView(GamesListView(mainViewModel: viewModel)),
            AnyView(ShopView(mainViewModel: viewModel)),
            AnyView(AchievementsView(mainViewModel: viewModel)),
            AnyView(DailyRewardView(mainViewModel: viewModel))
        ]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Фон — красивый линейный градиент
                LinearGradient(
                    colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Статистика по очкам и монетам
                    HStack {
                        Text("Points: \(viewModel.userData.points)")
                        Spacer()
                        Text("Coins: \(viewModel.userData.coins)")
                    }
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    
                    // Кнопки навигации одномерного размера
                    ForEach(0..<buttonTitles.count, id: \.self) { index in
                        NavigationLink(destination: buttonDestinations[index]) {
                            Text(buttonTitles[index])
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white.opacity(0.25))
                                .foregroundColor(.white)
                                .font(.title2.bold())
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal, 40)
                    }
                    
                    // Заблокированные игры
                    Text("Locked Games")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 25) {
                            ForEach(viewModel.games.filter { !$0.isUnlocked }) { game in
                                VStack(spacing: 12) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 44))
                                        .foregroundColor(.white.opacity(0.8))
                                    Text(game.title)
                                        .foregroundColor(.white)
                                        .font(.headline)
                                    Text("Unlock at \(game.unlockScore) points")
                                        .foregroundColor(.white.opacity(0.7))
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(14)
                                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 3)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Arcade Fortune")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


#Preview {
    MainHubView()
}

import SwiftUI

import SwiftUI

struct GamesListView: View {
    @ObservedObject var mainViewModel: MainViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            List {
                ForEach(mainViewModel.games) { game in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(game.title)
                                .font(.headline)
                                .foregroundColor(.white)
                            if !game.isUnlocked {
                                Text("Unlocks at \(game.unlockScore) points")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        Spacer()
                        if game.isUnlocked {
                            NavigationLink(destination: destination(for: game)) {
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.title2)
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Games")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func destination(for game: Game) -> some View {
        switch game.id {
        case 1:
            GameDetailView(game: game, mainViewModel: mainViewModel)
        case 2:
            ColorSpinGameView(mainViewModel: mainViewModel)
        case 3:
            LuckyLinesView(mainViewModel: mainViewModel)
        default:
            Text("Coming soon")
                .font(.largeTitle)
                .foregroundColor(.white)
                .navigationTitle(game.title)
        }
    }
}

import SwiftUI

class LuckyLinesViewModel: ObservableObject {
    @Published var gridSymbols: [[Int]] = Array(repeating: Array(repeating: 0, count: 3), count: 3)
    @Published var isSpinning = false
    @Published var lastWin: Int = 0
    
    private let symbolCount = 6 // количество уникальных символов
    private let mainViewModel: MainViewModel
    
    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
        resetGrid()
    }
    
    func resetGrid() {
        gridSymbols = Array(repeating: Array(repeating: Int.random(in: 1...symbolCount), count: 3), count: 3)
        lastWin = 0
    }
    
    func spin() {
        guard !isSpinning else { return }
        isSpinning = true
        lastWin = 0
        
        // Анимация "вращения" заполняет сетку случайными символами с задержкой
        var spinCount = 15
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
            self.gridSymbols = self.gridSymbols.map { row in
                row.map { _ in Int.random(in: 1...self.symbolCount) }
            }
            spinCount -= 1
            if spinCount <= 0 {
                timer.invalidate()
                self.isSpinning = false
                self.evaluateWin()
            }
        }
    }
    
    func evaluateWin() {
        // Проверяем горизонтальные линии
        lastWin = 0
        for row in gridSymbols {
            if Set(row).count == 1 { // Если в строке все символы одинаковы
                lastWin += 100
            }
        }
        // Можно добавить проверку диагоналей, вертикалей и т.д.
        if lastWin > 0 {
            mainViewModel.addPoints(lastWin)
            mainViewModel.addCoins(lastWin / 10)
        }
    }
}

struct LuckyLinesView: View {
    @ObservedObject var mainViewModel: MainViewModel
    @StateObject private var viewModel: LuckyLinesViewModel
    
    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
        _viewModel = StateObject(wrappedValue: LuckyLinesViewModel(mainViewModel: mainViewModel))
    }
    
    let symbolNames = ["star.fill", "circle.fill", "diamond.fill", "hexagon.fill", "heart.fill", "sparkles"]
    let symbolColors: [Color] = [.yellow, .blue, .purple, .green, .red, .orange]
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.9)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Lucky Lines")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                VStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 20) {
                            ForEach(0..<3, id: \.self) { col in
                                let symbolIndex = viewModel.gridSymbols[row][col] - 1
                                Image(systemName: symbolNames[symbolIndex])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(symbolColors[symbolIndex])
                                    .padding(8)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                
                if viewModel.lastWin > 0 && !viewModel.isSpinning {
                    Text("You won \(viewModel.lastWin) points!")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                        .transition(.opacity)
                }
                
                Button(action: {
                    viewModel.spin()
                }) {
                    Text(viewModel.isSpinning ? "Spinning..." : "Spin")
                        .bold()
                        .frame(minWidth: 150, minHeight: 45)
                        .background(viewModel.isSpinning ? Color.gray : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: .orange.opacity(0.6), radius: 8, x: 0, y: 4)
                }
                .disabled(viewModel.isSpinning)
                
                Spacer()
            }
            .padding()
        }
    }
}

import SwiftUI

struct ColorSpinGameView: View {
    @ObservedObject var mainViewModel: MainViewModel
    @State private var selectedColorIndex: Int? = nil
    @State private var currentColorIndex: Int = 0
    @State private var isSpinning = false
    @State private var hasSpun = false
    @State private var initialSelection: Int? = nil  // запоминаем выбор перед спином

    private let colors: [Color] = [.red, .green, .blue, .yellow, .purple, .orange]
    private let colorNames = ["Red", "Green", "Blue", "Yellow", "Purple", "Orange"]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.9)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Color Spin")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                Picker("Select a color", selection: $selectedColorIndex) {
                    ForEach(colors.indices, id: \.self) { index in
                        Text(colorNames[index])
                            .tag(Optional(index))
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .disabled(isSpinning) // блокируем выбор, пока крутится

                Circle()
                    .fill(colors[currentColorIndex])
                    .frame(width: 150, height: 150)
                    .overlay(Circle().stroke(Color.white.opacity(0.7), lineWidth: 5))
                    .shadow(radius: 8)
                    .animation(.easeInOut(duration: 0.15), value: currentColorIndex)

                Button(action: spin) {
                    Text(isSpinning ? "Spinning..." : "Spin")
                        .bold()
                        .frame(width: 150, height: 50)
                        .background(isSpinning ? Color.gray : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .shadow(color: .orange.opacity(0.6), radius: 8, x: 0, y: 4)
                }
                .disabled(isSpinning || selectedColorIndex == nil)

                // показываем сообщение только если цвет совпал с тем, который был выбран до спина
                if !isSpinning, hasSpun, let selected = initialSelection, currentColorIndex == selected {
                    Text("You won 200 points!")
                        .font(.title3.bold())
                        .foregroundColor(.green)
                        .transition(.opacity)
                }

                Spacer()
            }
            .padding()
        }
    }

    func spin() {
        guard !isSpinning, let selected = selectedColorIndex else { return }
        isSpinning = true
        hasSpun = true
        initialSelection = selected // сохраняем выбор именно перед вращением

        var spinCount = 20
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            currentColorIndex = Int.random(in: 0..<colors.count)
            spinCount -= 1
            if spinCount <= 0 {
                timer.invalidate()
                isSpinning = false

                // немного увеличим шанс победы
                if currentColorIndex != selected && Int.random(in: 1...100) <= 35 {
                    currentColorIndex = selected
                }

                if currentColorIndex == selected {
                    let reward = 200
                    mainViewModel.addPoints(reward)
                    mainViewModel.addCoins(reward / 10)
                }
            }
        }
    }
}

import SwiftUI

struct ShopItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let price: Int
}

struct ShopView: View {
    @ObservedObject var mainViewModel: MainViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Список бонусов в магазине
    private let shopItems: [ShopItem] = [
        ShopItem(title: "2x Сhance", description: "Double chance for 10 min", price: 5000),
        ShopItem(title: "Unlock Skin", description: "Change game theme", price: 6000),
        ShopItem(title: "Jackpot Boost", description: "Increase jackpot chance", price: 8000),
        ShopItem(title: "Lucky Charm", description: "Slightly improve odds", price: 10000),
        ShopItem(title: "Mega Bonus", description: "Get bonus multipliers", price: 12500),
        ShopItem(title: "Secret Game Key", description: "Unlock hidden game", price: 100000)
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
                .ignoresSafeArea()
            
            List {
                ForEach(shopItems) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(item.description)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Text("\(item.price) coins")
                            .font(.subheadline)
                            .foregroundColor(.yellow)
                            .bold()
                        
                        Button(action: {
                            buyItem(item)
                        }) {
                            Text("Buy")
                                .font(.subheadline)
                                .frame(width: 50, height: 30)
                                .background(mainViewModel.userData.coins >= item.price ? Color.green : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .alert(isPresented: $showAlert) {
                         Alert(title: Text("Insufficient Funds"),
                               message: Text(alertMessage),
                               dismissButton: .default(Text("OK")))
                     }
        }
        .navigationTitle("Shop")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func buyItem(_ item: ShopItem) {
        if mainViewModel.userData.coins >= item.price {
            mainViewModel.userData.coins -= item.price
            mainViewModel.addCoins(0) // сохранить изменения
            // Реализация бонуса по item тут
        } else {
            alertMessage = "You don't have enough coins to buy \"\(item.title)\"."
            DispatchQueue.main.async {
                showAlert = true
            }
        }
    }
}


import SwiftUI

struct AchievementsView: View {
    @ObservedObject var mainViewModel: MainViewModel
    
    // Для демонстрации статичные данные достижений с учетом открытия из модели
    var achievements: [Achievement] {
        [
            Achievement(id: 1, title: "First Win", description: "Earn 500 points", rewardPoints: 500, isUnlocked: mainViewModel.userData.points >= 500),
            Achievement(id: 2, title: "Played 10 Games", description: "Play 10 times", rewardPoints: 1000, isUnlocked: mainViewModel.userData.points >= 1000),
            Achievement(id: 3, title: "Reach 50000 Points", description: "Accumulate 50000 points", rewardPoints: 5000, isUnlocked: mainViewModel.userData.points >= 50000),
        ]
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            List {
                ForEach(achievements) { achievement in
                    HStack {
                        Image(systemName: achievement.isUnlocked ? "checkmark.seal.fill" : "lock.fill")
                            .foregroundColor(achievement.isUnlocked ? .green : .black.opacity(0.7))
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(achievement.title)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(achievement.description)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Text("+\(achievement.rewardPoints)")
                            .font(.title3)
                            .bold()
                            .foregroundColor(achievement.isUnlocked ? .yellow : .black.opacity(0.7))
                    }
                    .padding(.vertical, 6)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }
}


import SwiftUI

struct DailyRewardView: View {
    @ObservedObject var mainViewModel: MainViewModel
    @State private var lastClaim: Date? = nil
    @State private var canClaim = false
    @State private var timeRemaining: TimeInterval = 0
    
    // Ежедневная награда фиксирована
    let rewardAmount = 100
    
    // Таймер для обновления countdown каждую секунду
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Daily Reward")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                Text("You will receive \(rewardAmount) coins")
                    .font(.title3.weight(.medium))
                    .foregroundColor(.white.opacity(0.85))
                
                Button(action: claimReward) {
                    Text(canClaim ? "Claim Reward" : "Already Claimed")
                        .bold()
                        .frame(minWidth: 180, minHeight: 50)
                        .background(canClaim ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .disabled(!canClaim)
                
                if !canClaim {
                    VStack(spacing: 8) {
                        Text("Next reward in")
                            .foregroundColor(.white.opacity(0.8))
                        Text(timeString(from: timeRemaining))
                            .font(.system(size: 38, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear(perform: setup)
        .onReceive(timer) { _ in
            updateTimer()
        }
        .navigationTitle("Daily Reward")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Настройка начального состояния
    private func setup() {
        loadLastClaimDate()
        updateCanClaim()
        updateTimer()
    }
    
    private func loadLastClaimDate() {
        lastClaim = UserDefaults.standard.object(forKey: "lastDailyClaim") as? Date
    }
    
    private func updateCanClaim() {
        if let last = lastClaim {
            canClaim = !Calendar.current.isDateInToday(last)
        } else {
            canClaim = true
        }
    }
    
    private func updateTimer() {
        guard let last = lastClaim, !canClaim else {
            timeRemaining = 0
            return
        }
        let nextClaimDate = Calendar.current.date(byAdding: .day, value: 1, to: last)!
        timeRemaining = max(0, nextClaimDate.timeIntervalSince(Date()))
        if timeRemaining <= 0 {
            canClaim = true
        }
    }
    
    private func claimReward() {
        guard canClaim else { return }
        
        mainViewModel.addCoins(rewardAmount)
        lastClaim = Date()
        UserDefaults.standard.set(lastClaim, forKey: "lastDailyClaim")
        canClaim = false
        timeRemaining = 24 * 3600
    }
    
    // Форматирование таймера в "ЧЧ:ММ:СС"
    private func timeString(from interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = (totalSeconds % 60)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}


import SwiftUI
import Combine

class GameDetailViewModel: ObservableObject {
    @Published var reels: [Int] = [1, 1, 1]
    @Published var isSpinning: Bool = false
    @Published var lastWin: Int = 0
    
    private var spinCancellable: AnyCancellable?
    private let mainViewModel: MainViewModel
    
    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    func spin() {
        guard !isSpinning else { return }
        isSpinning = true
        lastWin = 0
        
        var spinsLeft = 15
        spinCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.reels = (0..<3).map { _ in Int.random(in: 1...9) }
                spinsLeft -= 1
                if spinsLeft <= 0 {
                    self.spinCancellable?.cancel()
                    self.isSpinning = false
                    self.evaluateWin()
                    
                    mainViewModel.addPoints(lastWin)
                    mainViewModel.addCoins(lastWin / 10)
                } else {
                    lastWin = 0
                }
            }
    }
    
    func evaluateWin() {
        
        let lucky = Bool.random()

        if Int.random(in: 1...100) <= 20 || lucky {
            let val = Int.random(in: 1...9)
            reels = [val, val, val]
            lastWin = Int.random(in: 50...150)
        } else {
            lastWin = 0
        }
    }
}

import SwiftUI

struct GameDetailView: View {
    let game: Game
    @ObservedObject var mainViewModel: MainViewModel
    @StateObject private var viewModel: GameDetailViewModel
    
    init(game: Game, mainViewModel: MainViewModel) {
        self.game = game
        self.mainViewModel = mainViewModel
        _viewModel = StateObject(wrappedValue: GameDetailViewModel(mainViewModel: mainViewModel))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text(game.title)
                    .font(.largeTitle)
                    .bold()
                
                HStack(spacing: 15) {
                    ForEach(0..<3) { i in
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 60, height: 90)
                            Text("\(viewModel.reels[i])")
                                .font(.system(size: 40, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .scaleEffect(viewModel.lastWin > 0 ? 1.2 : 1.0)
                                .animation(.spring(), value: viewModel.lastWin)
                        }
                    }
                }
                .frame(height: 100)
                
                if viewModel.lastWin > 0 {
                    Text("You won \(viewModel.lastWin) points!")
                        .font(.title3)
                        .foregroundColor(.black)
                        .transition(.opacity)
                }
                
                Button(action: { viewModel.spin() }) {
                    Text(viewModel.isSpinning ? "Spinning..." : "Spin")
                        .bold()
                        .frame(minWidth: 150, minHeight: 45)
                        .background(viewModel.isSpinning ? Color.gray : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .disabled(viewModel.isSpinning)
                
                Spacer()
            }
            .padding()
        }
    }
}
