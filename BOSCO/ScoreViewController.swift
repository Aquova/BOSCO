//
//  ScoreViewController.swift
//  BOSCO
//
//  Created by Amelia Santrach on 12/3/17.
//  Copyright © 2017 labuser. All rights reserved.
//

import Foundation
import UIKit

class ScoreViewController: UIViewController{
    
    let Default:UserDefaults = UserDefaults.standard
    var userDefaults = UserDefaults.standard
    
    @IBOutlet weak var CurrScore: UILabel!
    @IBOutlet weak var NameEntry: UITextField!
    @IBOutlet weak var submit: UIButton!
    var rank = 0
    var resetScores: Bool = false
    var points: Int!
    var fetchScores: [Scores] = []
    
    var names: [String] = []
    var point: [Int] = []

    
    @IBAction func SubmitHighScore(_ sender: Any) {
        print(fetchScores)
        names.append(NameEntry.text!)
        point.append(points)
//        if fetchScores.count > 0{
//            for ind in (0..<fetchScores.count){
//                //for var score in fetchScores{
//                var score = fetchScores[ind]
//                if (Int(CurrScore.text!)! > score.Score){
//                    rank = score.Rank
//                    let curHighScore = Scores(Name: NameEntry.text!, Score: Int(CurrScore.text!)!, Rank: rank)
//                    fetchScores.append(curHighScore)
//                    resetScores = true
//                }
//                if(resetScores){
//                    score.Rank += 1
//                    if(score.Rank > 5 ){
//                        fetchScores.remove(at: ind)
//                    }
//                }
//            }
//        }else{
//            let curHighScore = Scores(Name: (NameEntry.text)!, Score: points, Rank: rank)
//            fetchScores.append(curHighScore)
//        }
        let encodedNames : Data = NSKeyedArchiver.archivedData(withRootObject: names)
        Default.set(encodedNames, forKey: "Names")
        Default.synchronize()
        
        let encodedPoints : Data = NSKeyedArchiver.archivedData(withRootObject: point)
        Default.set(encodedPoints, forKey: "Points")
        Default.synchronize()
        

        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "SubmitScore", sender: nil)
            
        }
        
    }
    
    override func viewDidLoad() {
        let decodedNames = Default.object(forKey: "Names")
        if(decodedNames != nil){
            let decoded = NSKeyedUnarchiver.unarchiveObject(with: decodedNames as! Data) as! [String]
            names = decoded
        }
        let decodedPoints = Default.object(forKey: "Points")
        if(decodedPoints != nil){
            let decoded = NSKeyedUnarchiver.unarchiveObject(with: decodedPoints as! Data) as! [Int]
            point = decoded
        }else{
            for i in 0..<names.count{
                fetchScores.append(Scores(Name: names[i], Score: point[i], Rank: i))
            }
        }
        super.viewDidLoad()
        let decodedData = Default.object(forKey: "userPoints")
        if(decodedData != nil){
            let decoded = NSKeyedUnarchiver.unarchiveObject(with: decodedData as! Data) as! Int
            points = decoded
        }
        CurrScore.text = String(points!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}
