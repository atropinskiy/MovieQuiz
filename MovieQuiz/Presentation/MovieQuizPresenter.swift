import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewControllerProtocol?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private var questionFactory: QuestionFactoryProtocol?
    var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
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
        let answerResult = givenAnswer == currentQuestion.correctAnswer
        
        didAnswerCorrect(isCorrectAnswer: answerResult)
        showAnswerResult(isCorrect: answerResult)
    }
    
    func didAnswerCorrect(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            self.correctAnswers += 1
        }
    }
    
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let result = makeResultsMessage()
            viewController?.show(alert: result)
        } else { // если еще не конец игры
            self.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    func makeResultsMessage() -> AlertModel {
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
        return alertModel
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
    
    func showAnswerResult(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.disableButtons()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            showNextQuestionOrResults()
            viewController?.resetImageBorder()
            viewController?.enableButtons()
        }
    }
    
}
