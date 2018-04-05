//
//  DataManager.swift
//  Everpobre
//
//  Created by Rafael Lujan on 12/3/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//

import UIKit
import CoreData

class DataManager: NSObject {
    
    static let sharedManager = DataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "EverpobreModel")
        container.loadPersistentStores(completionHandler: { (storeDescription,error) in
            
            if let err = error {
                // Error to handle.
                print(err)
            }
            //Para llevarse los cambios de background al hilo principal
            container.viewContext.automaticallyMergesChangesFromParent = true
        })
        return container
    }()
    
    func fetchNotebooks() -> [NoteBook] {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NoteBook>(entityName: "NoteBook")
        do {
            let notebooks = try context.fetch(fetchRequest)
            return notebooks
        } catch let fetchErr {
            print("Failed to fetch notes: ", fetchErr)
            return []
        }
    }
    
    func fetchNotes() -> [Note] {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        do {
            let notes = try context.fetch(fetchRequest)
            return notes
        } catch let fetchErr {
            print("Failed to fetch notes: ", fetchErr)
            return []
        }
    }
    
    func createNotebook(name: String) -> NoteBook? {
        let context = persistentContainer.viewContext
        let notebook = NSEntityDescription.insertNewObject(forEntityName: "NoteBook", into: context) as! NoteBook
        notebook.name = name
        do {
            try context.save()
            return notebook
        } catch let err {
            print("Failed to create a new notebook: ", err)
            return nil
        }
    }
    
    func createNote(notebook: NoteBook) -> (Note?,Error?) {
        let context = persistentContainer.viewContext
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        note.title = "New Note"
        note.body = "Write here..."
        note.creationDate = Date()
        note.modificationDate = Date()
        note.notebook = notebook
        
        do {
            try context.save()
            return (note, nil)
        } catch let err {
            print("Failed to create a new note: ", err)
            return (nil, err)
        }
    }
}
