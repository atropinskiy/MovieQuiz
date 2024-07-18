protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(alert result: AlertModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func resetImageBorder()
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func disableButtons()
    func enableButtons()
    func showNetworkError(message: String)
}
