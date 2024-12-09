//
//  SplashViewController.swift
//  PetMissingApp
//
//  Created by Revathy - iOS Dev on 07/12/24.
//

import UIKit
import FirebaseAuth

class SplashViewController: UIViewController {
    
    @IBOutlet weak var splashIconView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.splashIconView.bounce()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.moveTo()
        }
    }
    
    func moveTo() {
        let stBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = stBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
