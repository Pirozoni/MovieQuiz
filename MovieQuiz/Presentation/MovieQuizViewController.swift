import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    // MARK: - Private Properties
    
    private let presenter = MovieQuizPresenter()
    private var currentQuestionIndex = 0
//    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0


    private lazy var alertPresenter = AlertPresenter(delegate: self)
    private lazy var statisticService: StatisticServiceProtocol = StatisticService()
    private lazy var questionFactory: QuestionFactoryProtocol = QuestionFactory(
        moviesLoader: MoviesLoader(),
        delegate: self
    )
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true

        showLoadingIndicator()
        questionFactory.loadData() // убран опционал
        questionFactory.requestNextQuestion()
        
        imageView.backgroundColor = .ypWhite
        imageView.layer.cornerRadius = 20
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
//        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
    // MARK: - IB Actions
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        //        guard let currentQuestion = questions[safe: currentQuestionIndex] else { return } // 4 спринт
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        availableButtons(status: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        //        guard let currentQuestion = questions[safe: currentQuestionIndex] else { return } // 4 спринт
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        availableButtons(status: false)
    }
    
    // MARK: - Private Methods
    
    // вывод на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // изменение цвета рамки
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect  {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {  [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() /*== presenter.questionsAmount - 1*/ {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let text = correctAnswers == presenter.questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            """
            Ваш результат: \(correctAnswers)\\\(presenter.questionsAmount)/10
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
                    self?.questionFactory.requestNextQuestion()
                })
                alertPresenter.show(quiz: alertModel)
                // идём в состояние "Результат квиза"
            } else {
//                currentQuestionIndex += 1
                presenter.switchToNextQuestion()
                self.questionFactory.requestNextQuestion()
            }
            imageView.layer.borderColor = UIColor.ypBlack.cgColor
            availableButtons(status: true)
        }
    
    private func availableButtons(status: Bool) {
        yesButton.isEnabled = status
        noButton.isEnabled = status
    }
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        self.presenter.resetQuestionIndex()
        self.correctAnswers = 0
        
        let model = AlertModel(
            title: "Что-то пошло не так :(",
            message: message,
            buttonText: "Попробуйте еще раз"
        ) { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.presenter.resetQuestionIndex()
            self.questionFactory.requestNextQuestion()
        }
        alertPresenter.show(quiz: model)
    }
}
    
extension MovieQuizViewController: AlertPresenterDelegate {
    func show(quiz result: AlertModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.message,
            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory.requestNextQuestion()
            })
        alertPresenter.show(quiz: alertModel)
    }
}
