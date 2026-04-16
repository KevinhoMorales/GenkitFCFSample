//
//  AIViewModel.swift
//  GenkitFCFSwift
//
//  Created by Kevinho Morales on 15/4/26.
//

import Foundation
import Combine

@MainActor
class AIViewModel: ObservableObject {
    
    @Published var prompt: String = ""
    @Published var result: String = ""
    @Published var isLoading = false
    
    func generate() async {
        guard !prompt.isEmpty else { return }
        
        isLoading = true
        
        do {
            let response = try await AIService.shared.generateText(prompt: prompt)
            result = response
        } catch {
            result = "Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
