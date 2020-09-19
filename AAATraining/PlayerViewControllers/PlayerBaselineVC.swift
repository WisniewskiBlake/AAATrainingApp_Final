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
    
    @IBOutlet weak var composeButton: UIBarButtonItem!
    let helper = Helper()
    
    var userBeingViewed = FUser()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadBaselinesForGuest), name: NSNotification.Name(rawValue: "createBaseline"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadBaselinesForGuest), name: NSNotification.Name(rawValue: "createBaseline"), object: nil)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        //self.setLeftAlignedNavigationItemTitle(text: "Baselines", color: .white, margin: 12)
        
        if FUser.currentUser()?.accountType == "Player" {
            composeButton.isEnabled = false
            loadBaselines()
            
        } else {
            composeButton.isEnabled = true
            loadBaselinesForGuest()
            
        }
        
        

    }
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if FUser.currentUser()?.accountType == "Player" {
            composeButton.isEnabled = false
            loadBaselines()
            
        } else {
            composeButton.isEnabled = true
            loadBaselinesForGuest()
            
        }
        
        //tableView.tableFooterView = UIView()
        //navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    @objc func loadBaselinesForGuest() {
        
        ProgressHUD.show()
        
        recentListener = reference(.Baseline).whereField(kBASELINEOWNERID, isEqualTo: userBeingViewed.objectId).order(by: kBASELINEDATE, descending: true).addSnapshotListener({ (snapshot, error) in
                   
                self.allBaselines = []
            
                if error != nil {
                    print(error!.localizedDescription)
                    ProgressHUD.dismiss()
                    self.tableView.reloadData()
                    return
                }
                   guard let snapshot = snapshot else { ProgressHUD.dismiss(); return }

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
               })
        
        
        ProgressHUD.show()
        
    }
    
    // MARK: - Load Baselines
    // loading posts from the server via@objc  PHP protocol
    @objc func loadBaselines() {
        
        ProgressHUD.show()
        
        recentListener = reference(.Baseline).whereField(kBASELINEOWNERID, isEqualTo: FUser.currentId()).order(by: kBASELINEDATE, descending: true).addSnapshotListener({ (snapshot, error) in
                   
                self.allBaselines = []
            
                if error != nil {
                    print(error!.localizedDescription)
                    ProgressHUD.dismiss()
                    self.tableView.reloadData()
                    return
                }
                   guard let snapshot = snapshot else { ProgressHUD.dismiss(); return }

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
               })
        
        
        ProgressHUD.show()
        

        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if allBaselines.count == 0 {
            var emptyLabelOne = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            emptyLabelOne.text = "Nothing to show!"
            emptyLabelOne.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = emptyLabelOne
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            return 0
        } else {
            self.tableView.backgroundView = nil
            return allBaselines.count
        }
        
    }
    
    // heights of the cells
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    

        // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BaselineCell", for: indexPath) as! BaselineCell
        
        var baseline: Baseline
        baseline = allBaselines[indexPath.row]
        
        //var date: Date!
        var date: String?
        
        let currentDateFormater = helper.dateFormatter()
        currentDateFormater.dateFormat = "MM/dd/YYYY"
        
        let baselineDate = helper.dateFormatter().date(from: baseline.baselineDate)
        //cell.baselineDateLabel.text = helper.timeElapsed(date: date)
        
        date = currentDateFormater.string(from: baselineDate!)
        cell.baselineDateLabel.text = date
       
        cell.heightLabel.text = baseline.height
        print(baseline.height)
        cell.weightLabel.text = baseline.weight
        print(baseline.weight)
        cell.wingspanLabel.text = baseline.wingspan
        cell.verticalLabel.text = baseline.vertical
        cell.dashLabel.text = baseline.yardDash
        cell.agilityLabel.text = baseline.agility
        print(baseline.agility)
        cell.pushUpLabel.text = baseline.pushUp
        cell.chinUpLabel.text = baseline.chinUp
        cell.mileLabel.text = baseline.mileRun
                         
        //cell.generateCellWith(baseline: baseline, indexPath: indexPath)
         
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var baseline: Baseline
        baseline = allBaselines[indexPath.row]
        
        if FUser.currentUser()?.accountType != "Player" {
            let editBaselineVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditBaselineVC") as! EditBaselineVC
            
            editBaselineVC.baselineToEdit = baseline
            
            
            self.navigationController?.pushViewController(editBaselineVC, animated: true)
            
        }
        
        
    }
    
    @IBAction func composeButtonPressed(_ sender: Any) {
        let newBaselineVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewBaselineVC") as! NewBaselineVC
//           let navigation = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addMembersNav") as! UINavigationController
//           contactsVC.isGroup = isGroup
        
        newBaselineVC.userBeingViewed = userBeingViewed
           
        //self.present(newBaselineVC, animated: true, completion: nil)
        self.navigationController?.pushViewController(newBaselineVC, animated: true)
    }
    

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
