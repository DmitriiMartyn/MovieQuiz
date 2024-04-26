import UIKit
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    func show(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
 
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButtonClicked: UIButton!
    @IBOutlet private weak var yesButtonClicked: UIButton!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    
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
    // переменная с индексом текущего вопроса, начальное значение 0
    // (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex = 0

    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0

    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private lazy var statisticService: StatisticServiceProtocol = StatisticServiceImplementation()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        alertPresenter = AlertPresenter(delegate: self)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        questionFactory?.requestNextQuestion()
    }
    // MARK: - QuestionFactoryDelegate

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


    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
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
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderColor = UIColor.ypBlack.cgColor
           // код, который мы хотим вызвать через 1 секунду
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

    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
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




/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
