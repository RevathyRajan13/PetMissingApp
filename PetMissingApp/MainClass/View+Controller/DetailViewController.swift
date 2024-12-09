//
//  DetailViewController.swift
//  PetMissingApp
//
//  Created by Revathy - iOS Dev on 07/12/24.
//

import UIKit
import MessageUI

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var speciesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var pets: Pet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
    }
    
    func loadData() {
        self.titleLabel.text = self.pets?.name
        self.petNameLabel.text = "Name : \(self.pets?.name ?? "")"
        self.speciesLabel.text = "Species : \(self.pets?.species ?? "")"
        self.descriptionLabel.text = "Description : \(self.pets?.description ?? "")"
        self.petImageView.image = self.stringToImage(base64String: self.pets?.photoData ?? "")
        self.timeLabel.text = timestampToMyCustomTime(self.pets?.currentTimestamp ?? "")
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func locationButtonTapped(_ sender: Any) {
        let stBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = stBoard.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
        vc.pets = self.pets
        vc.isViewOnly = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func mailButtonTapped(_ sender: Any) {
        guard let email = self.pets?.contactMailId else { return }

        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setToRecipients([email])
            mailComposeVC.setSubject("Inquiry about \(self.pets?.name ?? "Pet")")
            mailComposeVC.setMessageBody("Hello, I would like to know more about the pet.", isHTML: false)
            self.present(mailComposeVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Mail Not Available", message: "Please install the mail on your phone.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func callButtonTapped(_ sender: Any) {
        guard let phone = self.pets?.contactNo else { return }
        if UIApplication.shared.canOpenURL(URL(string: "tel://")!) {
            let urlString = "tel:\(phone)"
            UIApplication.shared.open(URL(string: urlString)!)
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let text = "Hey my pet is missing, please contact if anybody found \n Name: \(self.pets?.name ?? "") \n Contact number: \(self.pets?.contactNo ?? "")"
        let shareItems:Array = [text] as [Any]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
}

extension DetailViewController : MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
