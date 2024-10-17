//  PresenterTests.swift
//  PresenterTests
//
//  Created by Надежда Пономарева on 17.10.2024.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewProtocol {
    var vc: UIViewController = UIViewController()
    
    func screenBeforeTapAnswer() {
        
    }
    
    func bordersColor(isCorrect: Bool) {
        
    }
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
    
    }
    
    func showLoadingIndicator() {
    
    }
    
    func hideLoadingIndicator() {
    
    }
    
    func showNetworkError(message: String) {
    
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter()
        
        sut.view = viewControllerMock
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
