//
//  ContentView.swift
//  GenkitFCFSwift
//
//  Created by Kevinho Morales on 15/4/26.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = AIViewModel()
    
    var body: some View {
        ZStack {
            
            // 🌅 BACKGROUND GRADIENT
            LinearGradient(
                colors: [Color.orange.opacity(0.2), Color.yellow.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                // 🔥 HEADER
                VStack(spacing: 8) {
                    Text("🔥 IA con Firebase")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Describe tu idea y genera contenido con IA")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // ✏️ INPUT CARD
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tu idea")
                        .font(.headline)
                    
                    TextField("Ej: una app de comida con IA...", text: $viewModel.prompt)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 10)
                
                // 🚀 BUTTON
                Button {
                    Task {
                        await viewModel.generate()
                    }
                } label: {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        
                        Text(viewModel.isLoading ? "Generando..." : "Generar con IA")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .shadow(color: .orange.opacity(0.3), radius: 8)
                }
                .disabled(viewModel.prompt.isEmpty || viewModel.isLoading)
                
                
                // 🧠 RESULTADO
                if !viewModel.result.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("Resultado")
                            .font(.headline)
                        
                        ScrollView {
                            Text(viewModel.result)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        .frame(maxHeight: 200)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
