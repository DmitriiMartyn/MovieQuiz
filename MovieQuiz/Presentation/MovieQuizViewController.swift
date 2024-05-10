import UIKit
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    func show(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
 
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButtonClicked: UIButton!
    @IBOutlet private weak var yesButtonClicked: UIButton!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    private func showNetworkError(message: String) {

            let model = AlertModel(
                title: "Ошибка",
                message: message,
                buttonText: "Попробовать еще раз") { [weak self] in
                    guard let self = self else { return }

                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0

                    self.questionFactory?.requestNextQuestion()
                }
        alertPresenter?.show(alertModel: model)
        }
    @IBAction private func yesButtonClicked(_ sender: Any) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
        }
        @IBAction private func noButtonClicked(_ sender: Any) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
        }
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private lazy var statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        alertPresenter = AlertPresenter(delegate: self)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        
        showLoadingIndicator()
                questionFactory?.loadData()
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
            return QuizStepViewModel (
                image: UIImage(data: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        }
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
                correctAnswers += 1
            }
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        self.yesButtonClicked
            .isEnabled = false
        self.noButtonClicked.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderColor = UIColor.ypBlack.cgColor
        
           self.showNextQuestionOrResults()
            self.yesButtonClicked.isEnabled = true
            self.noButtonClicked.isEnabled = true
        }
    }
    private func showAlert(quizResult quiz: QuizResultsViewModel) {

        let alertModel = AlertModel(title: quiz.title,
                                    message: quiz.text,
                                    buttonText: quiz.buttonText,
                                    buttonAction: {[weak self] in
            self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
            self?.questionFactory?.requestNextQuestion()
        })
        alertPresenter?.show(alertModel: alertModel)
    }
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {

            statisticService.store(correct: correctAnswers, total: questionsAmount)

            showAlert(quizResult: QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: """
                Ваш результат: \(correctAnswers)/10
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.toString()))
                Средняя точность: \(Int(statisticService.totalAccuracy))%
                """,
                buttonText: "Сыграть еще раз"))
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}
