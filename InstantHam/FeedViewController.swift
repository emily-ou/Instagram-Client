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
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate, UIWindowSceneDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    var numOfPosts: Int = 5
    let refresh_Control = UIRefreshControl()
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var selectedPost: PFObject!
    
    // Logout button is triggered
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        delegate.window?.rootViewController = loginViewController
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        // if last cell - initiate comment bar
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        
        return comments.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
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
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as? PFUser
            cell.usernameLabel.text = user?.username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
    }
    
    // Load posts
    @objc func loadPosts() {
        // Query posts
        let query = PFQuery(className: "Posts")
        // order by newest first
        query.order(byDescending: "createdAt")
        query.includeKeys(["author", "comments", "comments.author"])
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
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let comment = PFObject(className: "Comments")
        
        commentBar.inputTextView.textColor = UIColor.gray
        // Create a comment
        // Set the fields
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        print(PFUser.current()!)
        
        selectedPost.add(comment, forKey: "comments")
        
        selectedPost.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Comment failed to save")
            }
        }
        
        tableView.reloadData()
            
        // Clear the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        // Get post
        loadPosts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Dismiss comment keyboard
        tableView.keyboardDismissMode = .interactive
        
        // Dismiss text input bar for comments
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
