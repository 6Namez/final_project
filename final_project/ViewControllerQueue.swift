//
//  ViewControllerQueue.swift
//  final_project
//
//  Created by Caleb Willingham on 3/12/25.
//

import UIKit

class ViewControllerQueue: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView! // Connect from Storyboard
    
    // The local queue that will display in this screen
    var queue: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // If you have a prototype cell in Storyboard with identifier "QueueCell",
        // you can comment out the line below:
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "QueueCell")
        
        // (Optional) Load previously saved queue
        loadQueue()
        
        // Listen for new videos being added from Media Library
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoAddedToQueue(_:)),
            name: NSNotification.Name("VideoAddedToQueue"),
            object: nil
        )
    }

    // MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queue.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QueueCell", for: indexPath)
        let videoURL = queue[indexPath.row]

        // Display the file name of the video
        cell.textLabel?.text = videoURL.lastPathComponent
        return cell
    }

    // MARK: - Handle Incoming Videos
    
    
    @objc func videoAddedToQueue(_ notification: Notification) {
        if let videoURL = notification.object as? URL {
            // Add the new video to our local queue
            queue.append(videoURL)
            
            // (Optional) Persist the updated queue
            saveQueue()
            
            // Refresh the table view
            tableView.reloadData()
            print("📌 Queue Updated: \(videoURL.lastPathComponent)")
        }
    }
    
    // MARK: - Persisting the Queue (Optional)
    
    /// Save the current queue to UserDefaults
    func saveQueue() {
        let urlStrings = queue.map { $0.absoluteString }
        UserDefaults.standard.set(urlStrings, forKey: "QueueURLs")
    }
    
    /// Load the queue from UserDefaults
    func loadQueue() {
        if let urlStrings = UserDefaults.standard.array(forKey: "QueueURLs") as? [String] {
            queue = urlStrings.compactMap { URL(string: $0) }
        }
    }
}
