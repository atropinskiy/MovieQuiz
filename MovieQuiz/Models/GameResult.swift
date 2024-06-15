import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func compareResult(res: GameResult) -> Bool {
        correct > res.correct
    }
}
