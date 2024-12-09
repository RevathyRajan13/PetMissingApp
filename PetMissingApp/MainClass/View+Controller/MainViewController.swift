//
//  MainViewController.swift
//  PetMissingApp
//
//  Created by Revathy - iOS Dev on 07/12/24.
//

import UIKit
import FirebaseAuth
import Toast_Swift
import FirebaseDatabase
import FirebaseStorage
import DropDown

class MainViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addPetView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var petsTableView: UITableView!
    @IBOutlet weak var nodataLabel: UILabel!
    
    var style = ToastStyle()
    let speciesdropDown = DropDown()
    var species_name = ["All", "Dogs", "Cats"]
    var pets: [Pet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchPetsData()
        self.logoutButton.isHidden = Auth.auth().currentUser != nil ? false : true
        self.titleLabel.text = Auth.auth().currentUser != nil ? "Welcome \(userDefaultModule.shared.getName())..!" : "Welcome Guest..!"
    }
    
    func configUI() {
        let petsNib = UINib(nibName: "PetTableViewCell", bundle: nil)
        self.petsTableView.register(petsNib, forCellReuseIdentifier: "PetTableViewCell")
        self.petsTableView.separatorStyle = .none
    }
    
    private func fetchPetsData(filterValue: String = "") {
        fetchPets(filterValue:filterValue ) { [weak self] fetchedPets in
            self?.pets = fetchedPets.reversed() // Used this for showing latest pets
            DispatchQueue.main.async {
                self?.view.removeBluerLoader()
                if self?.pets.count ?? 0 > 0 {
                    self?.petsTableView.isHidden = false
                    self?.nodataLabel.isHidden = true
                    self?.petsTableView.reloadData()
                } else {
                    self?.nodataLabel.isHidden = false
                    self?.petsTableView.isHidden = true
                }
            }
        }
    }
    
    func fetchPets(filterValue: String = "", completion: @escaping ([Pet]) -> Void) {
        self.view.showBlurLoader()
        let databaseRef = Database.database().reference().child("Pets")
        databaseRef.observe(.value) { snapshot in
            var pets: [Pet] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let petData = childSnapshot.value as? [String: Any] {
                    let pet = Pet(
                        name: petData["petName"] as? String ?? "",
                        species: petData["species"] as? String ?? "",
                        description: petData["description"] as? String ?? "",
                        photoData: petData["photoData"] as? String ?? "",
                        contactNo: petData["contactNo"] as? String ?? "",
                        contactMailId: petData["contactMailId"] as? String ?? "",
                        currentTimestamp: petData["currentTimestamp"] as? String ?? "",
                        lastSeenLat: petData["lastSeenLat"] as? Double ?? Double(),
                        lastSeenLong: petData["lastSeenLong"] as? Double ?? Double()
                    )
                    pets.append(pet)
                }
            }
            // filter
            if filterValue != "All" && !filterValue.isEmpty {
                let filteredPets = pets.filter { pet in
                    pet.species == filterValue
                }
                pets.removeAll()
                pets.append(contentsOf: filteredPets)
            }
            
            completion(pets)
        }
    }
    
    func showLogoutActionSheet() {
       let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)

       let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
           self.performLogout()
       }
       alertController.addAction(logoutAction)

       let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
       alertController.addAction(cancelAction)

       present(alertController, animated: true, completion: nil)
   }
    
    func performLogout() {
        self.view.showBlurLoader()
        do {
            try Auth.auth().signOut()
            self.view.removeBluerLoader()
            self.view.makeToast("User logged out successfully.", duration: 1.0, position: .bottom, style: self.style)
            self.titleLabel.text = "Welcome Guest..!"
            self.logoutButton.isHidden = true
        } catch let error {
            self.view.removeBluerLoader()
            self.view.makeToast("Error logging out: \(error.localizedDescription)", duration: 1.0, position: .bottom, style: self.style)
        }
    }
    
    @IBAction func addPetButtonTapped(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            let stBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = stBoard.instantiateViewController(withIdentifier: "AddMissingPetViewController") as! AddMissingPetViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let stBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = stBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        let dropDownValues = species_name
        speciesdropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print(self)
            self.fetchPetsData(filterValue: species_name[index])
        }
        speciesdropDown.anchorView = self.filterButton
        speciesdropDown.dataSource = dropDownValues
        speciesdropDown.direction = .bottom
        speciesdropDown.width = 85
        speciesdropDown.show()
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        self.showLogoutActionSheet()
    }

}

extension MainViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  petsTableView.dequeueReusableCell(withIdentifier: "PetTableViewCell") as! PetTableViewCell
        cell.petImageView.image = self.stringToImage(base64String: pets[indexPath.row].photoData)

        
        cell.petNameLabel.text = self.pets[indexPath.row].name
        cell.petDescriptionLabel.text = self.pets[indexPath.row].description
        
                
        cell.timeLabel.text = timestampToMyCustomTime(self.pets[indexPath.row].currentTimestamp)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = stBoard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.pets = self.pets[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }

}


