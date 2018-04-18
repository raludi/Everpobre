//
//  NotebooListVC+TableView.swift
//  Everpobre
//
//  Created by Rafael Lujan on 1/4/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//

import UIKit

extension NotebookListVC {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId)
            ?? UITableViewCell(style: .default, reuseIdentifier: cellId)
        let notebook = notebooks[indexPath.row]
        if let name = notebook.name, let notes = notebook.notes {
              cell.textLabel?.text = "\(name) - Number of notes: \(notes.count)"
        } else {
            cell.textLabel?.text = notebook.name
        }
      
        cell.textLabel?.textColor = UIColor.blueMidNight
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notebooks.count
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let defaultAction = UITableViewRowAction(style: .default, title: "Default Notebook", handler: setDefaultNotebook)
        defaultAction.backgroundColor = UIColor.blueMidNight
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: handleDeleteNotebook)
        return [deleteAction,defaultAction]
    }
    
    private func setDefaultNotebook(action: UITableViewRowAction, indexPath: IndexPath) {
        print("Setting notebook as default...")
        let notebook = self.notebooks[indexPath.row]
        delegate?.didSetDefaultNotebook(notebook: notebook)
    }
    
    private func handleDeleteNotebook(action: UITableViewRowAction, indexPath: IndexPath) {
        print("Deleting notebook...")
        let messageTitle = "Choose if you want to delete all your notes or move to another notebook"
        let alertController = UIAlertController(title: messageTitle, message: nil, preferredStyle: .actionSheet)
        self.notebooks.forEach { (notebook) in
            if notebooks[indexPath.row].name != notebook.name {
                alertController.addAction(UIAlertAction(title: notebook.name, style: .default) { (action) in
                    let context = DataManager.sharedManager.persistentContainer.viewContext
                    let notes = self.notebooks[indexPath.row].notes?.allObjects as? [Note]
                    if let notes = notes {
                        notes.forEach({ (note) in
                            note.notebook = notebook
                        })
                        context.delete(self.notebooks[indexPath.row])
                        try! context.save()
                    }
                    self.notebooks = DataManager.sharedManager.fetchNotebooks()
                    self.tableView.reloadData()
                })
            }
        }
        alertController.addAction(UIAlertAction(title: "Delete all", style: .destructive, handler: { (action) in
            let notebook = self.notebooks[indexPath.row]
            self.notebooks.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            //delete from CoreData
            let context = DataManager.sharedManager.persistentContainer.viewContext
            context.delete(notebook)
            do {
                try context.save()//Esto hace que se guarde el delete
            } catch let saveErr {
                print("Failed to delete note:", saveErr)
            }
        }))
        present(alertController, animated: true, completion: nil)
    }
    
}
