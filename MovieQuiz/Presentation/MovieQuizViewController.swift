import UIKit

protocol MovieQuizViewProtocol: AnyObject {
    var vc: UIViewController { get }
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func screenBeforeTapAnswer()
    func show(quiz step: QuizStepViewModel)
    func bordersColor(isCorrect: Bool)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewProtocol {
    
    // MARK: - IB Outlets
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    // MARK: - Properties
    
    var vc: UIViewController { self }
    
    // MARK: - Private Properties
    
    private var presenter: MovieQuizPresenterProtocol = MovieQuizPresenter()

    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true

        presenter.view = self
        showLoadingIndicator()
        
        imageView.backgroundColor = .ypWhite
        imageView.layer.cornerRadius = 20
        
        presenter.loadData()
    }
    
    // MARK: - IB Actions
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
        availableButtons(status: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
        availableButtons(status: false)
    }
    
    // MARK: - Private Methods
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func bordersColor(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func screenBeforeTapAnswer() {
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        availableButtons(status: true)
    }
    
    func availableButtons(status: Bool) { //убрала приватность для presenter
        yesButton.isEnabled = status
        noButton.isEnabled = status
    }
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
}
