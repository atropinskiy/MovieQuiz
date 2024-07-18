import XCTest
@testable import MovieQuiz

class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    var shownQuizStep: QuizStepViewModel?
    var shownAlert: AlertModel?
    var highlightedImageBorder: Bool?
    var loadingIndicatorShown: Bool = false
    var buttonsEnabled: Bool = true
    var networkErrorMessage: String?

    func show(quiz step: QuizStepViewModel) {
        shownQuizStep = step
    }
    
    func show(alert result: AlertModel) {
        shownAlert = result
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        highlightedImageBorder = isCorrectAnswer
    }
    
    func resetImageBorder() {
        highlightedImageBorder = nil
    }
    
    func showLoadingIndicator() {
        loadingIndicatorShown = true
    }
    
    func hideLoadingIndicator() {
        loadingIndicatorShown = false
    }
    
    func disableButtons() {
        buttonsEnabled = false
    }
    
    func enableButtons() {
        buttonsEnabled = true
    }
    
    func showNetworkError(message: String) {
        networkErrorMessage = message
    }
}


final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
