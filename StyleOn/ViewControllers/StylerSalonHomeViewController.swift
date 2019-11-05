import UIKit
import Firebase
import FirebaseAuth
import Foundation

class StylerSalonHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
    // Instantiate table view to post content
    var tableView:UITableView!

    var posts = [Post]()
    
    // Loads current view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        
        let cellNib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "postCell")
        
        view.addSubview(tableView)
        
        var layoutGuide:UILayoutGuide
        
        if #available(iOS 11.0, *){
            layoutGuide = view.safeAreaLayoutGuide
        }
        
        layoutGuide = view.safeAreaLayoutGuide
        
        tableView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        observe()
        
        tableView.reloadData()

    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        cell.set(post: posts[indexPath.row])
        return cell
    }
    
    
    @IBAction func handleLogout(_ target: UIBarButtonItem) {
        try! Auth.auth().signOut()
        self.dismiss(animated: false, completion: nil)
    }


    func observe() {
        let postsRef = Database.database().reference(withPath: "post")
                
                postsRef.observe(.value, with: { snapshot in
                    
                    var tempPosts = [Post]()
//                    var counter = 0
                    
                    
                    for child in snapshot.children {
                        if let childSnapshot = child as? DataSnapshot,
                            let data = childSnapshot.value as? [String:Any],
                            let timestamp = data["timestamp"] as? Double,
                            let postTitle = data["title"] as? String,
                            let postDescription = data["description"] as? String
                        {
                        
                            let newDate = self.getDateFromTimeStamp(timestamp:timestamp)
                        
                            let post = Post(timestamp: newDate, postTitle: postTitle, postDescription: postDescription)

                            tempPosts.append(post)
                            
//                            for x in tempPosts{
//                                print(x.timestamp)
//                            }
                        }
                        
                        // Counter to keep track of which post goes first, can be replaced with timestamp in future
//                        counter += 1
                    }
                    
                    self.posts = tempPosts
                    self.tableView.reloadData()
                    
                })
    }


    func getDateFromTimeStamp(timestamp : Double) -> String {
        
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }

    
    
    
    
    
    
}
