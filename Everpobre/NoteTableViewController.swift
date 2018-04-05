//
//  NoteTableViewController.swift
//  Everpobre
//
//  Created by Rafael Lujan on 12/3/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//

import UIKit
import CoreData

let LAST_NOTE = "LastNote"

final class NoteTableViewController: UITableViewController {
    
    var fetchedResultController: NSFetchedResultsController<Note>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        
        // Fetch Request
        let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
        
        //Creamos objeto
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        
        // 3.- (Opcional) Si queremos un orden tenemos que anhadir esta parte
        let sortByDate = NSSortDescriptor(key: "createdAt", ascending: true)
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortByDate, sortByTitle]
        
        // 4.- (Opcional) Filtrado. Usamos un predicado
        let created24H = Date().timeIntervalSince1970 - 24 * 3600
        let predicate = NSPredicate(format: "createdAt >= %f", created24H)
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 25 //Limitamos a 25 las peticiones
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewMOC, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchedResultController.performFetch()
        fetchedResultController.delegate = self
        // 5.- Ejecutamos la request
        //try! noteList = viewMOC.fetch(fetchRequest)
    }
    
    // MARK: - Private methods
    @objc private func addNewNote() {
        
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        privateMOC.perform {
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: privateMOC) as! Note
            //KVC
            let dict = ["testTitle": "New Note from KVC", "createdAt": Date().timeIntervalSince1970] as [String : Any]
            // Lo guardamos
            note.setValuesForKeys(dict)
            try! privateMOC.save()
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension NoteTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
         return fetchedResultController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultController.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = fetchedResultController.object(at: indexPath).title
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let noteVC = NoteDetailViewController()
        noteVC.note = fetchedResultController.object(at: indexPath)
        if UIDevice.current.userInterfaceIdiom == .pad {
            showDetailViewController(noteVC, sender: nil)
        } else {
            navigationController?.pushViewController(noteVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Borrar en database
            //tableView.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension NoteTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}


