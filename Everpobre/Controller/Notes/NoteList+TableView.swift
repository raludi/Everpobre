//
//  NoteList+TableView.swift
//  Everpobre
//
//  Created by Rafael Lujan on 1/4/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//

import UIKit

class IndentLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        let customRect = UIEdgeInsetsInsetRect(rect, insets)
        super.drawText(in: customRect)
    }
    
}

extension NoteListViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentLabel()
        if let name = self.notebooks[section].name {
            label.text = "Notebook: \(name)"
        }
        label.backgroundColor = UIColor.blueMidNight
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.notebooks.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.notebooks[section].notes?.count)!
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
        self.notebooks.forEach { (notebook) in
            alertController.addAction(UIAlertAction(title: notebook.name, style: .default) { (action) in
                let context = DataManager.sharedManager.persistentContainer.viewContext
                let note = self.notebooks[indexPath.section].notes?.allObjects[indexPath.row] as? Note
                note?.notebook = notebook
                do {
                    try context.save()
                } catch let saveErr {
                    print("Failed to edit note:", saveErr)
                }
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancel)
        if let popoverController = alertController.popoverPresentationController {//popover es el modal pero para ipad
            //popoverController.barButtonItem = sender -> Aqui hacemos que salga encima del botón pero en nuestro caso lo queremos en el centro:
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(alertController, animated: true, completion: nil)
    }
    
    private func handleDeleteNote(action: UITableViewRowAction, indexPath: IndexPath) {
        print("Deleting note...")
        let note = self.notebooks[indexPath.section].notes?.allObjects[indexPath.row] as? Note
        //delete from CoreData
        let context = DataManager.sharedManager.persistentContainer.viewContext
        context.delete(note!)
        do {
            try context.save()
        } catch let saveErr {
            print("Failed to delete note:", saveErr)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId)
            ?? UITableViewCell(style: .default, reuseIdentifier: cellId)
        let note = self.notebooks[indexPath.section].notes?.allObjects[indexPath.row] as! Note
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
        noteDetailVC.note = self.notebooks[indexPath.section].notes?.allObjects[indexPath.row] as? Note
        noteDetailVC.delegate = self
        if UIDevice.current.userInterfaceIdiom == .pad {
            splitViewController?.showDetailViewController(noteDetailVC.wrappedNavigation(), sender: nil)
        } else {
            navigationController?.pushViewController(noteDetailVC, animated: true)
        }
        
    }
    
}
