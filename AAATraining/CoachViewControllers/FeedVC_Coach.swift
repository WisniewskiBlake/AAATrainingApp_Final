//
//  FeedVC_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/15/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import MediaPlayer
import ImagePicker
import Firebase
import FirebaseFirestore

class FeedVC_Coach: UITableViewController {
    
    // posts obj
    var posts: [NSDictionary] = []
    var recentListener: ListenerRegistration!
    
    var avas = [UIImage]()
    var pictures = [UIImage]()
    var skip = 0
    var limit = 25
    var isLoading = false
    var liked = [Int]()
    
    var lastNames : [String] = []
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        // dynamic cell height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadNewPosts), name: NSNotification.Name(rawValue: "uploadPost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadAvaAfterUpload), name: NSNotification.Name(rawValue: "uploadImage"), object: nil)
        // add observers for notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPostsAfterDelete), name: NSNotification.Name(rawValue: "deletePost"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "deleteUser"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(deletePost), name: NSNotification.Name(rawValue: "deletePost"), object: nil)
        
        
        // run function
        loadPosts()
        

    }
    
    
    
   
    
    func configureNavBar() {
        let imageView = UIImageView(image: UIImage(named: "aaaLogo.png"))        
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
    }
    

    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
        navigationController?.setNavigationBarHidden(true, animated: true)

    }
    
    
    // MARK: - Load Posts
    
    @objc func loadPosts() {
        
    }
    
    // MARK: - Load New
    // exec-d when new post is published
        @objc func loadNewPosts() {
            
            // skipping 0 posts, as we want to load the entire feed. And we are extending Limit value based on the previous loaded posts.
            loadPosts()
   
        }
    // MARK: - Load Delete
    @objc func loadPostsAfterDelete() {
            
            // skipping 0 posts, as we want to load the entire feed. And we are extending Limit value based on the previous loaded posts.
            loadPosts()
    
        }
    
    // MARK: - Load Ava
    @objc func loadAvaAfterUpload() {
            
            // skipping 0 posts, as we want to load the entire feed. And we are extending Limit value based on the previous loaded posts.
            loadPosts()
    
        }
    
    // MARK: - Load More
    // loading more posts from the server via PHP protocol
    @objc func loadMore() {
        
    }
    

    
    
    // MARK: - Table view data source

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoachNoPicCell", for: indexPath) as! CoachNoPicCell
        
        return cell
    }
    

    
    // MARK: - Scroll Did Scroll
    // executed always whenever tableView is scrolling
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // load more posts when the scroll is about to reach the bottom AND currently is not loading (posts)
        let a = tableView.contentOffset.y - tableView.contentSize.height + 60
        let b = -tableView.frame.height
        
        if a > b && isLoading == false {
            loadMore()

        }
        
    }

    
    

}
