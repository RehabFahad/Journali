//
//  ContentView.swift
//  mvvmtest
//
//  Created by رحاب فهد  on 01/05/1447 AH.
//

// 📁 Models/JournalEntry.swift
import Foundation

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let title: String
    let body: String
    let date: Date
    var bookmarked: Bool = false
}
