//
//  ViewControllerMediaLibrary.swift
//  final_project
//
//  Created by Caleb Willingham on 3/12/25.
//

import UIKit
import PhotosUI

class ViewControllerMediaLibrary: UIViewController, UITableViewDelegate, UITableViewDataSource, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView! // Connect from Storyboard
    
    var mediaLibrary: [URL] = [] // Array to store video file URLs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register a basic cell, but you can remove this if you have a prototype cell in Storyboard
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MediaCell")
        
        // Give enough height for the button to be visible
        tableView.rowHeight = 60
        
        loadMediaLibrary()
    }

    // MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaLibrary.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a basic cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaCell", for: indexPath)
        
        // Clear any old subviews from reuse
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let videoURL = mediaLibrary[indexPath.row]
        cell.textLabel?.text = videoURL.lastPathComponent
        
        // Create the "➕ Queue" button
        let addButton = UIButton(type: .system)
        addButton.setTitle("➕ Queue", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        addButton.setTitleColor(.systemBlue, for: .normal)
        addButton.backgroundColor = .systemGray5
        addButton.layer.cornerRadius = 5
        addButton.tag = indexPath.row
        addButton.addTarget(self, action: #selector(addToQueueTapped(_:)), for: .touchUpInside)
        
        // Use Auto Layout constraints for the button
        addButton.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            // Pin button to the left with a little padding
            addButton.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 8),
            // Vertically center in the cell
            addButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            // Set a fixed width & height
            addButton.widthAnchor.constraint(equalToConstant: 80),
            addButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Optionally indent the text label so it doesn't overlap the button
        // This helps avoid overlapping with the button on the left
        cell.indentationLevel = 2
        cell.indentationWidth = 50
        
        return cell
    }

    // MARK: - Load and Save Media Library
    
    func saveMediaLibrary() {
        let urls = mediaLibrary.map { $0.absoluteString }
        UserDefaults.standard.set(urls, forKey: "mediaLibrary")
    }
    
    func loadMediaLibrary() {
        if let savedURLs = UserDefaults.standard.array(forKey: "mediaLibrary") as? [String] {
            mediaLibrary = savedURLs.compactMap { URL(string: $0) }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Add Media Button Action
    
    @IBAction func addMediaTapped(_ sender: UIButton) {
        var config = PHPickerConfiguration()
        config.filter = .videos // Only allow video selection
        config.selectionLimit = 1 // Select only one video at a time
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // MARK: - Handle Video Selection
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider else {
            print("⚠️ No video selected.")
            return
        }
        
        if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                guard let url = url else {
                    print("❌ Failed to load video file: \(String(describing: error))")
                    return
                }
                self.saveVideoToAppStorage(originalURL: url)
            }
        } else {
            print("❌ Selected item is not a video.")
        }
    }

    // MARK: - Save Video to App Storage
    
    func saveVideoToAppStorage(originalURL: URL) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(originalURL.lastPathComponent)

        if fileManager.fileExists(atPath: destinationURL.path) {
            print("⚠️ Video already exists at: \(destinationURL.path)")
            return
        }

        do {
            try fileManager.copyItem(at: originalURL, to: destinationURL)
            DispatchQueue.main.async {
                self.mediaLibrary.append(destinationURL)
                self.saveMediaLibrary()
                self.tableView.reloadData()
                print("✅ Video successfully copied to: \(destinationURL.path)")

                // Now add the video to the queue
                NotificationCenter.default.post(
                    name: NSNotification.Name("VideoAddedToQueue"),
                    object: destinationURL
                )
            }
        } catch {
            print("❌ Error copying video: \(error)")
        }
    }




    // MARK: - Add Video to Queue
    
    @objc func addToQueueTapped(_ sender: UIButton) {
        let selectedVideo = mediaLibrary[sender.tag]
        
        // Notify Queue Screen via NotificationCenter
        NotificationCenter.default.post(
            name: NSNotification.Name("VideoAddedToQueue"),
            object: selectedVideo
        )
        
        print("✅ Added to queue: \(selectedVideo.lastPathComponent)")
    }
}

