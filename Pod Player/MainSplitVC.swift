//
//  MainSplitVC.swift
//  Pod Player
//
//  Created by Eric Garza Gonzalez on 03/09/18.
//  Copyright © 2018 Eric Garza Gonzalez. All rights reserved.
//

import Cocoa

class MainSplitVC: NSSplitViewController {

    @IBOutlet weak var podcastsItem: NSSplitViewItem!
    @IBOutlet weak var episodesItem: NSSplitViewItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let podcastsVC = podcastsItem.viewController as? PodcastsVC {
            if let episodesVC = episodesItem.viewController as? EpisodesVC {
                podcastsVC.episodeVC = episodesVC
                episodesVC.podcastsVC = podcastsVC
            }
        }
    }
    
}
