//
//  Date+Format.swift
//  ToDoApp
//
//  Created by Артемий Андреев  on 21.05.2025.
//

import Foundation

extension Date {
    static let todoDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.dateFormat = "dd/MM/yy"
        return df
    }()
    var shortString: String { Self.todoDateFormatter.string(from: self) }
}
