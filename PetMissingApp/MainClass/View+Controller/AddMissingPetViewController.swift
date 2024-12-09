//
//  AddMissingPetViewController.swift
//  PetMissingApp
//
//  Created by Revathy - iOS Dev on 07/12/24.
//

import UIKit
import MapKit
import DropDown
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore
import Toast_Swift

class AddMissingPetViewController: UIViewController, UINavigationControllerDelegate, LocationSelectionDelegate {
    
    @IBOutlet weak var petNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var speciesNameTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var mailIdTextField: UITextField!
    @IBOutlet weak var previewImageIconView: UIView!
    @IBOutlet weak var imagePreviewMainView: UIView!
    @IBOutlet weak var petImageView: UIImageView!
    
    let speciesdropDown = DropDown()
    var species_name = ["Dogs", "Cats"]
    var selectedImage: UIImage?
    var style = ToastStyle()
    var latitude : Double = 0.0
    var longitude : Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    func configUI() {
        
        self.mobileTextField.text = userDefaultModule.shared.getMobileNo()
        self.mailIdTextField.text = userDefaultModule.shared.getEmailID()

        self.addDoneButtonOnKeyboard(textfield: self.petNameTextField)
        self.addDoneButtonOnKeyboard(textfield: self.descriptionTextField)
        self.addDoneButtonOnKeyboard(textfield: self.speciesNameTextField)
        self.addDoneButtonOnKeyboard(textfield: self.mobileTextField)
        self.addDoneButtonOnKeyboard(textfield: self.mailIdTextField)
    }
    
    func didSelectLocation(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }


    func savePetDetails(petName: String, species: String, description: String, location: String, photo: UIImage, contactNo: String, contactMailId: String) {
        let databaseRef = Database.database().reference().child("Pets").childByAutoId()
        
        guard let photoData = photo.jpegData(compressionQuality: 0) else { return }
        let base64PhotoString = photoData.base64EncodedString()
        
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        let currentTimestampString = String(currentTimestamp)

        /*
        let name: String
        let species: String
        let description: String
        let photoData: String
        let location: String
        let contactNo: String
        let contactMailId: String
        let currentTimestamp : String
        let lastSeenLat : Double
        let lastSeenLong : Double
        
        */
        
        let petDetails: [String: Any] = [
            "petName": petName,
            "species": species,
            "description": description,
            "photoData": base64PhotoString,
            "contactNo": contactNo,
            "contactMailId": contactMailId,
            "currentTimestamp": currentTimestampString,
            "lastSeenLat": self.latitude,
            "lastSeenLong": self.longitude
        ]
        
        databaseRef.setValue(petDetails) { error, _ in
            if let error = error {
                self.view.makeToast("Failed to save pet details: \(error)", duration: 1.0, position: .bottom, style: self.style)
            } else {
                let alertController = UIAlertController(title: "Success", message: "Pet details saved successfully!", preferredStyle: .alert)
                let loginAction = UIAlertAction(title: "Okay", style: .default) { _ in
                    self.view.removeBluerLoader()
                    self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(loginAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    
    @IBAction func mapButtonTapped(_ sender: UIButton) {
        
        let stBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = stBoard.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
        vc.isViewOnly = false
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func previewImageIconButtonTapped(_ sender: Any) {
        self.imagePreviewMainView.isHidden = false
    }
    
    @IBAction func selectPhotoTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func previewImageViewCloseButtonTapped(_ sender: Any) {
        self.imagePreviewMainView.isHidden = true
    }
    
    @IBAction func imageDeleteButtonTapped(_ sender: Any) {
        self.imagePreviewMainView.isHidden = true
        self.selectedImage = UIImage()
        self.previewImageIconView.isHidden = true
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        var errormsg = String()
        if self.petNameTextField.text?.count == 0 {
            errormsg = "Please enter your Pet Name."
        }
        else if self.speciesNameTextField.text?.count == 0 {
            errormsg = "Please enter your Pet's Species."
        }
        else if self.descriptionTextField.text?.count == 0 {
            errormsg = "Please enter your Pet's Description."
        }
        else if self.mobileTextField.text?.count == 0 {
            errormsg = "Please enter your Contact Number."
        }
        else if self.mailIdTextField.text?.count == 0 {
            errormsg = "Please enter your Contact Mail."
        }
        else if self.selectedImage == nil {
            errormsg = "Please upload your Pet's Picture"
        }
        else if self.latitude == 0.0 || self.longitude == 0.0 {
            errormsg = "Please share your Pet's last seen using the map"
        }
        
        if errormsg.count > 0 {
            self.view.makeToast(errormsg, duration: 1.0, position: .bottom, style: self.style)
        }
        else {
            self.savePetDetails(petName: self.petNameTextField.text ?? "", species: self.speciesNameTextField.text ?? "", description: self.descriptionTextField.text ?? "", location: "", photo: self.selectedImage ?? UIImage(), contactNo: self.mobileTextField.text ?? "", contactMailId: self.mailIdTextField.text ?? "")
        }
    }
    
    @IBAction func specialityButtonTapped(_ sender: Any) {
        let dropDownValues = species_name
        speciesdropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print(self)
            self.speciesNameTextField.text = species_name[index]
        }
        speciesdropDown.anchorView = self.speciesNameTextField
        speciesdropDown.dataSource = dropDownValues
        speciesdropDown.direction = .bottom
        speciesdropDown.show()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: UITextFieldDelegate
extension AddMissingPetViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case petNameTextField:
            descriptionTextField.becomeFirstResponder()
        case descriptionTextField:
            mobileTextField.becomeFirstResponder()
        case mobileTextField:
            mailIdTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
}

//MARK: UIImagePickerControllerDelegate
extension AddMissingPetViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            self.selectedImage = selectedImage
            previewImageIconView.isHidden = false
            petImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
}


