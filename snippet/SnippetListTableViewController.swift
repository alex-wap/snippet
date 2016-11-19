//
//  ViewController.swift
//  snippet
//
//  Created by Elliot Young on 9/27/16.
//  Copyright © 2016 Elliot Young. All rights reserved.
//

import UIKit
import CoreData
//Global Variables
let pasteBoard = UIPasteboard.general
class SnippetListTableViewController: UITableViewController, EditSnippetDelegate, CancelButtonDelegate {
    //
    //OUTLETS
    @IBAction func newSnippetButtonPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "editSnippetSegue", sender: sender)
    }
    //OUTLETS
    //
    //
    //VARIABLES
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var snippetsArray = [Snippets]()
    var filteredSnippetsArray = [Snippets]()
    let searchController = UISearchController(searchResultsController: nil)
    let dateFormatter = DateFormatter()
    //VARIABLES
    //
    //
    //VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
//        dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy h:mma"
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        fetchAllSnippets()
        tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        fetchAllSnippets()
        tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //VIEW DID LOAD
    //
    //
    //TABLE VIEW FUNCTIONS
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredSnippetsArray.count
        }
        return snippetsArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "prototypecell") as! SnippetTableViewCell
        let snippetToUse: Snippets
        if searchController.isActive && searchController.searchBar.text != "" {
            snippetToUse = filteredSnippetsArray[(indexPath as NSIndexPath).row]
        } else {
            snippetToUse = snippetsArray[(indexPath as NSIndexPath).row]
        }
        cell.snippetTextLabel.text = snippetsArray[(indexPath as NSIndexPath).row].snippetTitle
        cell.snippetForCell = snippetsArray[(indexPath as NSIndexPath).row]
        cell.snippetDateLabel.text = dateFormatter.string(from: cell.snippetForCell!.dateCreated! as Date)
        return cell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let celltapped = tableView.cellForRow(at: indexPath) as! SnippetTableViewCell
        managedObjectContext.delete(celltapped.snippetForCell!)
        saveNotes()
        fetchAllSnippets()
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editSnippetSegue", sender: indexPath)
    }
    //TABLE VIEW FUNCTIONS
    //
    //
    //
    //CORE DATA FUNCTIONS
    func fetchAllSnippets(){
        let snippetsRequest = NSFetchRequest(entityName: "Snippets")
        do {
            // get the results by executing the fetch request we made earlier
            let results = try managedObjectContext.fetch(snippetsRequest)
            snippetsArray = results as! [Snippets]
            snippetsArray = sortTableByRecentlyEdited(snippetsArray)
        } catch {
            // print the error if it is caught (Swift automatically saves the error in "error")
            print("\(error)")
        }
    }
    func saveNotes(){
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                print("Success")
            } catch {
                print("\(error)")
            }
        }
    }
    //CORE DATA FUNCTIONS
    //
    //
    //DATE TIME FUNCTIONS
    func sortTableByRecentlyEdited(_ snippets:[Snippets]) -> [Snippets]{
        var count = snippets.count-1
        var newSnippetsArray = snippets
        while(count>0){
            for i in 0...count-1{
                print("array at \(i):")
                print(newSnippetsArray[i].dateUpdated)
                print("array at \(i+1):")
                print(newSnippetsArray[i+1].dateUpdated)
                if newSnippetsArray[i].dateUpdated!.compare(newSnippetsArray[i+1].dateUpdated! as Date) == ComparisonResult.orderedAscending{
                    let temp = newSnippetsArray[i]
                    newSnippetsArray[i] = newSnippetsArray[i+1]
                    newSnippetsArray[i+1] = temp
                    print("swapped values")
                }
            }
            count = count-1
        }
        return newSnippetsArray
    }
    //DATE TIME FUNCTIONS
    //
    //
    //SEGUE FUNCTIONS
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSnippetSegue" {
            let navigationController = segue.destination as! UINavigationController
            let destinationController = navigationController.topViewController as! EditSnippetViewController
            destinationController.editSnippetDelegate = self
            destinationController.cancelButtonDelegate = self
            if sender is NSIndexPath {
                let celltapped = tableView.cellForRow(at: sender as! IndexPath) as! SnippetTableViewCell
                destinationController.recievedSnippetTextToEdit = celltapped.snippetForCell?.snippetText
                destinationController.snippetToEdit = celltapped.snippetForCell
                destinationController.recievedSnippetTitleToEdit = celltapped.snippetForCell?.snippetTitle
            }
            else if sender is UIBarButtonItem{
               //optional logic here for the "add new snippet" button. Currently everything is handled and it works without needing any logic here.
            }
        }
    }
    //SEGUE FUNCTIONS
    //
    //
    //DELEGATE FUNCTIONS
    func editSnippetDelegate(_ newSnippetText:String, newSnippetTitle:String){
        let newSnippet = NSEntityDescription.insertNewObject(forEntityName: "Snippets", into: managedObjectContext) as! Snippets
        print("An Object was Added to Core Data")
        newSnippet.snippetText = newSnippetText
        newSnippet.snippetTitle = newSnippetTitle
        newSnippet.dateCreated = Date()
        newSnippet.dateUpdated = Date()
        saveNotes()
        fetchAllSnippets()
        tableView.reloadData()
    }
    func editSnippetDelegate(_ editedSnippetText:String, editedSnippetTitle:String, snippetToEdit:Snippets){
        snippetToEdit.snippetText = editedSnippetText
        snippetToEdit.snippetTitle = editedSnippetTitle
        snippetToEdit.dateUpdated = Date()
        saveNotes()
        fetchAllSnippets()
        tableView.reloadData()
    }
    func cancelButtonPressedFrom(_ sender: UIViewController){
        dismiss(animated: true, completion: nil)
    }
    //DELEGATE FUNCTIONS
    //
    //
    //SEARCH BAR FUNCTIONS
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredSnippetsArray = snippetsArray.filter { snippet in
            return snippet.snippetTitle!.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    //SEARCH BAR FUNCTIONS
    //
}
extension SnippetListTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

