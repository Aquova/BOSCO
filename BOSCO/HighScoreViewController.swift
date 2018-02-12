//
//  HighScoreViewController.swift
//  BOSCO
//
//  Created by Madeline on 11/19/17.
//  Copyright © 2017 labuser. All rights reserved.
//

import Foundation
import UIKit
import ARKit

//we want to still show the background behind the score board

class ViewController: UIViewController, ARSCNViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    //Get the top 5 scores from the HighScores class and Display them
    func getHighScores(sender: Any) {
        
    }
    
    
    //PlayGameButton starts the game again
    @IBAction func playGameButtonPressed(_sender: UIButton){
        //go back to playing game
    }

}
