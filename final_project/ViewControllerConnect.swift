//
//  ViewControllerConnect.swift
//  final_project
//
//  Created by Caleb Willingham on 3/12/25.
//
                                                

import UIKit
import AVKit
import AVFoundation
import MediaPlayer

class ViewControllerConnect: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStackView()
    }

    func setupStackView() {
        let option1 = createLabel(text: "🔹 Connect to TV")
        let airplayView = createAirPlayView()
        let playButton = createPlayButton()

        stackView.addArrangedSubview(option1)
        stackView.addArrangedSubview(airplayView)
        stackView.addArrangedSubview(playButton)
    }

    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        return label
    }

    func createAirPlayView() -> AVRoutePickerView {
        let routePickerView = AVRoutePickerView()
        return routePickerView
    }

    func createPlayButton() -> UIButton {
        let playButton = UIButton(type: .system)
        playButton.setTitle("▶️ Play Local Video", for: .normal)
        playButton.addTarget(self, action: #selector(playLocalVideoTapped), for: .touchUpInside)
        return playButton
    }

    @objc func playLocalVideoTapped() {
        print("▶️ Play Local Video button tapped!")

        guard let videoURL = getLocalVideoURL() else {
            print("❌ No valid video found in queue")
            return
        }

        print("🎬 Attempting to play: \(videoURL.path)")

        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player

        present(playerViewController, animated: true) {
            player.play()
            print("✅ Video should now be playing")
        }
    }


    func getLocalVideoURL() -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        if let fileNames = UserDefaults.standard.array(forKey: "QueueFileNames") as? [String],
           let firstFileName = fileNames.first {
            
            let videoURL = documentsDirectory.appendingPathComponent(firstFileName)

            if fileManager.fileExists(atPath: videoURL.path) {
                print("✅ Video file found at path: \(videoURL.path)")
                return videoURL
            } else {
                print("❌ Video file does NOT exist at path: \(videoURL.path)")
            }
        } else {
            print("⚠️ Queue is empty!")
        }
        
        return nil
    }



}
