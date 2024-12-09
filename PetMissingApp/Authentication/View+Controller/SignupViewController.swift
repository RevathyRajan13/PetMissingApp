//
//  SignupViewController.swift
//  PetMissingApp
//
//  Created by Revathy - iOS Dev on 07/12/24.
//

import UIKit
import Toast_Swift
import FirebaseAuth
import FirebaseDatabase

class SignupViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailIdTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var eyeImageView: UIImageView!
    
    var style = ToastStyle()
    var eyeVal = "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    func configUI() {
        self.addDoneButtonOnKeyboard(textfield: self.nameTextField)
        self.addDoneButtonOnKeyboard(textfield: self.emailIdTextField)
        self.addDoneButtonOnKeyboard(textfield: self.mobileTextField)
        self.addDoneButtonOnKeyboard(textfield: self.passwordTextField)
    }
    
    func signup() {
        self.view.showBlurLoader()
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailIdTextField.text, !email.isEmpty,
              let phone = mobileTextField.text, !phone.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            self.view.makeToast("All fields are required.", duration: 1.0, position: .bottom, style: self.style)
            return
        }
        
        guard self.isValidEmail(emailIdTextField.text ?? "") else {
            self.view.makeToast("Invalid Email, please check", duration: 1.0, position: .bottom, style: self.style)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.view.removeBluerLoader()
                self.view.makeToast("Error: \(error.localizedDescription)", duration: 1.0, position: .bottom, style: self.style)
                return
            }
            
            guard let uid = authResult?.user.uid else {
                self.view.removeBluerLoader()
                return
            }
            
            let ref = Database.database().reference()
            let userObject: [String: Any] = [
                "name": name,
                "email": email,
                "phone": phone
            ]
            ref.child("users").child(uid).setValue(userObject) { error, _ in
                if let error = error {
                    self.view.removeBluerLoader()
                    self.view.makeToast("Database Error: \(error.localizedDescription)", duration: 1.0, position: .bottom, style: self.style)
                    return
                }
                let alertController = UIAlertController(title: "Success", message: "User successfully registered!", preferredStyle: .alert)
                let loginAction = UIAlertAction(title: "Okay", style: .default) { _ in
                    self.view.removeBluerLoader()

                    let name = self.nameTextField.text ?? ""
                    userDefaultModule.shared.setName(name: name)
                    
                    let mobile = self.mobileTextField.text ?? ""
                    userDefaultModule.shared.setMobileNo(mobileNo: mobile)
                    
                    let email = self.emailIdTextField.text ?? ""
                    userDefaultModule.shared.setEmailID(emailId: email)
                    
                    self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(loginAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func eyeButtonTapped() {
        if (eyeVal == "0") {
            self.eyeImageView.image=UIImage(named: "1 Eye off")
            self.passwordTextField.isSecureTextEntry = true
            self.eyeVal = "1"
        }
        else if (eyeVal == "1") {
            self.eyeImageView.image=UIImage(named: "1 Eye")
            self.passwordTextField.isSecureTextEntry = false
            self.eyeVal = "0"
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        let stBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = stBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func signupButtonTapped(_ sender: Any) {
        self.signup()
    }
    
}

//MARK: UITextFieldDelegate
extension SignupViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            emailIdTextField.becomeFirstResponder()
        case emailIdTextField:
            mobileTextField.becomeFirstResponder()
        case mobileTextField:
            passwordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
}
