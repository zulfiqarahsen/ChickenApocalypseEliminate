


import SwiftUI
import AVFoundation

// MARK: - Enhanced Data Models with Visual Effects
struct JungleChicken: Identifiable {
    let id = UUID()
    let type: Int
    var position: CGPoint
    var isAlive: Bool = true
    var isDying: Bool = false
    
    var imageName: String {
        return "chicken\(type)"
    }
}

struct Bomb: Identifiable {
    let id = UUID()
    var position: CGPoint
    var isBlinking: Bool = true
    var blastRadius: CGFloat
    var bombType: BombType
    var points: Int
    var bombNumber: Int // Added bomb numbering
    
    enum BombType: String, CaseIterable {
        case handGrenade = "Hand Grenade"
        case dynamite = "Dynamite"
        case tnt = "TNT"
        case c4 = "C4 Explosive"
        case hydrogen = "Hydrogen Bomb"
        case nuclear = "Nuclear Bomb"
        case plasma = "Plasma Bomb"
        
        var imageName: String {
            switch self {
            case .handGrenade: return "grenade"
            case .dynamite: return "dynamite"
            case .tnt: return "tnt"
            case .c4: return "c4"
            case .hydrogen: return "hydrogen"
            case .nuclear: return "nuclear"
            case .plasma: return "plasma"
            }
        }
        
        var radius: CGFloat {
            switch self {
            case .handGrenade: return 60
            case .dynamite: return 80
            case .tnt: return 100
            case .c4: return 120
            case .hydrogen: return 150
            case .nuclear: return 180
            case .plasma: return 200
            }
        }
        
        var pointValue: Int {
            switch self {
            case .handGrenade: return 10
            case .dynamite: return 20
            case .tnt: return 30
            case .c4: return 50
            case .hydrogen: return 80
            case .nuclear: return 120
            case .plasma: return 150
            }
        }
        
        var explosionColor: Color {
            switch self {
            case .handGrenade: return .orange
            case .dynamite: return .red
            case .tnt: return .yellow
            case .c4: return .blue
            case .hydrogen: return .green
            case .nuclear: return .purple
            case .plasma: return .pink
            }
        }
    }
}

struct ExplosionEffect: Identifiable {
    let id = UUID()
    var position: CGPoint
    var progress: CGFloat = 0.0
    var bombType: Bomb.BombType
    var maxRadius: CGFloat
}

struct SmokeEffect: Identifiable {
    let id = UUID()
    var position: CGPoint
    var progress: CGFloat = 0.0
    var opacity: Double = 1.0
}

struct ToastMessage: Identifiable {
    let id = UUID()
    var message: String
    var position: CGPoint
    var opacity: Double = 1.0
    var scale: CGFloat = 0.8
}

struct LevelConfig {
    let level: Int
    let bombType: Bomb.BombType
    let bombCount: Int
    let gameDuration: TimeInterval
    let chickenSpawnRate: TimeInterval
    let chickenSpeed: Double
    
    static func getConfig(for level: Int) -> LevelConfig {
        switch level {
        case 1:
            return LevelConfig(
                level: 1,
                bombType: .handGrenade,
                bombCount: 3,
                gameDuration: 20,
                chickenSpawnRate: 3.0,
                chickenSpeed: 3.0
            )
        case 2:
            return LevelConfig(
                level: 2,
                bombType: .dynamite,
                bombCount: 4,
                gameDuration: 20,
                chickenSpawnRate: 2.5,
                chickenSpeed: 2.5
            )
        case 3:
            return LevelConfig(
                level: 3,
                bombType: .tnt,
                bombCount: 5,
                gameDuration: 20,
                chickenSpawnRate: 2.0,
                chickenSpeed: 2.0
            )
        case 4:
            return LevelConfig(
                level: 4,
                bombType: .c4,
                bombCount: 4,
                gameDuration: 20,
                chickenSpawnRate: 1.5,
                chickenSpeed: 1.8
            )
        case 5:
            return LevelConfig(
                level: 5,
                bombType: .hydrogen,
                bombCount: 3,
                gameDuration: 20,
                chickenSpawnRate: 1.2,
                chickenSpeed: 1.5
            )
        case 6:
            return LevelConfig(
                level: 6,
                bombType: .nuclear,
                bombCount: 2,
                gameDuration: 20,
                chickenSpawnRate: 1.0,
                chickenSpeed: 1.3
            )
        case 7:
            return LevelConfig(
                level: 7,
                bombType: .plasma,
                bombCount: 1,
                gameDuration: 20,
                chickenSpawnRate: 0.8,
                chickenSpeed: 1.0
            )
        default:
            return LevelConfig(
                level: level,
                bombType: .plasma,
                bombCount: 1,
                gameDuration: 20,
                chickenSpawnRate: 0.8,
                chickenSpeed: 1.0
            )
        }
    }
}

// MARK: - Game Statistics Model for UserDefaults
struct GameStatistics: Codable {
    var levelStats: [LevelStat]
    
    struct LevelStat: Codable {
        let level: Int
        let bombType: Bomb.BombType
        let bombsUsed: Int
        let chickensBlasted: Int
        let score: Int
        let date: Date
        
        enum CodingKeys: String, CodingKey {
            case level, bombType, bombsUsed, chickensBlasted, score, date
        }
        
        init(level: Int, bombType: Bomb.BombType, bombsUsed: Int, chickensBlasted: Int, score: Int, date: Date = Date()) {
            self.level = level
            self.bombType = bombType
            self.bombsUsed = bombsUsed
            self.chickensBlasted = chickensBlasted
            self.score = score
            self.date = date
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            level = try container.decode(Int.self, forKey: .level)
            let bombTypeString = try container.decode(String.self, forKey: .bombType)
            bombType = Bomb.BombType(rawValue: bombTypeString) ?? .handGrenade
            bombsUsed = try container.decode(Int.self, forKey: .bombsUsed)
            chickensBlasted = try container.decode(Int.self, forKey: .chickensBlasted)
            score = try container.decode(Int.self, forKey: .score)
            date = try container.decode(Date.self, forKey: .date)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(level, forKey: .level)
            try container.encode(bombType.rawValue, forKey: .bombType)
            try container.encode(bombsUsed, forKey: .bombsUsed)
            try container.encode(chickensBlasted, forKey: .chickensBlasted)
            try container.encode(score, forKey: .score)
            try container.encode(date, forKey: .date)
        }
    }
}

// MARK: - Enhanced Game Manager with Real Effects and UserDefaults
class ChickenBlastGame: ObservableObject {
    @Published var chickens: [JungleChicken] = []
    @Published var bombs: [Bomb] = []
    @Published var explosions: [ExplosionEffect] = []
    @Published var smokeEffects: [SmokeEffect] = []
    @Published var toastMessages: [ToastMessage] = []
    @Published var score = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var gameState: GameState = .mainMenu
    @Published var currentLevel = 1
    @Published var chickensBlastedThisLevel = 0
    @Published var completedLevels: Set<Int> = [1] // Level 1 always unlocked
    @Published var showHowToPlay = false
    @Published var showLeaderboard = false
    
    private var gameTimer: Timer?
    private var chickenSpawnTimer: Timer?
    private var bombBlinkTimer: Timer?
    private var audioPlayer: AVAudioPlayer?
    
    let gameArea = CGRect(x: 0, y: 0, width: 350, height: 500)
    private let statisticsKey = "ChickenBlastStatistics"
    
    public var currentConfig: LevelConfig {
        return LevelConfig.getConfig(for: currentLevel)
    }
    
    // Statistics from UserDefaults
    var gameStatistics: GameStatistics {
        get {
            if let data = UserDefaults.standard.data(forKey: statisticsKey),
               let stats = try? JSONDecoder().decode(GameStatistics.self, from: data) {
                return stats
            }
            return GameStatistics(levelStats: [])
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: statisticsKey)
            }
        }
    }
    
    enum GameState {
        case mainMenu
        case bombPlacement
        case playing
        case levelComplete
        case gameOver
    }
    
    // MARK: - Game Setup
    func setupMainMenu() {
        gameState = .mainMenu
        score = 0
        chickens.removeAll()
        bombs.removeAll()
        explosions.removeAll()
        smokeEffects.removeAll()
        toastMessages.removeAll()
        chickensBlastedThisLevel = 0
        loadCompletedLevels()
    }
    
    private func loadCompletedLevels() {
        if let data = UserDefaults.standard.data(forKey: "completedLevels"),
           let levels = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            completedLevels = levels
        } else {
            completedLevels = [1] // Level 1 always unlocked
        }
    }
    
    private func saveCompletedLevels() {
        if let data = try? JSONEncoder().encode(completedLevels) {
            UserDefaults.standard.set(data, forKey: "completedLevels")
        }
    }
    
    func startLevel(_ level: Int) {
        currentLevel = level
        chickensBlastedThisLevel = 0
        setupBombPlacement()
    }
    
    func setupBombPlacement() {
        gameState = .bombPlacement
        score = 0
        chickens.removeAll()
        bombs.removeAll()
        explosions.removeAll()
        smokeEffects.removeAll()
        toastMessages.removeAll()
        chickensBlastedThisLevel = 0
        
        let config = currentConfig
        
        // Create bombs for current level with numbering
        for i in 0..<config.bombCount {
            let randomPosition = CGPoint(
                x: CGFloat.random(in: 50...300),
                y: CGFloat.random(in: 100...450)
            )
            bombs.append(Bomb(
                position: randomPosition,
                blastRadius: config.bombType.radius,
                bombType: config.bombType,
                points: config.bombType.pointValue,
                bombNumber: i + 1 // Add bomb numbering
            ))
        }
        
        startBombBlinking()
    }
    
    func startGame() {
        gameState = .playing
        timeRemaining = currentConfig.gameDuration
        
        // Start game timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeRemaining -= 1
            if self.timeRemaining <= 0 {
                self.endGame()
            }
        }
        
        // Start chicken spawning
        chickenSpawnTimer = Timer.scheduledTimer(withTimeInterval: currentConfig.chickenSpawnRate, repeats: true) { [weak self] _ in
            self?.spawnChicken()
        }
        
        // Spawn initial chickens
        for _ in 0..<3 {
            spawnChicken()
        }
        
        stopBombBlinking()
    }
    
    private func spawnChicken() {
        let chickenType = Int.random(in: 1...4)
        let randomPosition = CGPoint(
            x: CGFloat.random(in: 30...320),
            y: CGFloat.random(in: 80...470)
        )
        
        let newChicken = JungleChicken(type: chickenType, position: randomPosition)
        chickens.append(newChicken)
        
        // Start slow chicken movement with animation
        startChickenMovement(chicken: newChicken)
    }
    
    private func startChickenMovement(chicken: JungleChicken) {
        let moveDuration = currentConfig.chickenSpeed
        
        Timer.scheduledTimer(withTimeInterval: moveDuration, repeats: true) { [weak self] timer in
            guard let self = self,
                  let index = self.chickens.firstIndex(where: { $0.id == chicken.id }),
                  self.chickens[index].isAlive,
                  !self.chickens[index].isDying,
                  self.gameState == .playing else {
                timer.invalidate()
                return
            }
            
            withAnimation(.easeInOut(duration: moveDuration)) {
                self.chickens[index].position = CGPoint(
                    x: CGFloat.random(in: 30...320),
                    y: CGFloat.random(in: 80...470)
                )
            }
        }
    }
    
    // MARK: - Bomb Functions
    private func startBombBlinking() {
        bombBlinkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            for index in self.bombs.indices {
                self.bombs[index].isBlinking.toggle()
            }
        }
    }
    
    private func stopBombBlinking() {
        bombBlinkTimer?.invalidate()
        bombBlinkTimer = nil
        for index in bombs.indices {
            bombs[index].isBlinking = false
        }
    }
    
    func blastBomb(at index: Int) {
        guard index < bombs.count, gameState == .playing else { return }
        
        let bomb = bombs[index]
        playExplosionSound()
        
        // Create real explosion effect
        createRealExplosionEffect(at: bomb.position, bombType: bomb.bombType)
        
        // Check for chickens in blast radius
        var chickensHit = 0
        var chickenIndicesToRemove: [UUID] = []
        
        for chickenIndex in chickens.indices {
            let chicken = chickens[chickenIndex]
            let distance = hypot(
                chicken.position.x - bomb.position.x,
                chicken.position.y - bomb.position.y
            )
            
            if distance <= bomb.blastRadius && chickens[chickenIndex].isAlive && !chickens[chickenIndex].isDying {
                chickensHit += 1
                chickens[chickenIndex].isDying = true
                chickenIndicesToRemove.append(chicken.id)
                
                // Create toast message for points
                createToastMessage(at: chicken.position, points: bomb.points)
                
                // Create smoke effect for dying chicken
                createSmokeEffect(at: chicken.position)
                
                // Remove chicken after smoke effect with safe indexing
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    guard let self = self else { return }
                    if let currentIndex = self.chickens.firstIndex(where: { $0.id == chicken.id }) {
                        self.chickens.remove(at: currentIndex)
                    }
                }
            }
        }
        
        // Update score and count
        chickensBlastedThisLevel += chickensHit
        score += chickensHit * bomb.points
        
        // Remove bomb after blast
        withAnimation(.spring()) {
            bombs.remove(at: index)
        }
        
        // Check if level complete (no bombs left)
        if bombs.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.completeLevel(chickensBlasted: self.chickensBlastedThisLevel)
            }
        }
    }
    
    private func createRealExplosionEffect(at position: CGPoint, bombType: Bomb.BombType) {
        let explosion = ExplosionEffect(
            position: position,
            bombType: bombType,
            maxRadius: bombType.radius
        )
        explosions.append(explosion)
        
        // Animate explosion
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] timer in
            guard let self = self,
                  let index = self.explosions.firstIndex(where: { $0.id == explosion.id }) else {
                timer.invalidate()
                return
            }
            
            self.explosions[index].progress += 0.05
            
            if self.explosions[index].progress >= 1.0 {
                self.explosions.removeAll { $0.id == explosion.id }
                timer.invalidate()
            }
        }
    }
    
    private func createSmokeEffect(at position: CGPoint) {
        let smoke = SmokeEffect(position: position)
        smokeEffects.append(smoke)
        
        // Animate smoke
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] timer in
            guard let self = self,
                  let index = self.smokeEffects.firstIndex(where: { $0.id == smoke.id }) else {
                timer.invalidate()
                return
            }
            
            self.smokeEffects[index].progress += 0.02
            self.smokeEffects[index].opacity -= 0.01
            
            if self.smokeEffects[index].progress >= 1.0 || self.smokeEffects[index].opacity <= 0 {
                self.smokeEffects.removeAll { $0.id == smoke.id }
                timer.invalidate()
            }
        }
    }
    
    private func createToastMessage(at position: CGPoint, points: Int) {
        let toast = ToastMessage(
            message: "+\(points) Points!",
            position: position
        )
        toastMessages.append(toast)
        
        // Animate toast message
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] timer in
            guard let self = self,
                  let index = self.toastMessages.firstIndex(where: { $0.id == toast.id }) else {
                timer.invalidate()
                return
            }
            
            // Move toast upward
            self.toastMessages[index].position.y -= 1
            self.toastMessages[index].opacity -= 0.01
            self.toastMessages[index].scale += 0.01
            
            if self.toastMessages[index].opacity <= 0 {
                self.toastMessages.removeAll { $0.id == toast.id }
                timer.invalidate()
            }
        }
    }
    
    // MARK: - Game Control
    private func endGame() {
        gameState = .gameOver
        stopAllTimers()
        playGameOverSound()
    }
    
    private func completeLevel(chickensBlasted: Int) {
        gameState = .levelComplete
        stopAllTimers()
        
        // Save level stats to UserDefaults
        let stat = GameStatistics.LevelStat(
            level: currentLevel,
            bombType: currentConfig.bombType,
            bombsUsed: currentConfig.bombCount - bombs.count,
            chickensBlasted: chickensBlasted,
            score: score
        )
        
        var stats = gameStatistics
        // Remove existing stat for this level if any
        stats.levelStats.removeAll { $0.level == currentLevel }
        stats.levelStats.append(stat)
        gameStatistics = stats
        
        // Mark this level as completed and unlock next level
        completedLevels.insert(currentLevel)
        if currentLevel < 7 {
            completedLevels.insert(currentLevel + 1) // Unlock next level
        }
        saveCompletedLevels()
        
        playLevelCompleteSound()
    }
    
    private func stopAllTimers() {
        gameTimer?.invalidate()
        chickenSpawnTimer?.invalidate()
        bombBlinkTimer?.invalidate()
    }
    
    func nextLevel() {
        if currentLevel < 7 {
            currentLevel += 1
            setupBombPlacement()
        } else {
            // Game completed
            gameState = .gameOver
        }
    }
    
    func restartGame() {
        stopAllTimers()
        setupMainMenu()
    }
    
    func backToMainMenu() {
        stopAllTimers()
        setupMainMenu()
    }
    
    // MARK: - Audio
    private func playExplosionSound() {
        guard let url = Bundle.main.url(forResource: "explosion", withExtension: "mp3") else {
            print("Explosion sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing explosion sound: \(error)")
        }
    }
    
    private func playLevelCompleteSound() {
        guard let url = Bundle.main.url(forResource: "level_complete", withExtension: "mp3") else {
            print("Level complete sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing level complete sound: \(error)")
        }
    }
    
    private func playGameOverSound() {
        guard let url = Bundle.main.url(forResource: "game_over", withExtension: "mp3") else {
            print("Game over sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing game over sound: \(error)")
        }
    }
}

// MARK: - Real Explosion Effect View
struct ExplosionEffectView: View {
    let explosion: ExplosionEffect
    
    var body: some View {
        ZStack {
            // Main explosion
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            explosion.bombType.explosionColor,
                            .orange,
                            .red,
                            .black
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: explosion.maxRadius * explosion.progress
                    )
                )
                .frame(
                    width: explosion.maxRadius * 2 * explosion.progress,
                    height: explosion.maxRadius * 2 * explosion.progress
                )
                .opacity(1.0 - explosion.progress)
            
            // Shockwave
            Circle()
                .stroke(explosion.bombType.explosionColor, lineWidth: 3)
                .frame(
                    width: explosion.maxRadius * 2 * explosion.progress * 1.2,
                    height: explosion.maxRadius * 2 * explosion.progress * 1.2
                )
                .opacity(1.0 - explosion.progress)
            
            // Particles
            ForEach(0..<8) { i in
                Circle()
                    .fill(explosion.bombType.explosionColor)
                    .frame(width: 8, height: 8)
                    .offset(
                        x: cos(Double(i) * .pi / 4) * explosion.maxRadius * explosion.progress,
                        y: sin(Double(i) * .pi / 4) * explosion.maxRadius * explosion.progress
                    )
                    .opacity(1.0 - explosion.progress)
            }
        }
        .position(explosion.position)
    }
}

// MARK: - Real Smoke Effect View
struct SmokeEffectView: View {
    let smoke: SmokeEffect
    
    var body: some View {
        ZStack {
            // Smoke puff 1
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.gray, .white, .clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 30 * smoke.progress
                    )
                )
                .frame(
                    width: 60 * smoke.progress,
                    height: 60 * smoke.progress
                )
                .offset(x: -10 * smoke.progress, y: -15 * smoke.progress)
                .opacity(smoke.opacity)
            
            // Smoke puff 2
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.gray, .white, .clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 25 * smoke.progress
                    )
                )
                .frame(
                    width: 50 * smoke.progress,
                    height: 50 * smoke.progress
                )
                .offset(x: 15 * smoke.progress, y: -20 * smoke.progress)
                .opacity(smoke.opacity * 0.8)
            
            // Smoke puff 3
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.gray, .white, .clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 20 * smoke.progress
                    )
                )
                .frame(
                    width: 40 * smoke.progress,
                    height: 40 * smoke.progress
                )
                .offset(x: 5 * smoke.progress, y: -30 * smoke.progress)
                .opacity(smoke.opacity * 0.6)
        }
        .position(smoke.position)
        .blur(radius: 5)
    }
}

// MARK: - Toast Message View
struct ToastMessageView: View {
    let toast: ToastMessage
    
    var body: some View {
        Text(toast.message)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.orange, .red]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
            .scaleEffect(toast.scale)
            .opacity(toast.opacity)
            .position(toast.position)
    }
}

// MARK: - Background Views
struct JungleBackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.3, blue: 0.1),
                Color(red: 0.2, green: 0.5, blue: 0.2),
                Color(red: 0.1, green: 0.4, blue: 0.1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

struct JungleEnvironmentView: View {
    var body: some View {
        ZStack {
            // Trees
            ForEach(0..<8, id: \.self) { i in
                Image("tree\(i % 3 + 1)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 60)
                    .position(
                        x: CGFloat.random(in: 20...330),
                        y: CGFloat.random(in: 60...480)
                    )
            }
            
            // Bushes
            ForEach(0..<12, id: \.self) { i in
                Image("bush")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 20)
                    .position(
                        x: CGFloat.random(in: 15...335),
                        y: CGFloat.random(in: 70...490)
                    )
            }
        }
    }
}

// MARK: - Enhanced Game Elements View with Real Effects
struct GameElementsView: View {
    @ObservedObject var game: ChickenBlastGame
    
    var body: some View {
        ZStack {
            // Explosion effects
            ForEach(game.explosions) { explosion in
                ExplosionEffectView(explosion: explosion)
            }
            
            // Smoke effects
            ForEach(game.smokeEffects) { smoke in
                SmokeEffectView(smoke: smoke)
            }
            
            // Toast messages
            ForEach(game.toastMessages) { toast in
                ToastMessageView(toast: toast)
            }
            
            // Bombs
            ForEach(Array(game.bombs.enumerated()), id: \.element.id) { index, bomb in
                BombView(bomb: bomb, index: index, game: game)
            }
            
            // Chickens
            ForEach(game.chickens) { chicken in
                if chicken.isAlive && !chicken.isDying {
                    ChickenView(chicken: chicken)
                }
            }
            
            // Dying chickens
            ForEach(game.chickens) { chicken in
                if chicken.isDying {
                    DyingChickenView(chicken: chicken)
                }
            }
        }
    }
}

// MARK: - Bomb View with Numbering
struct BombView: View {
    let bomb: Bomb
    let index: Int
    let game: ChickenBlastGame
    
    var body: some View {
        ZStack {
            // Bomb image with blinking effect
            Image(bomb.bombType.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .opacity(bomb.isBlinking ? 1.0 : 0.7)
                .scaleEffect(bomb.isBlinking ? 1.1 : 1.0)
                .animation(bomb.isBlinking ? .easeInOut(duration: 0.5).repeatForever() : .default, value: bomb.isBlinking)
            
            // Bomb number
            Text("\(bomb.bombNumber)")
                .font(.system(size: 16, weight: .black))
                .foregroundColor(.white)
                .background(
                    Circle()
                        .fill(Color.red)
                        .frame(width: 24, height: 24)
                )
                .offset(y: -25)
            
            // Blast radius indicator
            if game.gameState == .bombPlacement {
                Circle()
                    .stroke(Color.red.opacity(0.3), lineWidth: 2)
                    .frame(width: bomb.blastRadius * 2, height: bomb.blastRadius * 2)
            }
        }
        .position(bomb.position)
    }
}

// MARK: - Chicken Views
struct ChickenView: View {
    let chicken: JungleChicken
    
    var body: some View {
        Image(chicken.imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50)
            .position(chicken.position)
    }
}

// MARK: - Enhanced Dying Chicken View
struct DyingChickenView: View {
    let chicken: JungleChicken
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            Image(chicken.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .position(chicken.position)
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                rotation = 180
                scale = 0.8
            }
            
            withAnimation(.easeOut(duration: 1.5).delay(0.5)) {
                opacity = 0.0
                scale = 0.3
            }
        }
    }
}

// MARK: - Enhanced Header View with Beautiful Design
struct GameHeaderView: View {
    @ObservedObject var game: ChickenBlastGame
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Back to Menu Button
                Button(action: {
                    game.backToMainMenu()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Menu")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(15)
                }
                
                Spacer()
                
                // Level Info
                VStack(alignment: .center, spacing: 4) {
                    HStack {
                        Image(systemName: "number")
                            .foregroundColor(.orange)
                            .font(.system(size: 14))
                        
                        Text("LEVEL \(game.currentLevel)")
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(.white)
                    }
                    
                    Text(game.currentConfig.bombType.rawValue.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                // Score
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                        
                        Text("SCORE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text("\(game.score)")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.white)
                        .shadow(color: .yellow, radius: 2)
                }
                
                Spacer()
                
                // Time
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(game.timeRemaining < 10 ? .red : .green)
                            .font(.system(size: 14))
                        
                        Text("TIME")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text("\(Int(game.timeRemaining))")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(game.timeRemaining < 10 ? .red : .white)
                }
            }
            
            // Progress Bar
            HStack {
                Text("Chickens Blasted: \(game.chickensBlastedThisLevel)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("Bombs Left: \(game.bombs.count)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.3, green: 0.2, blue: 0.1),
                    Color(red: 0.4, green: 0.3, blue: 0.2),
                    Color(red: 0.3, green: 0.2, blue: 0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.orange, .yellow, .orange]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 10)
    }
}


// MARK: - Modern Main Menu View
struct MainMenuView: View {
    @ObservedObject var game: ChickenBlastGame
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack {
            // Background Image with proper safe area handling
            Color.black.ignoresSafeArea()
            
            Image("menu_background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.height
                )
                .ignoresSafeArea()
                .overlay(
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                )
            
            // Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    // Logo
                    VStack(spacing: 10) {
                        Text("CHICKENAPOCALYPSE")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .orange, radius: 10)
                            .multilineTextAlignment(.center)
                        
                        Text("Blast & Survive")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 50)
                    
                    // Main Action Buttons
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    
                        
                        Button(action: {
                            game.showHowToPlay = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 35))
                                Text("GUIDELINES")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(colors: [.blue, .blue.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        
                        Button(action: {
                            game.showLeaderboard = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 35))
                                Text("Mission Records")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(colors: [.orange, .orange.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        
                        Button(action: {
                            game.gameStatistics = GameStatistics(levelStats: [])
                            game.completedLevels = [1]
                            UserDefaults.standard.removeObject(forKey: "completedLevels")
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 35))
                                Text("Reset Game")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(colors: [.red, .red.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Level Selection Grid
                    VStack(spacing: 15) {
                        Text("SELECT MISSION")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                            .shadow(color: .orange, radius: 5)
                        
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(1...7, id: \.self) { level in
                                ModernLevelCard(level: level, game: game)
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                    .padding(.top, 10)
                    
                    Spacer(minLength: 50) // Add bottom spacing
                }
                .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height)
                .padding(.top,30)
                .padding(.top,20)
            }
            .ignoresSafeArea()
            
            // How to Play Popup
            if game.showHowToPlay {
                HowToPlayView(game: game)
            }
            
            // Leaderboard Popup
            if game.showLeaderboard {
                LeaderboardView(game: game)
            }
        }
        .ignoresSafeArea()
    }
}


// MARK: - Modern Level Card Design
struct ModernLevelCard: View {
    let level: Int
    @ObservedObject var game: ChickenBlastGame
    
    var config: LevelConfig {
        return LevelConfig.getConfig(for: level)
    }
    
    var isUnlocked: Bool {
        return game.completedLevels.contains(level)
    }
    
    var levelStat: GameStatistics.LevelStat? {
        return game.gameStatistics.levelStats.first { $0.level == level }
    }
    
    var body: some View {
        Button(action: {
            if isUnlocked {
                game.startLevel(level)
            }
        }) {
            VStack(spacing: 12) {
                // Level Badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isUnlocked ?
                                    [Color.orange, Color.red] :
                                    [Color.gray, Color.gray.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: isUnlocked ? .orange : .gray, radius: 8, x: 0, y: 4)
                    
                    if isUnlocked {
                        VStack(spacing: 2) {
                            Image(config.bombType.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                            
                            Text("Lv. \(level)")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(.white)
                        }
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Completion Badge
                    if levelStat != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.green).frame(width: 20, height: 20))
                            .offset(x: 25, y: -25)
                    }
                }
                
                // Level Info
                VStack(spacing: 4) {
                    Text(config.bombType.rawValue)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Label("\(config.bombCount)", systemImage: "bomb.fill")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Label("\(config.bombType.pointValue)", systemImage: "star.fill")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Best Score
                    if let stat = levelStat {
                        Text("Best: \(stat.score)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                }
            }
            .frame(width: 110, height: 130)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: isUnlocked ?
                                [Color.brown.opacity(0.9), Color.brown.opacity(0.7)] :
                                [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isUnlocked ?
                                    (levelStat != nil ? Color.green : Color.orange) :
                                    Color.gray,
                                lineWidth: 3
                            )
                    )
                    .shadow(color: isUnlocked ? .orange.opacity(0.3) : .gray.opacity(0.3), radius: 10, x: 0, y: 5)
            )
        }
        .disabled(!isUnlocked)
        .opacity(isUnlocked ? 1.0 : 0.6)
        .scaleEffect(isUnlocked ? 1.0 : 0.9)
    }
}

// MARK: - How to Play View
struct HowToPlayView: View {
    @ObservedObject var game: ChickenBlastGame
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("GUIDELINES")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: .blue, radius: 10)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        InstructionRow(icon: "1.circle.fill", title: "Select Mission", description: "Choose from 7 explosive levels with different bomb types")
                        
                        InstructionRow(icon: "2.circle.fill", title: "Place Bombs", description: "Bombs are automatically placed in strategic positions")
                        
                        InstructionRow(icon: "3.circle.fill", title: "Blast Chickens", description: "Tap bombs when chickens are in blast radius to score points")
                        
                        InstructionRow(icon: "4.circle.fill", title: "Score Points", description: "Different bomb types give different points per chicken")
                        
                        InstructionRow(icon: "5.circle.fill", title: "Complete Levels", description: "Use all bombs strategically to maximize your score")
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Bomb Types:")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.orange)
                            
                            ForEach(Bomb.BombType.allCases, id: \.self) { bombType in
                                HStack {
                                    Image(bombType.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                    
                                    VStack(alignment: .leading) {
                                        Text(bombType.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Text("\(bombType.pointValue) pts • \(Int(bombType.radius)) radius")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 400)
                
                Button("Got It!") {
                    game.showHowToPlay = false
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(red: 0.2, green: 0.1, blue: 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.blue, lineWidth: 3)
                    )
            )
            .padding(40)
        }
    }
}

struct InstructionRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Leaderboard View
struct LeaderboardView: View {
    @ObservedObject var game: ChickenBlastGame
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Mission Records")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: .orange, radius: 10)
                
                if game.gameStatistics.levelStats.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "trophy")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Missions Completed Yet!")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Complete missions to see your stats here")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(game.gameStatistics.levelStats.sorted { $0.level < $1.level }, id: \.level) { stat in
                                LeaderboardRow(stat: stat)
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: 400)
                }
                
                HStack(spacing: 20) {
                    Button("Clear Stats") {
                        game.gameStatistics = GameStatistics(levelStats: [])
                        game.completedLevels = [1]
                        UserDefaults.standard.removeObject(forKey: "completedLevels")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.red)
                    .cornerRadius(20)
                    
                    Button("Close") {
                        game.showLeaderboard = false
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(20)
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(red: 0.2, green: 0.1, blue: 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.orange, lineWidth: 3)
                    )
            )
            .padding(40)
        }
    }
}

struct LeaderboardRow: View {
    let stat: GameStatistics.LevelStat
    
    var body: some View {
        HStack(spacing: 15) {
            // Level Badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Text("\(stat.level)")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(stat.bombType.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                HStack {
                    Label("\(stat.chickensBlasted)", systemImage: "bird.fill")
                    Label("\(stat.bombsUsed)", systemImage: "bomb.fill")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(stat.score)")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.yellow)
                
                Text("Points")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.brown.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.orange, lineWidth: 1)
                )
        )
    }
}


// MARK: - Level Complete View
struct LevelCompleteView: View {
    @ObservedObject var game: ChickenBlastGame
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Text("LEVEL \(game.currentLevel) COMPLETE!")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: .green, radius: 10)
                
                VStack(spacing: 20) {
                    ResultRow(icon: "trophy.fill", title: "Total Score", value: "\(game.score)")
                    
                    if let lastStat = game.gameStatistics.levelStats.last(where: { $0.level == game.currentLevel }) {
                        ResultRow(icon: "bird.fill", title: "Chickens Blasted", value: "\(lastStat.chickensBlasted)")
                        ResultRow(icon: "bomb.fill", title: "Bombs Used", value: "\(lastStat.bombsUsed)/\(game.currentConfig.bombCount)")
                        ResultRow(icon: "clock.fill", title: "Time Left", value: "\(Int(game.timeRemaining))s")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.brown.opacity(0.9))
                )
                
                HStack(spacing: 20) {
                    if game.currentLevel < 7 {
                        Button(action: {
                            game.nextLevel()
                        }) {
                            HStack {
                                Image(systemName: "arrow.right")
                                Text("NEXT LEVEL")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .cornerRadius(20)
                        }
                    }
                    
                    Button(action: {
                        game.setupMainMenu()
                    }) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("MAIN MENU")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(20)
                    }
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(red: 0.2, green: 0.1, blue: 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.green, lineWidth: 3)
                    )
            )
            .padding(40)
        }
    }
}

// MARK: - Game Over View
struct GameOverView: View {
    @ObservedObject var game: ChickenBlastGame
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Text("MISSION COMPLETE!")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: .orange, radius: 10)
                
                Text("Level Finished")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                VStack(spacing: 15) {
                    Text("FINAL SCORE")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(game.score)")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(.yellow)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.brown.opacity(0.9))
                )
                
                HStack(spacing: 20) {
                    Button(action: {
                        game.restartGame()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("PLAY AGAIN")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(20)
                    }
                    
                    Button(action: {
                        game.setupMainMenu()
                    }) {
                        HStack {
                            Image(systemName: "trophy.fill")
                            Text("Menu")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .cornerRadius(20)
                    }
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(red: 0.2, green: 0.1, blue: 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.orange, lineWidth: 3)
                    )
            )
            .padding(40)
        }
    }
}

struct ResultRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.orange)
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundColor(.white)
        }
    }
}




// MARK: - Splash Screen View
struct SplashScreenView: View {
    @State private var isActive = false
    @State private var scale = 0.5
    @State private var opacity = 0.0
    @State private var rotation = 0.0
    @State private var explode = false
    @State private var blastRadius: CGFloat = 0
    @State private var blastOpacity: Double = 0
    @State private var textScale: CGFloat = 0.8
    @State private var showChickenIcons = false
    
    var body: some View {
        ZStack {
            // Background Image
            Image("menu_background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.height
                )
                .ignoresSafeArea()
                .overlay(
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                )
            
            // Blast Effect
            if explode {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [.orange, .red, .yellow, .clear]),
                            center: .center,
                            startRadius: 0,
                            endRadius: blastRadius
                        )
                    )
                    .frame(width: blastRadius * 2, height: blastRadius * 2)
                    .opacity(blastOpacity)
                    .blur(radius: 20)
            }
            
            // Chicken Icons flying out
            if showChickenIcons {
                ForEach(0..<8, id: \.self) { index in
                    Image(systemName: "bird.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .offset(
                            x: cos(Double(index) * .pi / 4) * blastRadius * 0.8,
                            y: sin(Double(index) * .pi / 4) * blastRadius * 0.8
                        )
                        .scaleEffect(2.0 - blastOpacity)
                        .opacity(1.0 - blastOpacity)
                }
            }
            
            // App Name with Effects
            VStack(spacing: 5) {
                Text("CHICKEN")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .orange, radius: 15, x: 0, y: 5)
                    .scaleEffect(textScale)
                
                Text("BLAST")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundColor(.orange)
                    .shadow(color: .red, radius: 20, x: 0, y: 5)
                    .scaleEffect(scale)
                    .overlay(
                        Text("BLAST")
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)
                            .scaleEffect(scale)
                            .blur(radius: 10)
                            .opacity(0.6)
                    )
                
                Text("APOCALYPSE")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.yellow)
                    .shadow(color: .green, radius: 10, x: 0, y: 3)
                    .scaleEffect(textScale)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            
            // Loading indicator
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                    Spacer()
                }
                .padding(.bottom, 80)
                .opacity(opacity)
            }
        }
        .onAppear {
            // Initial animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
                textScale = 1.0
            }
            
            // Rotation animation
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                rotation = 360
            }
            
            // First blast effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.8)) {
                    explode = true
                    blastRadius = 300
                    blastOpacity = 0.8
                    showChickenIcons = true
                }
                
                withAnimation(.easeIn(duration: 0.5).delay(0.8)) {
                    blastOpacity = 0
                    scale = 1.1
                }
            }
            
            // Second blast effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.6)) {
                    blastRadius = 400
                    blastOpacity = 0.6
                    scale = 1.0
                }
                
                withAnimation(.easeIn(duration: 0.4).delay(0.6)) {
                    blastOpacity = 0
                }
            }
            
            // Third blast effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeOut(duration: 0.4)) {
                    blastRadius = 500
                    blastOpacity = 0.4
                    textScale = 1.05
                }
                
                withAnimation(.easeIn(duration: 0.3).delay(0.4)) {
                    blastOpacity = 0
                    textScale = 1.0
                }
            }
            
            // Move to main menu
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            ChickenBlastView()
        }
    }
}


// MARK: - Main Game View
struct ChickenBlastView: View {
    @StateObject private var game = ChickenBlastGame()
    @State private var contentSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                JungleBackgroundView()
                
                // Main content
                VStack(spacing: 0) {
                    // Header - only show when NOT in main menu
                    if game.gameState != .mainMenu {
                        GameHeaderView(game: game)
                            .padding(.horizontal, 10)
                            .padding(.top, 10)
                    }
                    
                    // Game Area
                    if game.gameState == .mainMenu {
                        // Main Menu takes full screen
                        MainMenuView(game: game)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    } else {
                        // Game content with scroll view
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 20) {
                                ZStack {
                                    // Jungle environment
                                    JungleEnvironmentView()
                                    
                                    // Game elements with real effects
                                    GameElementsView(game: game)
                                }
                                .frame(width: min(350, geometry.size.width * 0.9),
                                       height: min(500, geometry.size.height * 0.6))
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.green.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.green.opacity(0.3), lineWidth: 2)
                                        )
                                )
                                
                                // Controls - Compact version for smaller screens
                                if game.gameState == .bombPlacement {
                                    CompactBombPlacementView(game: game)
                                } else if game.gameState == .playing {
                                    GameControlsView(game: game)
                                }
                                
                                Spacer(minLength: 20)
                            }
                            .padding()
                            .frame(width: geometry.size.width)
                        }
                        .frame(maxHeight: .infinity)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                
                // Overlays
                if game.gameState == .levelComplete {
                    LevelCompleteView(game: game)
                }
                
                if game.gameState == .gameOver {
                    GameOverView(game: game)
                }
            }
        }
        .onAppear {
            game.setupMainMenu()
        }
    }
}



// MARK: - Compact Bomb Placement View
struct CompactBombPlacementView: View {
    @ObservedObject var game: ChickenBlastGame
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("READY FOR MISSION")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.white)
                    
                    Text(game.currentConfig.bombType.rawValue)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                Button(action: {
                    game.startGame()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("START")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                }
            }
            
            HStack(spacing: 20) {
                StatItem(icon: "bomb.fill", value: "\(game.currentConfig.bombCount)", label: "BOMBS")
                
                StatItem(icon: "scope", value: "\(Int(game.currentConfig.bombType.radius))", label: "RADIUS")
                
                StatItem(icon: "star.fill", value: "\(game.currentConfig.bombType.pointValue)", label: "POINTS")
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.brown.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.orange, lineWidth: 1)
                )
        )
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.orange)
            
            Text(value)
                .font(.system(size: 14, weight: .black))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Updated Game Controls View for Responsiveness
struct GameControlsView: View {
    @ObservedObject var game: ChickenBlastGame
    
    var body: some View {
        VStack(spacing: 12) {
            Text("TAP BOMBS TO BLAST!")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(.white)
                .shadow(color: .red, radius: 2)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(Array(game.bombs.enumerated()), id: \.element.id) { index, bomb in
                        Button(action: {
                            game.blastBomb(at: index)
                        }) {
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.red, .orange],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(width: 60, height: 60)
                                        .shadow(color: .red, radius: 8)
                                    
                                    Text("\(bomb.bombNumber)")
                                        .font(.system(size: 18, weight: .black))
                                        .foregroundColor(.white)
                                        .shadow(color: .black, radius: 2)
                                }
                                
                                Text("\(bomb.points) pts")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.yellow)
                                
                                Text(bomb.bombType.rawValue)
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                            }
                            .frame(width: 70)
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            .frame(height: 100)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.red.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.orange, lineWidth: 1)
                )
        )
    }
}

