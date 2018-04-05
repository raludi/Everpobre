//
//  NoteListViewController.swift
//  Everpobre
//
//  Created by Rafael Lujan on 21/3/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//

import UIKit
import CoreData

class NoteListViewController: UITableViewController {

    //var notes = [Note]()
    var notesArray = [[Note]]()
    var sectionsName = [String]()
    var defaultNotebook: NoteBook?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchSections()
        //self.notes = DataManager.sharedManager.fetchNotes()
        //self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupNavigationBar()
        
        navigationController?.isToolbarHidden = false
        let operationsNotebook = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(handleNotebooks))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//mirar más
        let fastAdd = UIBarButtonItem(title: "Sticky note", style: .done, target: self, action: #selector(handleAddStickyNote))
        operationsNotebook.tintColor = UIColor.emerald
        fastAdd.tintColor = UIColor.emerald
        self.setToolbarItems([operationsNotebook, flexible, fastAdd], animated: false)
        
        fetchSections()
    }
    
    @objc func handleAddNote() {
        print("Added new note...")
        let alertController = UIAlertController(title: "Choose Notebook", message: nil, preferredStyle: .actionSheet)

        let notebooks = DataManager.sharedManager.fetchNotebooks()
        notebooks.forEach { (notebook) in
            alertController.addAction(UIAlertAction(title: notebook.name, style: .default) { (action) in
                _ = DataManager.sharedManager.createNote(notebook: notebook)
                //self.notes = DataManager.sharedManager.fetchNotes()
                self.fetchSections()
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func handleNotebooks() {
        let notebookController = NotebookListVC()
        notebookController.delegate = self
        navigationController?.pushViewController(notebookController, animated: true)
    }
    
    @objc func handleAddStickyNote() {
        if let defaultNotebook = defaultNotebook {
            let _ = DataManager.sharedManager.createNote(notebook: defaultNotebook)
            //if let note = note.0 {
                //notes.append(note)
                fetchSections()
            //}
        }
    }
    
}

// MARK: - Personalize View
extension NoteListViewController {
    
    private func setupNavigationBar() {
        navigationItem.title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "add").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleAddNote))
        navigationController?.navigationBar.tintColor = UIColor.emerald
        navigationController?.navigationBar.barTintColor = UIColor.emerald
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.blueMidNight, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 24)]
    }

}

 // MARK: - NoteDetailDelegate
extension NoteListViewController: NoteControllerDelegate {
    
    func didEditNote() {
        self.tableView.reloadData()
    }

}

// MARK: - NotebookListDelegate
extension NoteListViewController: NotebookListDelegate {
    
    func didSetDefaultNotebook(notebook: NoteBook) {
        defaultNotebook = notebook
    }
    
}
