//
//  PodcastsVC.swift
//  Pod Player
//
//  Created by Eric Garza Gonzalez on 03/09/18.
//  Copyright © 2018 Eric Garza Gonzalez. All rights reserved.
//

import Cocoa

class PodcastsVC: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    // A podcast url: http://www.espn.com/espnradio/podcast/feeds/itunes/podCast?id=2406595
    
    var podcasts : [Podcast] = []
    var episodeVC : EpisodesVC? = nil

    @IBOutlet weak var podcastURLTextField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        podcastURLTextField.stringValue = "http://www.espn.com/espnradio/podcast/feeds/itunes/podCast?id=2406595"
        
        getPodcasts()
    }
    
    func getPodcasts() {
        if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            let fetchData = Podcast.fetchRequest() as NSFetchRequest<Podcast>
            fetchData.returnsObjectsAsFaults = false
            
            fetchData.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            do {
                podcasts = try context.fetch(fetchData)
            } catch {}
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    @IBAction func AddPodcastButton_Click(_ sender: Any) {
        
        if let url = URL(string: self.podcastURLTextField.stringValue) {
            URLSession.shared.dataTask(with: url) { (data: Data?, response:URLResponse?, error:Error?) in
                if error != nil {
                    print(error)
                }else {
                    if data != nil {
                        let parser = PodcastParser()
                        let info = parser.getPodcastMetaData(data: data!)
                        
                        if !self.podcastExists(rssURL: url.absoluteString) {
                            if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                                
                                let podcast = Podcast(context: context)
                                
                                podcast.rssURL = url.absoluteString
                                podcast.imageURL = info.imageURL
                                podcast.title = info.title
                                podcast.owner = info.owner
                                
                                (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
                                
                                self.getPodcasts()
                            }
                        } else {
                            DispatchQueue.main.async {
                                let alert = NSAlert.init()
                                alert.window.title = "Error"
                                alert.messageText = "Error"
                                alert.informativeText = "This podcast already exists in your list"
                                alert.addButton(withTitle: "OK")
                                alert.addButton(withTitle: "Cancel")
                                alert.runModal()
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.podcastURLTextField.stringValue = ""
                        }
                    }
                }
            }.resume()
        }
    }
    
    func podcastExists(rssURL:String) -> Bool {
        
        if let context = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            let fetchData = Podcast.fetchRequest() as NSFetchRequest<Podcast>
            fetchData.predicate = NSPredicate(format: "rssURL == %@", rssURL)
            
            do {
                let matchingPodcasts = try context.fetch(fetchData)
                
                if matchingPodcasts.count >= 1 {
                    return true
                }
            } catch {}
            
        }
        
        return false
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.podcasts.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("podcastCell"), owner: self) as? NSTableCellView
        
        let podcast = self.podcasts[row]
        
        if podcast.title != nil {
            cell?.textField?.stringValue = podcast.title!
        }else{
            cell?.textField?.stringValue = "Unknown title"
        }
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow >= 0 {
            let podcast = podcasts[tableView.selectedRow]
            
            episodeVC?.podcast = podcast
            episodeVC?.updateView()
        }
    }
    
    
}
