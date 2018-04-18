//
//  NoteController.swift
//  Everpobre
//
//  Created by Rafael Lujan on 28/3/18.
//  Copyright © 2018 Rafael Lujan. All rights reserved.
//

import UIKit
import CoreData

protocol NoteControllerDelegate {
    func didEditNote(note: Note)
}

class NoteController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var modificationDate: UILabel!
    @IBOutlet weak var creationDate: UILabel!
    @IBOutlet weak var bodyText: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var topBodyConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var note: Note?
    var delegate: NoteControllerDelegate?
    var count = 0
    var relativePoint: CGPoint!
    
    var images = [UIImageView]()
    var photosToSave = [String]()
    
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
        if note?.images != nil {
        let imagesData = note?.images?.allObjects as? [PhotoContainer]
            imagesData?.forEach({ (container) in
                let data = container.image
                let posX = container.locationX
                let posY = container.locationY
                if let data = data {
                    let image = UIImage(data: data)
                    setupNewImageView(image: image!, x: posX, y: posY)
                }
            })
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleUpdateNote))
       // setupNoteImages()
        setupDatePicker()
        setupBottomToolbar()
        
    }

    @objc private func handleUpdateNote() {
        print("Updating note...")
        let context = DataManager.sharedManager.persistentContainer.viewContext
        let note = self.note
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        note?.body = self.bodyText.text
        note?.creationDate = dateFormatter.date(from: self.creationDate.text!)
        note?.modificationDate = dateFormatter.date(from: self.modificationDate.text!)
        note?.title = self.titleTextField.text
        let container  = bodyText.subviews
        container.forEach { (view) in
            if view is UIImageView {
                let imageView = view as? UIImageView
                if let imageView = imageView {
                    if photosToSave.contains("image_\(imageView.tag)") {
                        let frame = imageView.frame
                        let image = imageView.image
                        let imageData = UIImageJPEGRepresentation(image!, 0.8)
                        if let imageData = imageData {
                              DataManager.sharedManager.createPhotoContainer(image: imageData, note: note!, x: Float(frame.origin.x), y: Float(frame.origin.y))//TODO
                        }
                    }
                }
            }
        }
       
        /*self.photosToSave.forEach { (image) in
            let imageData = UIImageJPEGRepresentation(image, 0.8)
            if let imageData = imageData {
                DataManager.sharedManager.createPhotoContainer(image: imageData, note: note!, x: 0, y: 0)//TODO
            }
        }*/

        do {
            try context.save()
            if let note = note {
                delegate?.didEditNote(note: note)
            }
        } catch let saveErr {
            print("Failed to edit note:", saveErr)
        }
     
    }
}

extension NoteController: UITextFieldDelegate {
   
    func textFieldDidEndEditing(_ textField: UITextField) {
         print("Title Edited")
        let context = DataManager.sharedManager.persistentContainer.viewContext
        note?.title = titleTextField.text
        do {
            try context.save()
            if let note = note {
                delegate?.didEditNote(note: note)
            }
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
    
    func setupBottomToolbar()  {
        navigationController?.isToolbarHidden = false
        let photoBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(catchPhoto))
        //Este espacio es para dejar entre los botones unicamente
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//mirar más
        let mapBarButton = UIBarButtonItem(title: "Map", style: .done, target: self, action: #selector(addLocation))
        photoBarButton.tintColor = UIColor.emerald
        mapBarButton.tintColor = UIColor.emerald
        self.setToolbarItems([photoBarButton, flexible, mapBarButton], animated: false)
    }
    
    func setupNewImageView(image: UIImage, x: Float?, y: Float?) {
        //let imageView = UIImageView(image: image)
        if let x = x, let y = y {
        let frame = CGRect(x: CGFloat(x), y: CGFloat(y), width: 100, height: 150)
        let imageView = UIImageView(frame: frame)
        imageView.image = image
       
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.tag = count
     
        bodyText.addSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        let topImgConstraint = imageView.topAnchor.constraint(equalTo: bodyText.topAnchor, constant: CGFloat(y))
        topImgConstraint.isActive = true
        topImgConstraint.identifier = "topConstraint_image_\(count)"
        imageView.bottomAnchor.constraint(equalTo: bodyText.bottomAnchor, constant: -20)
        let leftImgConstraint = imageView.leftAnchor.constraint(equalTo: bodyText.leftAnchor, constant: CGFloat(x))
        leftImgConstraint.isActive = true
        leftImgConstraint.identifier = "leftConstraint_image_\(count)"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didChoosen))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didMoved))
        longPressGesture.delegate = self
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch))
        pinchGesture.delegate = self
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotateImage))
        rotateGesture.delegate = self
        imageView.addGestureRecognizer(tapGesture)
        imageView.addGestureRecognizer(longPressGesture)
        imageView.addGestureRecognizer(pinchGesture)
        imageView.addGestureRecognizer(rotateGesture)
        }
    }
    
    @objc func didChoosen(tapGesture: UITapGestureRecognizer) {
        bodyText.bringSubview(toFront: tapGesture.view!)
    }
    
    @objc func didPinch(pinchGesture: UIPinchGestureRecognizer) {
        let scale = pinchGesture.scale
        let imageView = pinchGesture.view as! UIImageView
        imageView.transform = imageView.transform.scaledBy(x: scale, y: scale)
        pinchGesture.scale = 1
    }
    
    @objc func didRotateImage(rotationGesture: UIRotationGestureRecognizer) {
        let rotation = rotationGesture.rotation
        let imageView = rotationGesture.view as! UIImageView
        imageView.transform =  imageView.transform.rotated(by: rotation)
        rotationGesture.rotation = 0
    }
    
    @objc func didMoved(longPressGesture: UILongPressGestureRecognizer) {
        let imageView =  longPressGesture.view as! UIImageView
        let topImgConstraint = bodyText.constraints.filter { (constraint) -> Bool in
            return constraint.identifier == "topConstraint_image_\(imageView.tag)"
        }.first
        let leftImgConstraint = bodyText.constraints.filter { (constraint) -> Bool in
            return constraint.identifier == "leftConstraint_image_\(imageView.tag)"
        }.first
        switch longPressGesture.state {
        case .began:
            closeKeyboard()
            relativePoint = longPressGesture.location(in: imageView)
        case .changed:
            let location = longPressGesture.location(in: bodyText)
            leftImgConstraint?.constant = location.x - relativePoint.x
            topImgConstraint?.constant = location.y - relativePoint.y
            break
        case .ended, .cancelled: break
            
        default:
            break
        }
    }
    
    func closeKeyboard() {
        if titleTextField.isFirstResponder {
            titleTextField.resignFirstResponder()
        } else if bodyText.isFirstResponder {
            bodyText.resignFirstResponder()
        }
    }
    //MARK:- UIGestureRecognizerDelegate Methods
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
   
    /*override func viewDidLayoutSubviews() {
        //let images = view.subviews
        let images = bodyText.subviews
        var paths = [UIBezierPath]()
        images.forEach { (view) in
            if view is UIImageView {
                let imageView = view as? UIImageView
                print("IMAGEVIEW TAG->", imageView?.tag)
                var imgRectangle = view.convert((imageView?.frame)!, to: bodyText)
                imgRectangle = imgRectangle.insetBy(dx: -15, dy: -15)//Con esto le metemos margen al rectangulo de la imagen
                paths.append(UIBezierPath(rect: imgRectangle))
            }
        }
        bodyText.textContainer.exclusionPaths = paths
    }*/
    
}

extension NoteController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func catchPhoto() {
        print("Add photo...")
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        count = count + 1
        photosToSave.append("image_\(count)")
        setupNewImageView(image: image, x: 20, y: 20)
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
// MARK: - DatePicker
extension NoteController {
    
    private func setupDatePicker() {
        modificationDate.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didDatePickerShowed))
        modificationDate.addGestureRecognizer(tapGesture)
        datePicker.isUserInteractionEnabled = true
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didCloseDatePicker))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
    }
    
    @objc func didDatePickerShowed() {
        datePicker.isHidden = false
        view.bringSubview(toFront: datePicker)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        datePicker.date = dateFormatter.date(from: modificationDate.text!)!
        datePicker.addTarget(self, action: #selector(didDateChanged), for: UIControlEvents.valueChanged)
        
    }
    
    @objc func didDateChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        modificationDate.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func didCloseDatePicker() {
        datePicker.isHidden = true
    }
}

extension NoteController {
    @objc func addLocation() {
        print("Add location...")
        let mapController = MapViewController()
        present(mapController.wrappedNavigation(), animated: true, completion: nil)
    }
}
