//
//  editSnippetDelegate.swift
//  snippet
//
//  Created by Elliot Young on 9/28/16.
//  Copyright © 2016 Elliot Young. All rights reserved.
//

import UIKit

protocol EditSnippetDelegate:class{
    func editSnippetDelegate(_ newSnippetText:String, newSnippetTitle:String)
    func editSnippetDelegate(_ editedSnippetText:String, editedSnippetTitle:String, snippetToEdit: Snippets)
}
