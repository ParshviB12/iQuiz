//
//  ResultsViewController.swift
//  iQuiz
//
//  Created by Parshvi Balu on 2/17/26.
//

import UIKit

final class ResultsViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!

    var quizTitle: String = ""
    var score: Int = 0
    var total: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Results"
        scoreLabel.text = "\(quizTitle)\nScore: \(score)/\(total)"
        scoreLabel.numberOfLines = 0
        scoreLabel.textAlignment = .center
    }
}
