//
//  LoginViewController.swift
//  PetMissingApp
//
//  Created by Revathy - iOS Dev on 07/12/24.
//

import UIKit
import Toast_Swift
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var eyeImageView: UIImageView!

    var style = ToastStyle()
    var eyeVal = "1"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    func configUI() {
        self.addDoneButtonOnKeyboard(textfield: self.emailTextField)
        self.addDoneButtonOnKeyboard(textfield: self.passwordTextField)
    }
    
    func login() {
        self.view.showBlurLoader()
        self.view.endEditing(true)
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            self.view.makeToast("Email and password are required.", duration: 1.0, position: .bottom, style: self.style)
            return
        }
        
        guard self.isValidEmail(emailTextField.text ?? "") else {
            self.view.makeToast("Invalid Email, please check", duration: 1.0, position: .bottom, style: self.style)
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.view.removeBluerLoader()
                self.view.makeToast("Error: \(error.localizedDescription)", duration: 1.0, position: .bottom, style: self.style)

                return
            }
            
            let alertController = UIAlertController(title: "Success", message: "User successfully logged in!", preferredStyle: .alert)
            let loginAction = UIAlertAction(title: "Okay", style: .default) { _ in
                self.view.removeBluerLoader()
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(loginAction)
            self.present(alertController, animated: true, completion: nil)
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
        self.login()
    }
    
    @IBAction func signupButtonTapped(_ sender: Any) {
        let stBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = stBoard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
    
}
