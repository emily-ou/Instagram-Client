//
//  FeedViewController.swift
//  InstantHam
//
//  Created by Emily Ou on 2/17/20.
//  Copyright © 2020 Emily Ou. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    var numOfPosts: Int = 5
    let refresh_Control = UIRefreshControl()
    
    // Logout button is triggered
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        let post = posts[indexPath.row]
    
        // Fill in labels for post
        let user = post["author"] as! PFUser
        cell.topUsernameLabel.text = user.username
        cell.captionLabel.text = (post["caption"] as! String)
        
        // Get image URL
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        // Post image
        cell.photoView.af_setImage(withURL: url)
        
        return cell
    }
    
    // Load posts
    @objc func loadPosts() {
        // Query posts
        let query = PFQuery(className: "Posts")
        // order by newest first
        query.order(byDescending: "createdAt")
        query.includeKey("author")
        query.limit = numOfPosts
        
        self.posts.removeAll()
        // Post the posts
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
                self.refresh_Control.endRefreshing()
            }
        }
    }
    
    // Add two posts whenever retrieving old posts
    func getOldPosts() {
        numOfPosts += 2
        loadPosts()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == numOfPosts {
            print("Num of posts: \(numOfPosts)")
            getOldPosts()
            print("Num of posts: \(numOfPosts)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        // Query posts
        let query = PFQuery(className: "Posts")
        // order by newest first
        query.order(byDescending: "createdAt")
        query.includeKey("author")
        query.limit = numOfPosts
        
        self.posts.removeAll()
        // Post the posts
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // Disallow cell selection
        tableView.allowsSelection = false
        
        // Cell height
        tableView.estimatedRowHeight = 450
        tableView.rowHeight = UITableView.automaticDimension
        
        // Get and load posts
        loadPosts()
        
        // Refresh page
        refresh_Control.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.refreshControl = refresh_Control
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
