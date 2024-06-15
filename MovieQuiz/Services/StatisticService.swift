import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
        case bestGameDate
        case totalCorrectAnswers
        case totalAnsweredQuestions
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.gamesCount.rawValue)
            let total = storage.integer(forKey: Keys.bestGame.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.gamesCount.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGame.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        let totalAnsweredQuestions = storage.integer(forKey: Keys.totalAnsweredQuestions.rawValue)
        
        if totalAnsweredQuestions > 0 {
            let accuracy = Double(totalCorrectAnswers) / Double(totalAnsweredQuestions)
            return accuracy * 100.0 // Приводим к процентам
        } else {
            return 0.0
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let currentCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        let currentAnsweredQuestions = storage.integer(forKey: Keys.totalAnsweredQuestions.rawValue)
        
        let newCorrectAnswers = currentCorrectAnswers + count
        let newAnsweredQuestions = currentAnsweredQuestions + amount
        
        storage.set(newCorrectAnswers, forKey: Keys.totalCorrectAnswers.rawValue)
        storage.set(newAnsweredQuestions, forKey: Keys.totalAnsweredQuestions.rawValue)

        let currentBestGame = bestGame
        if count > currentBestGame.correct {
            let newBestGame = GameResult(correct: count, total: amount, date: Date())
            bestGame = newBestGame
        }

        gamesCount += 1
    }
}
