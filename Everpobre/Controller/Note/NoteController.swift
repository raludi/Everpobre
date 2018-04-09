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

class NoteController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var modificationDate: UILabel!
    @IBOutlet weak var creationDate: UILabel!
    @IBOutlet weak var bodyText: UITextView!
    
    // MARK: - Properties
    var note: Note?
    var delegate: NoteControllerDelegate?
    
    var topImgConstraint: NSLayoutConstraint!
    var leftImgConstraint: NSLayoutConstraint!
    var relativePoint: CGPoint!
    
    var images = [UIImageView]()
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
        
        setupBottomToolbar()
        
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
    
    func setupNewImageView(image: UIImage) {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        view.addSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        topImgConstraint = imageView.topAnchor.constraint(equalTo: bodyText.topAnchor, constant: 20)
        topImgConstraint.isActive = true
        imageView.bottomAnchor.constraint(equalTo: bodyText.bottomAnchor, constant: -20)
        leftImgConstraint = imageView.leftAnchor.constraint(equalTo: bodyText.leftAnchor, constant: 20)
        leftImgConstraint.isActive = true
        imageView.image = image
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didMoved))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch))
        pinchGesture.delegate = self
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotateImage))
        imageView.addGestureRecognizer(longPressGesture)
        imageView.addGestureRecognizer(pinchGesture)
        imageView.addGestureRecognizer(rotateGesture)
        
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
        switch longPressGesture.state {
        case .began:
            closeKeyboard()
            relativePoint = longPressGesture.location(in: imageView)
            UIView.animate(withDuration: 0.2, animations: {
                //imageView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            })
            break
        case .changed:
            let location = longPressGesture.location(in: bodyText)
            leftImgConstraint.constant = location.x - relativePoint.x
            topImgConstraint.constant = location.y - relativePoint.y
            break
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.2, animations: {
               // imageView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            })
            break
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
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
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
        setupNewImageView(image: image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}


extension NoteController {
    @objc func addLocation() {
        print("Add location...")
        let mapController = MapViewController()
        present(mapController.wrappedNavigation(), animated: true, completion: nil)
    }
}
