//
//  NoteViewByCodeGestures2Controller.swift
//  Everpobre
//
//  Created by Rafael Lujan on 11/3/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//

import UIKit

class NoteViewByCodeGestures2Controller: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {

    // MARK: - Outlets
    
    // MARK: - Properties
    let dateLabel = UILabel()
    let expirationDate = UILabel()
    let titleTextField = UITextField()
    let noteTextView = UITextView()
    let imageView = UIImageView()
    
    var topImgConstraint: NSLayoutConstraint!
    var bottomImgConstraint: NSLayoutConstraint!
    var leftImgConstraint: NSLayoutConstraint!
    var rightImgConstraint: NSLayoutConstraint!
    
    var relativePoint: CGPoint!
    
    var note: Note?
    // MARK: - Life cycle
    override func loadView() {
        let backView = UIView()
        backView.backgroundColor = .white
        //Configuro label
        dateLabel.text = "25/02/2018"
        expirationDate.text = "03/03/2018"
        //Añado label
        backView.addSubview(dateLabel)
        backView.addSubview(expirationDate)
        //Configuro textField
        titleTextField.text = "Default Note"
        //Añado textField
        backView.addSubview(titleTextField)
        //Configuro noteTextView
        noteTextView.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        //Añado noteTextView
        backView.addSubview(noteTextView)
        //Configure imageView
        imageView.backgroundColor = .red
        backView.addSubview(imageView)
        // MARK: - Autolayout
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        expirationDate.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        //Visual Format (mirar guia apple)
        
        let viewDict = ["dateLabel": dateLabel, "titleTextField": titleTextField, "noteTextView": noteTextView, "expirationDate": expirationDate]
        //Horizontal
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-10-[titleTextField]-10-[expirationDate]-10-[dateLabel]-10-|", options: [], metrics: nil, views: viewDict)
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-10-[noteTextView]-10-|", options: [], metrics: nil, views: viewDict))
        
        //Verticals
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[dateLabel]-10-[noteTextView]-10-|", options: [], metrics: nil, views: viewDict))
        //Safe Area
        constraints.append(NSLayoutConstraint(item: dateLabel, attribute: .top, relatedBy: .equal, toItem: backView.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 10))
        //Alternativa
        //dateLabel.topAnchor.constraint(equalTo: backView.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        //Igualar a nivel de texto
        constraints.append(NSLayoutConstraint(item: titleTextField, attribute: .lastBaseline, relatedBy: .equal, toItem: dateLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: expirationDate, attribute: .lastBaseline, relatedBy: .equal, toItem: dateLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
        //ImageView
        var imgConstraints = [NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 100)]//ancho
        imgConstraints.append(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 150))//alto
        topImgConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: noteTextView, attribute: .top, multiplier: 1, constant: 20)
        bottomImgConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: noteTextView, attribute: .bottom, multiplier: 1, constant: -20)//menos porque quiero que este 20 más arriba
        leftImgConstraint = NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: noteTextView, attribute: .left, multiplier: 1, constant: 20)
        rightImgConstraint = NSLayoutConstraint(item: imageView, attribute: .right, relatedBy: .equal, toItem: noteTextView, attribute: .right, multiplier: 1, constant: -20)
        imgConstraints.append(contentsOf: [topImgConstraint, bottomImgConstraint, leftImgConstraint, rightImgConstraint])
        
        backView.addConstraints(constraints)
        backView.addConstraints(imgConstraints)
        NSLayoutConstraint.deactivate([bottomImgConstraint, rightImgConstraint])
        self.view = backView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        //Toolbar
        navigationController?.isToolbarHidden = false
        let photoBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(catchPhoto))
        //Este espacio es para dejar entre los botones unicamente
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//mirar más
        let mapBarButton = UIBarButtonItem(title: "Map", style: .done, target: self, action: #selector(addLocation))
        self.setToolbarItems([photoBarButton, flexible, mapBarButton], animated: false)
        
        //Para que no aparezca el teclado, ya que le quitamos la respuesta
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeKeyboard))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
        
        imageView.isUserInteractionEnabled = true//imageView es la unica vista que necesita activar gestos
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(moveImageWhereYouWant))
        imageView.addGestureRecognizer(longPressGesture)
        
        
        //MARK: - Notes Model
        if let note = note {
            titleTextField.text = note.title
            noteTextView.text = note.body
        }
    }
    
    //ARRASTRAR LA IMAGEN
    @objc func moveImageWhereYouWant(longPressGesture: UILongPressGestureRecognizer) {
        switch longPressGesture.state {
            case .began:
                closeKeyboard()
                relativePoint = longPressGesture.location(in: imageView)
                UIView.animate(withDuration: 0.2, animations: {
                    self.imageView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
                })
                break
            case .changed:
                let location = longPressGesture.location(in: noteTextView)
                leftImgConstraint.constant = location.x - relativePoint.x
                topImgConstraint.constant = location.y - relativePoint.y
                break
            case .ended, .cancelled:
                UIView.animate(withDuration: 0.2, animations: {
                    self.imageView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                })
                break
            default:
                break
        }

    }
    
    @objc func closeKeyboard() {
        if noteTextView.isFirstResponder {
            noteTextView .resignFirstResponder()
        } else if titleTextField.isFirstResponder {
            titleTextField.resignFirstResponder()
        }
    }
    
    //Aqui es donde digo al texto que se reposicione, excluimos un frame de otro
    override func viewDidLayoutSubviews() {
        var imgRectangle = view.convert(imageView.frame, to: noteTextView)
        imgRectangle = imgRectangle.insetBy(dx: -15, dy: -15)//Con esto le metemos margen al rectangulo de la imagen
        let paths = UIBezierPath(rect: imgRectangle)
        noteTextView.textContainer.exclusionPaths = [paths]
    }
    
    // MARK: - MAP
    
    @objc func addLocation() {
        //TODO:
    }
    
    // MARK: - Toolbar button camera
    
    @objc func catchPhoto() {
        let actionSheetAlert = UIAlertController(title: NSLocalizedString("Add photo", comment: "Add photo"), message: nil, preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let useCamera = UIAlertAction(title: "Camera", style: .default, handler: {
            (alertAction) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        })
        let usePhotoLibrary = UIAlertAction(title: "Photo Library", style: .default, handler: {
            (alertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        })
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        actionSheetAlert.addAction(useCamera)
        actionSheetAlert.addAction(usePhotoLibrary)
        actionSheetAlert.addAction(cancel)
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    // MARK: - Image Picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        //Para quitar luego la galería
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        note?.title = textField.text
        try! note?.managedObjectContext?.save()
    }
}
