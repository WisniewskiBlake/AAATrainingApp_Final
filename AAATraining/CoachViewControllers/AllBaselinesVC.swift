//
//  AllBaselinesVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/21/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import FirebaseFirestore

class AllBaselinesVC: UIViewController {
    
    var allBaselines: [Baseline] = []
    var user = FUser()
    let helper = Helper()
    var baselineData: [String] = ["Name", "Date", "Height", "Weight", "Wingspan", "Vertical", "20yd Dash", "Agility", "Push Ups", "Chin Ups", "Mile Time"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIFHUD.shared.setGif(named: "loaderFinal.gif")
        NotificationCenter.default.addObserver(self, selector: #selector(loadBaselines), name: NSNotification.Name(rawValue: "createBaseline"), object: nil)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
        loadBaselines()
    }
        
    @IBOutlet weak var gridCollectionView: UICollectionView! {
        didSet {
            gridCollectionView.bounces = false
        }
    }
    
    @IBOutlet weak var gridLayout: StickyGridCollectionViewLayout! {
        didSet {
            gridLayout.stickyRowsCount = 1
            gridLayout.stickyColumnsCount = 1
        }
    }
    
    @objc func loadBaselines() {
        GIFHUD.shared.show(withOverlay: true)
        
        var query: Query!
        query = reference(.Baseline).whereField(kBASELINETEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID).order(by: kBASELINEUSERNAME, descending: false)
        query.getDocuments { (snapshot, error) in
            
            self.allBaselines = []
                        
            if error != nil {
                print(error!.localizedDescription)
                GIFHUD.shared.dismiss()
             self.helper.showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                self.gridCollectionView.reloadData()
                return
            }
            
            guard let snapshot = snapshot else {
             self.helper.showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
             
                GIFHUD.shared.dismiss(); return
            }
            
            if !snapshot.isEmpty {
                
                for userDictionary in snapshot.documents {
                    
                    let userDictionary = userDictionary.data() as NSDictionary
                    let baseline = Baseline(_dictionary: userDictionary)
                    
                    self.allBaselines.append(baseline)
                    
                }
                
                self.gridCollectionView.reloadData()
            }
            
            self.gridCollectionView.reloadData()
            GIFHUD.shared.dismiss()
            
        }
    }
    
    func loadUserClicked(objectID : String) {
        GIFHUD.shared.show(withOverlay: true)
        var query: Query!
        
        query = reference(.User).whereField("objectId", isEqualTo: objectID)
        
        query.getDocuments { (snapshot, error) in
            
            self.user = FUser()
            
            if error != nil {
                print(error!.localizedDescription)
                GIFHUD.shared.dismiss()
             self.helper.showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                return
            }
            
            guard let snapshot = snapshot else {
             self.helper.showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                GIFHUD.shared.dismiss(); return
            }
            
            if !snapshot.isEmpty {
                
                for userDictionary in snapshot.documents {
                    
                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    
                    self.displayUserProfile(user : fUser)
                }
                
            }
            
            GIFHUD.shared.dismiss()
            
        }
    }
    
    func displayUserProfile(user : FUser) {
        let playerProfileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        playerProfileVC.userBeingViewed = user
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationController?.pushViewController(playerProfileVC, animated: true)
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

extension AllBaselinesVC: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return allBaselines.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return baselineData.count
    }
    //section = row, item = column
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllBaselinesCell", for: indexPath) as? AllBaselinesCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.section == 0 {
            cell.dataLabel.text = baselineData[indexPath.item]
            if gridLayout.isItemSticky(at: indexPath) {
                cell.dataLabel.font = .boldSystemFont(ofSize: 17.0)
                cell.backgroundColor = .groupTableViewBackground
            }
            
        } else {
            cell.dataLabel.font = .systemFont(ofSize: 17.0)
            if indexPath.item == 0 {
                cell.dataLabel.numberOfLines = 2
                print(indexPath.section)
                cell.dataLabel.text = allBaselines[indexPath.section - 1].userName
                cell.backgroundColor = gridLayout.isItemSticky(at: indexPath) ? .groupTableViewBackground : .white
            } else if indexPath.item == 1 {
                var date: String?
                let currentDateFormater = helper.dateFormatter()
                currentDateFormater.dateFormat = "MM/dd/yy"
                let baselineDate = helper.dateFormatter().date(from: allBaselines[indexPath.section - 1].baselineDate)
                date = currentDateFormater.string(from: baselineDate!)
                cell.dataLabel.text = date
                cell.backgroundColor = .white
            } else if indexPath.item == 2 {
                cell.dataLabel.text = allBaselines[indexPath.section - 1].height
                cell.backgroundColor = .white
            } else if indexPath.item == 3 {
                cell.dataLabel.text = allBaselines[indexPath.section - 1].weight
                cell.backgroundColor = .white
            } else if indexPath.item == 4 {
                cell.dataLabel.text = allBaselines[indexPath.section - 1].wingspan
                cell.backgroundColor = .white
            } else if indexPath.item == 5 {
                cell.dataLabel.text = allBaselines[indexPath.section - 1].vertical
                cell.backgroundColor = .white
            } else if indexPath.item == 6 {
                cell.dataLabel.text = allBaselines[indexPath.section - 1].yardDash
                cell.backgroundColor = .white
            } else if indexPath.item == 7 {
                cell.dataLabel.text = allBaselines[indexPath.section - 1].agility
                cell.backgroundColor = .white
            } else if indexPath.item == 8 {
                cell.dataLabel.text = allBaselines[indexPath.section - 1].pushUp
                cell.backgroundColor = .white
            } else if indexPath.item == 9 {
                cell.dataLabel.text = allBaselines[indexPath.section - 1].chinUp
                cell.backgroundColor = .white
            } else if indexPath.item == 10 {
                cell.dataLabel.text = allBaselines[indexPath.section - 1].mileRun
                cell.backgroundColor = .white
            }
            //could get rid of all the if else statements
            //by making a 2D array and saying dataLabel.text = allBaselines[item][section]
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //check that cell isnt in row 1
        if indexPath.section != 0 {
            //get the base that is in the row that the cell is in
            var baselineOwnerID = allBaselines[indexPath.section].baselineOwnerID
            loadUserClicked(objectID: baselineOwnerID)
        }
        
        //get the corresponding user by DB query for the owner ID of that row
        //push view controller with that user
    }
}

extension AllBaselinesVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    
}
