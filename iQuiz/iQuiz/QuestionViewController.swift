//
//  QuestionViewController.swift
//  iQuiz
//
//  Created by Parshvi Balu on 2/17/26.
//
import UIKit

final class QuestionViewController: UIViewController {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet var answerButtons: [UIButton]!
    @IBOutlet weak var submitButton: UIButton!

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!

    
    var quiz: Quiz!

    private var currentIndex = 0
    private var selectedIndex: Int? = nil
    private var userAnswers: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = quiz.title

        pageControl.numberOfPages = quiz.questions.count
        pageControl.currentPage = currentIndex
        pageControl.isUserInteractionEnabled = false  // dots display only

        showQuestion()
        addSwipeGestures()
    }
    private func addSwipeGestures() {
        let left = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        left.direction = .left
        view.addGestureRecognizer(left)

        let right = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        right.direction = .right
        view.addGestureRecognizer(right)
    }
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            guard selectedIndex != nil else { return }  // must answer first
            submitTapped(submitButton)

        case .right:
            guard currentIndex > 0 else { return }

            currentIndex -= 1

            if currentIndex < userAnswers.count {
                selectedIndex = userAnswers[currentIndex]
            } else {
                selectedIndex = nil
            }

            userAnswers = Array(userAnswers.prefix(currentIndex))

            showQuestion()

        default:
            break
        }
    }




    private func showQuestion() {
        resultLabel.text = ""
        correctAnswerLabel.text = ""
        let q = quiz.questions[currentIndex]
        questionLabel.text = q.text
        pageControl.currentPage = currentIndex


        for (i, btn) in answerButtons.enumerated() {
            btn.setTitle(q.answers[i], for: .normal)
            btn.alpha = 1.0
        }

        selectedIndex = nil
        submitButton.isEnabled = false

        // Button text changes: "Next" until last question, then "Submit"
        let isLast = (currentIndex == quiz.questions.count - 1)
        submitButton.setTitle(isLast ? "Submit" : "Next", for: .normal)
    }

    @IBAction func answerTapped(_ sender: UIButton) {
        guard let idx = answerButtons.firstIndex(of: sender) else { return }
        selectedIndex = idx
        submitButton.isEnabled = true  // your button says Next, that's fine

        for (i, btn) in answerButtons.enumerated() {
            btn.alpha = (i == idx) ? 1.0 : 0.5
        }

        let q = quiz.questions[currentIndex]
        if idx == q.correctIndex {
            resultLabel.text = "✅ Correct!"
            correctAnswerLabel.text = ""
        } else {
            resultLabel.text = "❌ Wrong!"
            let correctText = q.answers[q.correctIndex]
            correctAnswerLabel.text = "Correct answer is: \(correctText)"
        }

        for btn in answerButtons { btn.isEnabled = false }
    }


    @IBAction func submitTapped(_ sender: UIButton) {
        guard let chosen = selectedIndex else { return }
        userAnswers.append(chosen)

        if currentIndex < quiz.questions.count - 1 {
            currentIndex += 1
            for btn in answerButtons { btn.isEnabled = true }
            showQuestion()
        } else {
            // finished -> go to results
            performSegue(withIdentifier: "ShowResults", sender: nil)
        }
    }

    private func computeScore() -> (score: Int, total: Int) {
        var score = 0
        for (i, ans) in userAnswers.enumerated() {
            if ans == quiz.questions[i].correctIndex { score += 1 }
        }
        return (score, quiz.questions.count)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowResults",
           let dest = segue.destination as? ResultsViewController {
            let result = computeScore()
            dest.quizTitle = quiz.title
            dest.score = result.score
            dest.total = result.total

            // Part 1 placeholder for uploading
            print("Uploading score... \(result.score)/\(result.total) for \(quiz.title)")
        }
    }
}

