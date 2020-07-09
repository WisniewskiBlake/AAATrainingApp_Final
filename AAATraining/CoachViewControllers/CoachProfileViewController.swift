//
//  CoachProfileViewController.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/8/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class CoachProfileViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    
    
    // code obj (to build logic of distinguishing tapped / shown Cover / Ava)
    var isCover = false
    var isAva = false
    var imageViewTapped = ""
    
    // posts obj
    var posts = [NSDictionary?]()
    var avas = [UIImage]()
    var pictures = [UIImage]()
    var skip = 0
    var limit = 10
    var isLoading = false
    var liked = [Int]()
    
    // color obj
    let likeColor = UIColor(red: 28/255, green: 165/255, blue: 252/255, alpha: 1)
    
    // friends obj
    var myFriends = [NSDictionary?]()
    var myFriends_avas = [UIImage]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadUser), name: NSNotification.Name(rawValue: "updateStats"), object: nil)

        configure_avaImageView()
        loadUser()
        
    }
    
    // loads all user related information to be shown in the header
   @objc func loadUser() {
       
   
    guard let firstName = currentUser?["firstName"], let lastName = currentUser?["lastName"], let avaPath = currentUser?["ava"], let coverPath = currentUser?["cover"] else {
           
           return
       }
       // check in the front end is there any picture in the ImageView laoded from the server (is there a real html path / link to the image)
       if (avaPath as! String).count > 10 {
           isAva = true
       } else {
           avaImageView.image = UIImage(named: "user.png")
           isAva = false
       }
       
       if (coverPath as! String).count > 10 {
           isCover = true
       } else {
           coverImageView.image = UIImage(named: "HomeCover.jpg")
           isCover = false
       }
       // assigning vars which we accessed from global var, to fullnameLabel
       fullnameLabel.text = "\((firstName as! String).capitalized) \((lastName as! String).capitalized)"
       
       // downloading the images and assigning to certain imageViews
       Helper().downloadImage(from: avaPath as! String, showIn: self.avaImageView, orShow: "user.png")
       Helper().downloadImage(from: coverPath as! String, showIn: self.coverImageView, orShow: "HomeCover.jpg")
       // if bio is empty in the server -> hide bio label, otherwise, show bio label
       
       // save in the background thread the user's profile picture
       DispatchQueue.main.async {
           currentUser_ava = self.avaImageView.image
       }
   }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
