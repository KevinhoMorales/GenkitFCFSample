//
//  AIService.swift
//  GenkitFCFSwift
//
//  Created by Kevinho Morales on 15/4/26.
//

import Foundation

enum AIServiceError: LocalizedError {
    case badURL
    case invalidStatus(code: Int, body: String)
    case apiError(String)
    case emptyData

    var errorDescription: String? {
        switch self {
        case .badURL: return "URL inválida"
        case .invalidStatus(let code, let body):
            return "HTTP \(code): \(body)"
        case .apiError(let message): return message
        case .emptyData: return "Respuesta sin texto"
        }
    }
}

// MARK: - Service

final class AIService {

    static let shared = AIService()

    /// Ruta completa del HTTP function (incluye `/generate`).
    private let endpoint = URL(string: "https://us-central1-devlokos-genkit-demo.cloudfunctions.net/generate")!

    private init() {}

    func generateText(prompt: String) async throws -> String {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = ["text": prompt]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw AIServiceError.badURL
        }

        let raw = String(data: data, encoding: .utf8) ?? ""

        guard (200 ..< 300).contains(http.statusCode) else {
            throw AIServiceError.invalidStatus(code: http.statusCode, body: raw)
        }

        let decoded = try JSONDecoder().decode(AIGenerateResponse.self, from: data)

        guard decoded.success else {
            throw AIServiceError.apiError(decoded.error ?? "Error desconocido")
        }

        guard let text = decoded.data, !text.isEmpty else {
            throw AIServiceError.emptyData
        }

        return text
    }
}
