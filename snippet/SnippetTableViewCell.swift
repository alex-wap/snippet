//
//  SnippetTableViewCell.swift
//  snippet
//
//  Created by Elliot Young on 9/27/16.
//  Copyright © 2016 Elliot Young. All rights reserved.
//

import UIKit
class SnippetTableViewCell: UITableViewCell{
    @IBOutlet weak var snippetTextLabel: UILabel!
    @IBOutlet weak var snippetDateLabel: UILabel!
    weak var snippetForCell:Snippets?
}
