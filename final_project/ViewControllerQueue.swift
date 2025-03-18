//
//  ViewControllerQueue.swift
//  final_project
//
//  Created by Caleb Willingham on 3/12/25.
//

import UIKit

class ViewControllerQueue: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var queue: [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrintQueue()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "QueueCell")
        
        loadQueue()
        
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
        cell.textLabel?.text = videoURL.lastPathComponent
        return cell
    }

    // MARK: - Handle Incoming Videos
    @objc func videoAddedToQueue(_ notification: Notification) {
        if let videoURL = notification.object as? URL {
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let storedVideoURL = documentsDirectory.appendingPathComponent(videoURL.lastPathComponent)

            if fileManager.fileExists(atPath: storedVideoURL.path) {
                queue.append(storedVideoURL) // Use stored video URL, not the original one
                saveQueue()
                tableView.reloadData()
                print("✅ Added to queue: \(storedVideoURL.path)")
            } else {
                print("❌ Attempted to queue a non-existing file: \(storedVideoURL.path)")
            }
        }
    }



    func debugPrintQueue() {
        if let queueURLs = UserDefaults.standard.array(forKey: "QueueURLs") as? [String] {
            print("📁 Current queue paths:")
            for url in queueURLs {
                print(url)
            }
        } else {
            print("⚠️ Queue is empty!")
        }
    }


    // MARK: - Persisting the Queue
    func saveQueue() {
        let fileNames = queue.map { $0.lastPathComponent } // Store only filenames
        UserDefaults.standard.set(fileNames, forKey: "QueueFileNames") // Ensure correct key is used
        print("✅ Queue saved with filenames: \(fileNames)")
    }

    func loadQueue() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        if let fileNames = UserDefaults.standard.array(forKey: "QueueFileNames") as? [String] {
            queue = fileNames.map { documentsDirectory.appendingPathComponent($0) }
            print("📁 Loaded queue: \(queue.map { $0.path })")
        } else {
            print("⚠️ No saved queue found.")
        }
    }


}
