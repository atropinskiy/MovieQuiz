import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    //  Аутлеты и переменные
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private let presenter = MovieQuizPresenter()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self) // 2    // 3
        showLoadingIndicator()
        alertPresenter = AlertPresenter(delegate: self)
        questionFactory?.loadData()
        presenter.viewController = self
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // Функция показа вопроса и остального контента
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.cornerRadius = 20
    }

    // Функция результата ответа
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true // даём разрешение на рисовани
        imageView.layer.borderWidth = 8 // толщина рамки
        disableButtons()
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
            
        }
        else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = nil
            self.imageView.layer.cornerRadius = 0
            self.showNextQuestionOrResults()
            self.imageView.layer.cornerRadius = 20
            self.enableButtons()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
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
                    self.correctAnswers = 0
                    self.presenter.resetQuestionIndex()
                    self.questionFactory?.requestNextQuestion() }
            
            alertPresenter?.showAlert(quiz: alertModel)
            
        } else { // если еще не конец игры
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    private func enableButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { _ in

            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.showAlert(quiz: model)
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    @IBAction private func noTouched(_ sender: Any) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonTouched()
        
    }
    @IBAction private func yesButtonTouched(_ sender: Any) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonTouched()
    }

}
