//
//  NoteDetailViewController.swift
//  Everpobre
//
//  Created by Rafael Lujan on 17/3/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//

//
//  NoteViewByCodeGestures2Controller.swift
//  Everpobre
//
//  Created by Rafael Lujan on 11/3/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Contacts

class NoteDetailViewController: UIViewController, UINavigationControllerDelegate  {

    // MARK: - Properties
    let dateLabel: UILabel = {
        let date = UILabel()
        date.text = "25/02/2018"
        date.translatesAutoresizingMaskIntoConstraints = false
        return date
    }()
    let expirationDate: UILabel = {
        let date = UILabel()
        date.text = "03/03/2018"
        date.translatesAutoresizingMaskIntoConstraints = false
        return date
    }()
    let titleTextField: UITextField = {
        let textView = UITextField()
        textView.text = "Default Note"
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    let noteTextView: UITextView = {
        let textView = UITextView()
        textView.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    let imageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .red
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isUserInteractionEnabled = true//Habilitamos los gestos
        return image
    }()
    let mapView: MKMapView = {
        let map = MKMapView()
        map.isHidden = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    var topImgConstraint: NSLayoutConstraint!
    var leftImgConstraint: NSLayoutConstraint!
    var relativePoint: CGPoint!
    
    //Variables de modelo
    var note: Note?
    var notebook : NoteBook?
    
    // MARK: - Life cycle
    override func loadView() {
        let backView = UIView()
        backView.backgroundColor = .white
        backView.addSubview(noteTextView)
        backView.addSubview(imageView)
        backView.addSubview(mapView)
        //Set Autolayout
        setUpAutoLayoutNew(backView)
        self.view = backView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //imageView.isHidden = true
        titleTextField.delegate = self
//        mapView.delegate = self
        // MARK: - TOOLBAR
        navigationController?.isToolbarHidden = false
        let photoBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(catchPhoto))
        //Este espacio es para dejar entre los botones unicamente
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//mirar más
        let mapBarButton = UIBarButtonItem(title: "Map", style: .done, target: self, action: #selector(addLocation))
        self.setToolbarItems([photoBarButton, flexible, mapBarButton], animated: false)
        
        // MARK: - SWIP PARA OCULTAR TECLADO
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeKeyboard))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
        
        // MARK: - MANTENER PULSADO
    
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(moveImageWhereYouWant))
        imageView.addGestureRecognizer(longPressGesture)
        
        // MARK: - DOBLE TOQUE
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(rotateImage))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)
        
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
    
    @objc func rotateImage() {
        closeKeyboard()
        UIView.animate(withDuration: 1) {
            self.imageView.transform = CGAffineTransform.init(rotationAngle: 45 * .pi / 45)
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
        let initialCoord = CLLocationCoordinate2D(latitude: 40.42, longitude: -3.7035)
        //El span vale para el zoom hacia la dirección
        let region = MKCoordinateRegion(center: initialCoord, span: MKCoordinateSpan.init(latitudeDelta: 0.4, longitudeDelta: 0.4))
        mapView.setRegion(region, animated: true)
        mapView.isHidden = false
    }
    
    // MARK: - Toolbar button camera
    @objc func catchPhoto(_ sender: UIBarButtonItem) {
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
        if let popoverController = actionSheetAlert.popoverPresentationController {//popover es el modal pero para ipad
            //popoverController.barButtonItem = sender -> Aqui hacemos que salga encima del botón pero en nuestro caso lo queremos en el centro:
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(actionSheetAlert, animated: true, completion: nil)
    }
}

extension NoteDetailViewController: UITextFieldDelegate {
    // MARK: - TextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        note?.title = textField.text
        try! note?.managedObjectContext?.save()
    }
}

extension NoteDetailViewController: UIImagePickerControllerDelegate {
    // MARK: - Image Picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        //Para quitar luego la galería
        imageView.isHidden = false
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - AUTOLAYOUT
extension NoteDetailViewController {
    func setUpAutoLayoutNew(_ backView: UIView) {
        let headerContainerView = UIView()
//        let bodyContainerView = UIView()
//        let mapContainerView = UIView()
        backView.addSubview(headerContainerView)
        //HEADERCOINTERVIEW
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.widthAnchor.constraint(equalTo: backView.widthAnchor).isActive = true
        headerContainerView.heightAnchor.constraint(equalTo: backView.heightAnchor, multiplier: 0.2).isActive = true
        headerContainerView.leftAnchor.constraint(equalTo: backView.leftAnchor).isActive = true;
        headerContainerView.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true;
        headerContainerView.addSubview(titleTextField)
        headerContainerView.addSubview(expirationDate)
        headerContainerView.addSubview(dateLabel)
        //TitleText
        titleTextField.topAnchor.constraint(equalTo: headerContainerView.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        titleTextField.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -10).isActive = true
        titleTextField.leftAnchor.constraint(equalTo: headerContainerView.leftAnchor, constant: 10).isActive = true
        titleTextField.widthAnchor.constraint(equalTo: headerContainerView.widthAnchor, multiplier: 0.45).isActive = true
        //titleTextField.rightAnchor.constraint(equalTo: expirationDate.leftAnchor, constant: -10).isActive = true
        //ExpirationDate
        expirationDate.topAnchor.constraint(equalTo: headerContainerView.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        expirationDate.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -10).isActive = true
        expirationDate.rightAnchor.constraint(equalTo: dateLabel.leftAnchor, constant: -10).isActive = true
        //expirationDate.leftAnchor.constraint(equalTo: titleTextField.rightAnchor, constant: 10).isActive = true
        expirationDate.lastBaselineAnchor.constraint(equalTo: titleTextField.lastBaselineAnchor).isActive = true
        //DateLabel
        dateLabel.topAnchor.constraint(equalTo: headerContainerView.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -10).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: headerContainerView.rightAnchor, constant: -10).isActive = true
        dateLabel.lastBaselineAnchor.constraint(equalTo: titleTextField.lastBaselineAnchor).isActive = true
        //MAIN VIEW
        //NoteText
        noteTextView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: 10).isActive = true
        noteTextView.leftAnchor.constraint(equalTo: backView.leftAnchor, constant: 10).isActive = true
        noteTextView.rightAnchor.constraint(equalTo: backView.rightAnchor, constant: -10).isActive = true
        noteTextView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -30).isActive = true
        //Image
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        topImgConstraint = imageView.topAnchor.constraint(equalTo: noteTextView.topAnchor, constant: 20)
        topImgConstraint.isActive = true
        imageView.bottomAnchor.constraint(equalTo: noteTextView.bottomAnchor, constant: -20)
        leftImgConstraint = imageView.leftAnchor.constraint(equalTo: noteTextView.leftAnchor, constant: 20)
        leftImgConstraint.isActive = true
        //map
        mapView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -70).isActive = true
        mapView.leftAnchor.constraint(equalTo: backView.leftAnchor, constant: 10).isActive = true
       // mapView.rightAnchor.constraint(equalTo: backView.rightAnchor, constant: -10).isActive = true
        mapView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        mapView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}



