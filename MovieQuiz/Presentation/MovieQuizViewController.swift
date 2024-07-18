import UIKit

final class MovieQuizViewController: UIViewController {
    //  Аутлеты и переменные
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(delegate: self)
        presenter = MovieQuizPresenter(viewController: self)
        presenter.viewController = self
    }
    
    // Функция показа вопроса и остального контента
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.cornerRadius = 20
    }

    // Функция результата ответа !!! Остается
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true // даём разрешение на рисовани
        imageView.layer.borderWidth = 8 // толщина рамки
        disableButtons()
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            self.presenter.correctAnswers += 1
            
        }
        else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = nil
            self.imageView.layer.cornerRadius = 0
            self.presenter.showNextQuestionOrResults()
            self.imageView.layer.cornerRadius = 20
            self.enableButtons()
        }
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
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
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { _ in
            self.presenter.restartGame()
        }
        alertPresenter?.showAlert(quiz: model)
    }
    
    
    @IBAction private func noTouched(_ sender: Any) {
        presenter.noButtonTouched()
        
    }
    @IBAction private func yesButtonTouched(_ sender: Any) {
        presenter.yesButtonTouched()
    }

}
