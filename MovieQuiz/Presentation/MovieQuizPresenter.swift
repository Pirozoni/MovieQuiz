//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Надежда Пономарева on 16.10.2024.
import UIKit

protocol MovieQuizPresenterProtocol {
    var view: MovieQuizViewProtocol? { get set }
    func noButtonClicked()
    func yesButtonClicked()
    func didReceiveNextQuestion(question: QuizQuestion?)
    func loadData()
    func convert(model: QuizQuestion) -> QuizStepViewModel
    func showAnswerResult(isCorrect: Bool)
    
}

final class MovieQuizPresenter: MovieQuizPresenterProtocol {
    weak var view: MovieQuizViewProtocol?
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    private var statisticService = StatisticService()
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter?
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else {
            return
    }
        let givenAnswer = isYes
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            let text = correctAnswers == self.questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            """
            Ваш результат: \(correctAnswers)/10
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/10 (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    self?.currentQuestionIndex = 0
                    self?.correctAnswers = 0
                    self?.questionFactory?.requestNextQuestion()
                })
                alertPresenter?.show(quiz: alertModel)
                // идём в состояние "Результат квиза"
            } else {
                self.switchToNextQuestion()
                self.questionFactory?.requestNextQuestion()
            }
        view?.screenBeforeTapAnswer()
    }
    
    func loadData() {
      
        let alertPresenter = AlertPresenter(delegate: view?.vc)
        self .alertPresenter = alertPresenter
        let questionFactory: QuestionFactoryProtocol = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
            )
        view?.showLoadingIndicator()
        questionFactory.loadData()
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect  {
            correctAnswers += 1
        }
 
        view?.bordersColor(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {  [weak self] in
            guard let self = self else { return }
            showNextQuestionOrResults()
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
}

extension MovieQuizPresenter: AlertPresenterDelegate {
    func show(quiz result: AlertModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.message,
            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.show(quiz: alertModel)
    }
}

extension MovieQuizPresenter: QuestionFactoryDelegate {
    func show(quiz step: QuizStepViewModel) {
        view?.show(quiz: step)
    }
    
    func didLoadDataFromServer() {
        view?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        
        view?.hideLoadingIndicator()
            
        let model = AlertModel(
            title: "Что-то пошло не так :(",
            message: error.localizedDescription,
            buttonText: "Попробуйте еще раз"
        ) { [weak self] in

            self?.currentQuestionIndex = 0
            self?.resetQuestionIndex()
            self?.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.show(quiz: model)
    }
    
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
}
