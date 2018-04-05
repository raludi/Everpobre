//
//  NoteController.swift
//  Everpobre
//
//  Created by Rafael Lujan on 28/3/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//

import UIKit

protocol NoteControllerDelegate {
    func didEditNote()
}

class NoteController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var modificationDate: UILabel!
    @IBOutlet weak var creationDate: UILabel!
    @IBOutlet weak var bodyText: UITextView!
    
    // MARK: - Properties
    var note: Note?
    var delegate: NoteControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        titleTextField.delegate = self
        titleTextField.text = note?.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        creationDate.text = dateFormatter.string(from: (note?.creationDate)!)
        modificationDate.text = dateFormatter.string(from: (note?.modificationDate)!)
        bodyText.text = note?.body
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleUpdateNote))
    }

    @objc private func handleUpdateNote() {
        print("Updating note...")
    }

}

extension NoteController: UITextFieldDelegate {
   
    func textFieldDidEndEditing(_ textField: UITextField) {
         print("Title Edited")
        let context = DataManager.sharedManager.persistentContainer.viewContext
        note?.title = titleTextField.text
        do {
            try context.save()
            delegate?.didEditNote()
        } catch let saveErr {
            print("Failed to edit note:", saveErr)
        }
    }
}

extension NoteController {
    
    private func setupNavigationBar() {
        navigationItem.title = "Note Detail"
        navigationController?.navigationBar.tintColor = UIColor.blueMidNight
    }
    
}
