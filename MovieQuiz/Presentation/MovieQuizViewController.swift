import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    //  Аутлеты и переменные
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        statisticService = StatisticService()
        let questionFactory = QuestionFactory() // 2
        questionFactory.delegate = self         // 3
        
        alertPresenter = AlertPresenter(delegate: self)
        self.questionFactory = questionFactory  // 4
        
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    //  Остальные функции
    // Функция конвертации вопроса во View
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(named: model.image) ?? UIImage()
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        let question = model.text
        
        
        let viewModel = QuizStepViewModel(
            image: image,
            question: question,
            questionNumber: questionNumber)
        return viewModel
    }
    // Функция показа вопроса и остального контента
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.cornerRadius = 20
        
        
    }
    
    // Функция результата ответа
    private func showAnswerResult(isCorrect: Bool) {
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
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
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
                buttonText: "OK") { [weak self] _ in
                    guard let self = self else { return }
                    self.correctAnswers = 0
                    self.currentQuestionIndex = 0
                    self.questionFactory.requestNextQuestion() }
            alertPresenter?.showAlert(quiz: alertModel)
            
        } else { // если еще не конец игры
            currentQuestionIndex += 1 // увеличиваем индекс вопроса
            questionFactory.requestNextQuestion()
        }
    }
    
    private func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    private func enableButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    @IBAction private func noTouched(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false // 2
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
    }
    
    @IBAction private func yesButtonTouched(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true // 2
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
