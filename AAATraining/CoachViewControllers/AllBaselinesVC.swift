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
    let helper = Helper()
    var baselineData: [String] = ["Name", "Height", "Weight", "Wingspan", "Vertical", "20yd Dash", "Agility", "Push Ups", "Chin Ups", "Mile Time"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func loadBaselines() {
        ProgressHUD.show()
        
        var query: Query!
        query = reference(.Baseline).order(by: kBASELINEUSERNAME, descending: false)
        query.getDocuments { (snapshot, error) in
            
            self.allBaselines = []
                        
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
             self.helper.showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                self.gridCollectionView.reloadData()
                return
            }
            
            guard let snapshot = snapshot else {
             self.helper.showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
             
                ProgressHUD.dismiss(); return
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
            ProgressHUD.dismiss()
            
        }
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

extension AllBaselinesVC: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return allBaselines.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return baselineData.count
    }
    //section = row, item = column
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllBaselinesCell", for: indexPath) as? AllBaselinesCell else {
            return UICollectionViewCell()
        }
        print(indexPath)
        
        print(indexPath.item)
        print(indexPath.section)
        
        
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
                cell.dataLabel.text = allBaselines[indexPath.section].userName
                cell.backgroundColor = gridLayout.isItemSticky(at: indexPath) ? .groupTableViewBackground : .white
            } else if indexPath.item == 1 {
                cell.dataLabel.text = allBaselines[indexPath.section].height
                cell.backgroundColor = .white
            } else if indexPath.item == 2 {
                cell.dataLabel.text = allBaselines[indexPath.section].weight                
                cell.backgroundColor = .white
            } else if indexPath.item == 3 {
                cell.dataLabel.text = allBaselines[indexPath.section].wingspan
                cell.backgroundColor = .white
            } else if indexPath.item == 4 {
                cell.dataLabel.text = allBaselines[indexPath.section].vertical
                cell.backgroundColor = .white
            } else if indexPath.item == 5 {
                cell.dataLabel.text = allBaselines[indexPath.section].yardDash
                cell.backgroundColor = .white
            } else if indexPath.item == 6 {
                cell.dataLabel.text = allBaselines[indexPath.section].agility
                cell.backgroundColor = .white
            } else if indexPath.item == 7 {
                cell.dataLabel.text = allBaselines[indexPath.section].pushUp
                cell.backgroundColor = .white
            } else if indexPath.item == 8 {
                cell.dataLabel.text = allBaselines[indexPath.section].chinUp
                cell.backgroundColor = .white
            } else if indexPath.item == 9 {
                cell.dataLabel.text = allBaselines[indexPath.section].mileRun
                cell.backgroundColor = .white
            } else {
                cell.dataLabel.text = "\(indexPath)"
                cell.backgroundColor = .white
            }
            
        }

        
        return cell
    }
}

extension AllBaselinesVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    
}
