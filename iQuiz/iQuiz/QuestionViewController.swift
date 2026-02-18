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

    var quiz: Quiz!

    private var currentIndex = 0
    private var selectedIndex: Int? = nil
    private var userAnswers: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = quiz.title
        showQuestion()
    }

    private func showQuestion() {
        let q = quiz.questions[currentIndex]
        questionLabel.text = q.text

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
        submitButton.isEnabled = true

        // simple selection feedback
        for (i, btn) in answerButtons.enumerated() {
            btn.alpha = (i == idx) ? 1.0 : 0.5
        }
    }

    @IBAction func submitTapped(_ sender: UIButton) {
        guard let chosen = selectedIndex else { return }
        userAnswers.append(chosen)

        if currentIndex < quiz.questions.count - 1 {
            currentIndex += 1
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

