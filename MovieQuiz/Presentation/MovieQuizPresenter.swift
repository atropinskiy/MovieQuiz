import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var statisticService: StatisticServiceProtocol = StatisticService()
    var questionFactory: QuestionFactoryProtocol?
    var correctAnswers: Int = 0
    
    private var currentQuestionIndex: Int = 0

    init(viewController: MovieQuizViewController) {
            self.viewController = viewController
            statisticService = StatisticService()
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            questionFactory?.loadData()
            viewController.showLoadingIndicator()
        }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonTouched () {
        didAnswer(isYes: true)
    }
    
    func noButtonTouched () {
        didAnswer(isYes: false)
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            let gamesCount = statisticService.gamesCount
            let totalAccuracy = statisticService.totalAccuracy
            let bestGame = statisticService.bestGame
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: """
                    Ваш результат: \(correctAnswers)/10\n
                    Количество сыгранных квизов: \(gamesCount)\n
                    Рекорд: \(bestGame.total)/10 (\(bestGame.date.dateTimeString))\n
                    Средняя точность: \(String(format: "%.2f", totalAccuracy))
                    """,
                buttonText: "Сыграть ещё раз") { [weak self] _ in
                    guard let self = self else { return }
                    correctAnswers = 0
                    self.resetQuestionIndex()
                    self.questionFactory?.requestNextQuestion() }
            
            viewController?.alertPresenter?.showAlert(quiz: alertModel)
            
        } else { // если еще не конец игры
            self.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
}
