//
//  ViewControllerConnect.swift
//  final_project
//
//  Created by Caleb Willingham on 3/12/25.
//

import UIKit

class ViewControllerConnect: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView! // Connect this from Storyboard

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStackView()
    }

    func setupStackView() {
        // Dummy Labels
        let option1 = createLabel(text: "🔹 Connect to TV")

        // Add to Stack View
        stackView.addArrangedSubview(option1)
    }

    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .darkGray
        return label
    }
}
