//
//  Episode.swift
//  Pod Player
//
//  Created by Eric Garza Gonzalez on 03/09/18.
//  Copyright © 2018 Eric Garza Gonzalez. All rights reserved.
//

import Cocoa

class Episode {
    var title = ""
    var pubDate = Date()
    var audioURL = ""
    var htmlDescription = ""
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return formatter
    }()
}
