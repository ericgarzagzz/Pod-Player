//
//  EpisodesVC.swift
//  Pod Player
//
//  Created by Eric Garza Gonzalez on 03/09/18.
//  Copyright © 2018 Eric Garza Gonzalez. All rights reserved.
//

import Cocoa
import AVFoundation

class EpisodesVC: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    
    @IBOutlet weak var TitleLabel: NSTextField!
    @IBOutlet weak var OwnerLabel: NSTextField!
    @IBOutlet weak var CoverImage: NSImageView!
    @IBOutlet weak var VolumeLabel: NSTextField!
    @IBOutlet weak var PausePlayButton: NSButton!
    @IBOutlet weak var StatusLabel: NSTextField!
    @IBOutlet weak var DeleteButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var VolumeSlider: NSSlider!
    
    var podcast : Podcast? = nil
    var podcastsVC : PodcastsVC? = nil
    var episodes : [Episode] = []
    var player : AVPlayer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        updateView()
    }
    
    func updateView() {
        if podcast?.title != nil {
            TitleLabel.stringValue = podcast!.title!
        }else {
            TitleLabel.stringValue = ""
        }
        
        if podcast?.owner  != nil {
            OwnerLabel.stringValue = podcast!.owner!
        }else {
            OwnerLabel.stringValue = "Unknown owner"
        }
        
        if podcast?.imageURL != nil {
            let image = NSImage(byReferencing: URL(string: podcast!.imageURL!)!)
            CoverImage.image = image
        }else {
            CoverImage.image = nil
        }
        
        if podcast != nil {
            OwnerLabel.isHidden = false
            tableView.isHidden = false
            DeleteButton.isHidden = false
            VolumeSlider.isHidden = false
            VolumeLabel.isHidden = false
        }else {
            OwnerLabel.isHidden = true
            tableView.isHidden = true
            DeleteButton.isHidden = true
            VolumeSlider.isHidden = true
            VolumeLabel.isHidden = true
        }
        
        PausePlayButton.isHidden = true
        
        getEpisodes()
    }
    
    func getEpisodes() {
        if podcast?.rssURL != nil {
            if let url = URL(string: podcast!.rssURL!) {
                URLSession.shared.dataTask(with: url) { (data: Data?, response:URLResponse?, error:Error?) in
                    if error != nil {
                        print(error!)
                    }else {
                        if data != nil {
                            let parser = PodcastParser()
                            self.episodes = parser.getEpisodes(data: data!)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }.resume()
            }
        }
    }
    
    @IBAction func PausePlay_Click(_ sender: Any) {
        if self.player?.rate != 0 && self.player?.error == nil { // Playing
            self.player?.pause()
            self.PausePlayButton.title = "Play"
        }else { // Not playing
            self.player?.play()
            self.PausePlayButton.title = "Pause"
        }
    }
    
    @IBAction func Delete_Click(_ sender: Any) {
        
        if podcast != nil {
            if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                context.delete(podcast!)
                (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
                
                podcastsVC?.getPodcasts()
                
                podcast = nil
                updateView()
            }
        }
    }
    
    func getVolumeFromSlider() -> Float {
        let porcentageVolume = Float(self.VolumeSlider.doubleValue / 100)
        
        return porcentageVolume
    }
    
    @IBAction func VolumeSlider_ValueChange(_ sender: Any) {
        self.player?.volume = self.getVolumeFromSlider()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.episodes.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let episode = self.episodes[row]
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("episodeCell"), owner: self) as? EpisodeCell {
            cell.TitleLabel.stringValue = episode.title
            cell.DateLabel.stringValue = episode.pubDate.description
            
            let formatter = DateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
            formatter.dateFormat = "MMM d, yyyy"
            
            cell.DateLabel.stringValue = formatter.string(from: episode.pubDate)
            
            cell.DescriptionWV.loadHTMLString(episode.htmlDescription, baseURL: nil)
            
            return cell
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if self.tableView.selectedRow >= 0 {
            self.StatusLabel.stringValue = "Loading..."
            let episode = self.episodes[tableView.selectedRow]
            if let audioURL = URL(string: episode.audioURL) {
                self.player = nil
                self.player = AVPlayer(url: audioURL)
                self.player?.volume = self.getVolumeFromSlider()
                self.player?.play()
                
                self.PausePlayButton.isHidden = false
                self.PausePlayButton.title = "Pause"
                
                self.StatusLabel.stringValue = episode.title
            }else {
                self.StatusLabel.stringValue = "Error while loading the podcast"
            }
            
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 100
    }
}
