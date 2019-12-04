//
//  ViewController.swift
//  pinPhotos
//
//  Created by Karlis Cars on 04/12/2019.
//  Copyright © 2019 Karlis Cars. All rights reserved.
//

import UIKit
import CoreData


class PhotosViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var pinPhotos = [Photos]()
    var managedObjectContext: NSManagedObjectContext?
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        loadData()
        
        
    }

    func loadData(){
        let request: NSFetchRequest<Photos> = Photos.fetchRequest()
        do{
            let result = try managedObjectContext?.fetch(request)
            pinPhotos = result!
            collectionView.reloadData()
            
            
        }catch{
            fatalError("Error in retrieving Photo item")
        }
        
        
        
    }
    
    func pickedNewImage(with image: UIImage){
        let pickedItem = Photos(context: managedObjectContext!)
        pickedItem.image = NSData(data: image.jpegData(compressionQuality: 0.3)!) as Data
        
        do {
            try self.managedObjectContext?.save()
            self.loadData()
        }catch{
            fatalError("Could not save data")
        }
    }
    
    @IBAction func actionSheetTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Select Image Source", message: "Please select an OPtion", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Chose a Photo", style: .default, handler: { (UIAlertAction) in
            print("Photo Gallery")
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Take a new Photo", style: .default, handler: { (UIAlertAction) in
            print("Take Photo")
            
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                print("Photo Gallery")
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = false
                self.imagePicker.cameraCaptureMode = .photo
                self.imagePicker.modalPresentationStyle = .fullScreen
                self.present(self.imagePicker, animated: true, completion: nil)
            }else{
                self.warningPopUp(withTitle: "No Camera!", withMessage: "Device without camera")
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (UIAlertAction) in
            print("Dismiss")
        }))
        
        self.present(alert, animated: true, completion: {print("completion block")})
    }//end actionSheet
    
}//end

extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil)
            self.pickedNewImage(with: pickedImage)
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pinPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pinCell", for: indexPath) as? ImageCollectionViewCell
            else {return UICollectionViewCell()}
        
        let pins = pinPhotos[indexPath.row]
        print(pins.image as Any)
        
        let imageView : UIImageView = UIImageView(frame: CGRect(x: 5, y: 2, width: 190, height: 240))
        
        if let imageData = pins.value(forKey: "image") as? NSData{
            if let dataImage = UIImage(data: imageData as Data){
                imageView.image = dataImage
                cell.contentView.addSubview(imageView)
            }
        }
        
        return cell
    }
    
    func warningPopUp(withTitle title : String?, withMessage message : String?){
        DispatchQueue.main.async {
            let popUP = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            popUP.addAction(okButton)
            self.present(popUP, animated: true, completion: nil)
        }
    }
    
}

