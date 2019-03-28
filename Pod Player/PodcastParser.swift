//
//  PodcastParser.swift
//  Pod Player
//
//  Created by Eric Garza Gonzalez on 03/09/18.
//  Copyright © 2018 Eric Garza Gonzalez. All rights reserved.
//

import Foundation

class PodcastParser {
    func getPodcastMetaData(data: Data) -> (title:String?, imageURL:String?, owner:String?) {
        let xml = SWXMLHash.parse(data)
        
        return (xml["rss"]["channel"]["title"].element?.text, xml["rss"]["channel"]["itunes:image"].element?.attribute(by: "href")?.text, xml["rss"]["channel"]["itunes:owner"]["itunes:name"].element?.text)
    }
    
    func getEpisodes(data:Data) -> [Episode] {
        
        var episodes : [Episode] = []
        
        let xml = SWXMLHash.parse(data)
        
        
        for item in xml["rss"]["channel"]["item"].all {
            let episode = Episode()
            if let title = item["title"].element?.text {
                episode.title = title
            }
            if let htmlDescription = item["description"].element?.text {
                episode.htmlDescription = htmlDescription
            }
            if let audioLink = item["enclosure"].element?.attribute(by: "url")?.text {
                episode.audioURL = audioLink
            }
            if let pubDate = item["pubDate"].element?.text {
                if let date = Episode.formatter.date(from: pubDate) {
                    episode.pubDate = date
                }
            }
            
            episodes.append(episode)
            print(episode.pubDate)
        }
        
        
        return episodes
    }
}
