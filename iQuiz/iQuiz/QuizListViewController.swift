//
//  ViewController.swift
//  iQuiz
//
//  Created by Parshvi Balu on 2/17/26.
//

import UIKit

final class QuizListViewController: UITableViewController {

    // MARK: - Settings keys + default URL
    private let defaultURLString = "http://tednewardsandbox.site44.com/questions.json"
    private let urlDefaultsKey = "QuizSourceURL"

    // MARK: - Data source (mutable now)
    private var quizzes: [Quiz] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "iQuiz"
        print("✅ QuizListViewController loaded")

        // Start with fallback so app works offline
        quizzes = fallbackQuizzes()

        // Attempt initial download
        fetchQuizzes(showSuccessAlert: false)
    }

    // MARK: - Settings UI
    @IBAction func settingsTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Settings", message: "Quiz Source URL", preferredStyle: .alert)

        alert.addTextField { tf in
            tf.placeholder = "Source URL"
            tf.text = UserDefaults.standard.string(forKey: self.urlDefaultsKey) ?? self.defaultURLString
            tf.keyboardType = .URL
            tf.autocapitalizationType = .none
            tf.autocorrectionType = .no
        }

        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            let urlString = alert.textFields?.first?.text ?? self.defaultURLString
            UserDefaults.standard.set(urlString, forKey: self.urlDefaultsKey)
        }))

        // REQUIRED: Check Now triggers download
        alert.addAction(UIAlertAction(title: "Check Now", style: .default, handler: { _ in
            let urlString = alert.textFields?.first?.text ?? self.defaultURLString
            UserDefaults.standard.set(urlString, forKey: self.urlDefaultsKey)
            self.fetchQuizzes(showSuccessAlert: true)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowQuestion",
           let dest = segue.destination as? QuestionViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            dest.quiz = quizzes[indexPath.row]
        }
    }

    // MARK: - Fallback data (your current hardcoded quizzes)
    private func fallbackQuizzes() -> [Quiz] {
        return [
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
    }

    // MARK: - Networking DTOs (match JSON shape)
    private struct QuizDTO: Codable {
        let title: String
        let desc: String
        let questions: [QuestionDTO]
    }

    private struct QuestionDTO: Codable {
        let text: String
        let answer: String      // "1", "2", ... (1-based index)
        let answers: [String]
    }

    private func currentURL() -> URL {
        let saved = UserDefaults.standard.string(forKey: urlDefaultsKey) ?? defaultURLString
        return URL(string: saved) ?? URL(string: defaultURLString)!
    }
    

    private func fetchQuizzes(showSuccessAlert: Bool) {
        let url = currentURL()

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in

            // If network fails, show alert (counts as "notify users network not available")
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Network Error", message: error.localizedDescription)
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: "No data returned.")
                }
                return
            }

            do {
                let dtos = try JSONDecoder().decode([QuizDTO].self, from: data)

                let converted: [Quiz] = dtos.map { dto in
                    Quiz(
                        title: dto.title,
                        desc: dto.desc,
                        iconName: self?.iconName(for: dto.title) ?? "science",
                        questions: dto.questions.map { qdto in
                            // Convert "1"-based string to 0-based Int for your app
                            let oneBased = Int(qdto.answer) ?? 1
                            let correctIndex = max(0, oneBased - 1)
                            return Question(text: qdto.text, answers: qdto.answers, correctIndex: correctIndex)
                        }
                    )
                }

                DispatchQueue.main.async {
                    self?.quizzes = converted
                    self?.tableView.reloadData()

                    if showSuccessAlert {
                        self?.showAlert(title: "Updated", message: "Downloaded \(converted.count) quizzes.")
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Decode Error", message: error.localizedDescription)
                }
            }

        }.resume()
    }

    private func iconName(for title: String) -> String {
        let lower = title.lowercased()
        if lower.contains("math") { return "math" }
        if lower.contains("marvel") { return "marvel" }
        if lower.contains("science") { return "science" }
        return "science"
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

