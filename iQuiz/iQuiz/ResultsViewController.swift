//
//  ResultsViewController.swift
//  iQuiz
//
//  Created by Parshvi Balu on 2/17/26.
//

import UIKit

final class ResultsViewController: UIViewController {

    @IBOutlet weak var performanceLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!

    var quizTitle: String = ""
    var score: Int = 0
    var total: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Results"

        performanceLabel.text = performanceText(score: score, total: total)

        scoreLabel.text = "\(quizTitle)\nScore: \(score)/\(total)"
        scoreLabel.numberOfLines = 0
        scoreLabel.textAlignment = .center

    }

    private func performanceText(score: Int, total: Int) -> String {
        if total == 0 { return "" }
        if score == total { return "Perfect!" }
        if score == total - 1 { return "Almost!" }
        if score >= total / 2 { return "Not bad!" }
        return "Keep practicing!"
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        // “Continue” = go back to main topic list
        navigationController?.popToRootViewController(animated: true)
    }
}
