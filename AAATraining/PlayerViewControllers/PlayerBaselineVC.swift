//
//  PlayerBaselineVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/11/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import MediaPlayer
import ImagePicker
import Firebase
import FirebaseFirestore
import ProgressHUD

class PlayerBaselineVC: UITableViewController {
    
    var allBaselines: [Baseline] = []
    var recentListener: ListenerRegistration!
    
    let helper = Helper()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadBaselines), name: NSNotification.Name(rawValue: "uploadBaseline"), object: nil)
        
        loadBaselines()

    }
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBaselines()
        //navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    // MARK: - Load Baselines
    // loading posts from the server via@objc  PHP protocol
    @objc func loadBaselines() {
        ProgressHUD.show()
        
        var query: Query!
        
        query = reference(.Baseline).whereField(kBASELINEOWNERID, isEqualTo: FUser.currentId()).order(by: kBASELINEDATE, descending: true)
        
        query.getDocuments { (snapshot, error) in
            self.allBaselines = []
            
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            
            guard let snapshot = snapshot else {
                ProgressHUD.dismiss(); return
            }
            
            if !snapshot.isEmpty {
                
                for baselineDictionary in snapshot.documents {
                                let baselineDictionary = baselineDictionary.data() as NSDictionary
                                let baseline = Baseline(_dictionary: baselineDictionary)
                                   self.allBaselines.append(baseline)
                                    print(self.allBaselines)
                                    
                }
                self.tableView.reloadData()
            
            }
            ProgressHUD.dismiss()
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allBaselines.count
    }
    

        // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BaselineCell", for: indexPath) as! BaselineCell
        
        var baseline: Baseline
        
        var date: Date!
        
        baseline = allBaselines[indexPath.row]
        
        date = helper.dateFormatter().date(from: baseline.baselineDate)
        
        cell.baselineDateLabel.text = helper.timeElapsed(date: date)
                         
        cell.generateCellWith(baseline: baseline, indexPath: indexPath)
         
        return cell
        
    }

    

}
