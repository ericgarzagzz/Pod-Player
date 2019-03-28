//
//  EpisodeCell.swift
//  Pod Player
//
//  Created by Eric Garza Gonzalez on 04/09/18.
//  Copyright © 2018 Eric Garza Gonzalez. All rights reserved.
//

import Cocoa
import WebKit

class EpisodeCell: NSTableCellView {

    @IBOutlet weak var TitleLabel: NSTextField!
    @IBOutlet weak var DateLabel: NSTextField!
    @IBOutlet weak var DescriptionWV: WKWebView!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
