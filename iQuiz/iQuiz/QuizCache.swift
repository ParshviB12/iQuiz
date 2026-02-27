//
//  QuizCache.swift
//  iQuiz
//
//  Created by Parshvi Balu on 2/26/26.
//

import Foundation

enum QuizCache {
    static let filename = "quizzes_cache.json"

    static func cacheURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(filename)
    }

    static func save(_ data: Data) throws {
        try data.write(to: cacheURL(), options: [.atomic])
    }

    static func load() throws -> Data {
        try Data(contentsOf: cacheURL())
    }

    static func exists() -> Bool {
        FileManager.default.fileExists(atPath: cacheURL().path)
    }
}
