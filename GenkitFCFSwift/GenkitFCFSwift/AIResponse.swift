//
//  AIResponse.swift
//  GenkitFCFSwift
//
//  Created by Kevinho Morales on 15/4/26.
//

import Foundation

struct AIGenerateResponse: Decodable {
    let success: Bool
    let data: String?
    let error: String?
}
