//
//  NotebookListVC.swift
//  Everpobre
//
//  Created by Rafael Lujan on 1/4/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//

import UIKit
import CoreData

protocol NotebookListDelegate {
    func didSetDefaultNotebook(notebook: NoteBook)
}

class NotebookListVC: UITableViewController {
    
    var delegate: NotebookListDelegate?
    var notebooks = [NoteBook]()
    var nameTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()        
        //self.notebooks = DataManager.sharedManager.fetchNotebooks()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Notebooks"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "add").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleAddNotebook))
        navigationController?.navigationBar.tintColor = UIColor.blueMidNight
        navigationController?.navigationBar.barTintColor = UIColor.emerald
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.blueMidNight, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 24)]
    }
    
    @objc func handleAddNotebook() {
        let alertController = UIAlertController(title: "Add New Notebook", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (alert) in
            if let name = self.nameTextField?.text {
                DispatchQueue.global(qos: .background).async {
                    let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    privateMOC.parent = DataManager.sharedManager.persistentContainer.viewContext
                    let notebook = NSEntityDescription.insertNewObject(forEntityName: "NoteBook", into: privateMOC) as! NoteBook
                    notebook.name = name
                    notebook.defaultNotebook = false
                    try! privateMOC.save()
                    DispatchQueue.main.async {
                        self.notebooks = DataManager.sharedManager.fetchNotebooks()
                        self.tableView.reloadData()
                    }
                }
                //_ = DataManager.sharedManager.createNotebook(name: name)
                
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addTextField { (textfield) in
            self.nameTextField = textfield
            self.nameTextField?.placeholder = "Enter the notebook´s name"
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
}
