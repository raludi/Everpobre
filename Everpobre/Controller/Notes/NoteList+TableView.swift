//
//  NoteList+TableView.swift
//  Everpobre
//
//  Created by Rafael Lujan on 1/4/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//

import UIKit

extension NoteListViewController {
    
    /*override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Test"
        label.backgroundColor = .gray
        label.textColor = UIColor.blueMidNight
        return label
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.notesArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notesArray[section].count
    }
    
    func fetchHeaders() {
        let notebooks = DataManager.sharedManager.fetchNotebooks()
        notebooks.forEach { (notebook) in
            if let notes = notebook.notes {
                self.notesArray.append((notes.allObjects as? [Note])!)
            }
        }
    }*/
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let moveAction = UITableViewRowAction(style: .default, title: "Move", handler: moveToAnotherNotebook)
        moveAction.backgroundColor = UIColor.blueMidNight
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: handleDeleteNote)
        return [deleteAction,moveAction]
    }
    
    private func moveToAnotherNotebook(action: UITableViewRowAction, indexPath: IndexPath)  {
        print("Moving note to another notebook...")
        let alertController = UIAlertController(title: "Choose Notebook", message: nil, preferredStyle: .actionSheet)
        
        let notebooks = DataManager.sharedManager.fetchNotebooks()
        notebooks.forEach { (notebook) in
            alertController.addAction(UIAlertAction(title: notebook.name, style: .default) { (action) in
                let context = DataManager.sharedManager.persistentContainer.viewContext
                let note = self.notes[indexPath.row]
                note.notebook = notebook
                do {
                    try context.save()
                } catch let saveErr {
                    print("Failed to edit note:", saveErr)
                }
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    private func handleDeleteNote(action: UITableViewRowAction, indexPath: IndexPath) {
        print("Deleting note...")
//        let note = self.notesArray[indexPath.section][indexPath.row]
//        self.notesArray.remove(at: [indexPath.section][indexPath.row])
        let note = self.notes[indexPath.row]
        self.notes.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        
        //delete from CoreData
        let context = DataManager.sharedManager.persistentContainer.viewContext
        context.delete(note)
        do {
            try context.save()//Esto hace que se guarde el delete
        } catch let saveErr {
            print("Failed to delete note:", saveErr)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId)
            ?? UITableViewCell(style: .default, reuseIdentifier: cellId)

        let note = notes[indexPath.row]
        //let note = self.notesArray[indexPath.section][indexPath.row]
        
        if let name = note.title, let date = note.creationDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, yyyy"
            cell.textLabel?.text = "\(name) - Created at: \(dateFormatter.string(from: date))"
        } else {
            cell.textLabel?.text = note.title
        }
        
        cell.textLabel?.textColor = UIColor.blueMidNight
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return cell
    }
    
   
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let noteDetailVC = NoteController()
        noteDetailVC.note = notes[indexPath.row]
        noteDetailVC.delegate = self
        navigationController?.pushViewController(noteDetailVC, animated: true)
    }
    
}
