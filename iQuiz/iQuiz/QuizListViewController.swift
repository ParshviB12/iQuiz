//
//  ViewController.swift
//  iQuiz
//
//  Created by Parshvi Balu on 2/17/26.
//

import UIKit

final class QuizListViewController: UITableViewController {

    // Part 1: in-memory array (swap to HTTP in Part 2)
    private let quizzes: [Quiz] = [
        Quiz(
            title: "Mathematics",
            desc: "Test your math skills with quick problems.",
            iconName: "math",
            questions: [
                Question(text: "What is 2 + 2?", answers: ["3", "4", "5", "22"], correctIndex: 1),
                Question(text: "What is 10 / 2?", answers: ["2", "5", "8", "10"], correctIndex: 1)
            ]
        ),
        Quiz(
            title: "Marvel Super Heroes",
            desc: "How well do you know Marvel characters?",
            iconName: "marvel",
            questions: [
                Question(text: "Who is Iron Man?", answers: ["Bruce Wayne", "Tony Stark", "Peter Parker", "Clark Kent"], correctIndex: 1),
                Question(text: "Thor is the god of…", answers: ["Thunder", "Mischief", "Fire", "Water"], correctIndex: 0)
            ]
        ),
        Quiz(
            title: "Science",
            desc: "Explore fun facts and basic science trivia.",
            iconName: "science",
            questions: [
                Question(text: "Water freezes at…", answers: ["0°C", "10°C", "50°C", "100°C"], correctIndex: 0),
                Question(text: "Earth is the ___ planet from the Sun.", answers: ["2nd", "3rd", "4th", "5th"], correctIndex: 1)
            ]
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "iQuiz"
        print("✅ QuizListViewController loaded")
    }

    // MARK: - Settings

    @IBAction func settingsTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Settings", message: "Settings go here", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Table Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizzes.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath)

        let quiz = quizzes[indexPath.row]
        cell.textLabel?.text = quiz.title
        cell.detailTextLabel?.text = quiz.desc
        cell.imageView?.image = UIImage(named: quiz.iconName)
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    // MARK: - Navigation to Questions

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        performSegue(withIdentifier: "ShowQuestion", sender: indexPath)
//    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowQuestion",
           let dest = segue.destination as? QuestionViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            dest.quiz = quizzes[indexPath.row]
        }
    }

}

