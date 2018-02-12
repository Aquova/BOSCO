//
//  HighScoresViewController.swift
//  BOSCO
//
//  Created by Amelia Santrach on 12/3/17.
//  Copyright © 2017 labuser. All rights reserved.
//

import Foundation
import UIKit

class HighScoresViewController: UIViewController{
    
    let Default:UserDefaults = UserDefaults.standard
    var userDefaults = UserDefaults.standard
    
    @IBOutlet weak var HighLabel: UILabel!
    @IBOutlet weak var HighScore: UILabel!
    
    @IBOutlet weak var FirstScore: UILabel!
    @IBOutlet weak var SecondScore: UILabel!
    @IBOutlet weak var ThirdScore: UILabel!
    @IBOutlet weak var FourthScore: UILabel!
    @IBOutlet weak var FirstValue: UILabel!
    @IBOutlet weak var SecondValue: UILabel!
    @IBOutlet weak var ThirdValue: UILabel!
    @IBOutlet weak var FourthValue: UILabel!
    var fetchScores: [Scores] = []
    var names: [String] = []
    var points: [Int] = []
    
    func convertToNSData(arr:[Scores]) -> NSData {
        let aObject = NSKeyedArchiver.archivedData(withRootObject: arr as NSArray)
        return aObject as NSData
    }
    
    func sortArray(Strs:[String], ints: [Int]){
        var copy = ints
        var copyStrs:[String] = []
        copy = copy.sorted(by: >)
        for i in 0..<copy.count{
            for j in 0..<ints.count{
                if ints[j] == copy[i]{
                    copyStrs.append(Strs[j])
                }
                
            }
        }
        names = copyStrs
        points = copy
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
            points = decoded
        }else{
            for i in 0..<names.count{
                fetchScores.append(Scores(Name: names[i], Score: points[i], Rank: i))
            }
        }
        sortArray(Strs: names, ints: points)
        
        print("High score view")
        print(fetchScores)
       
        for i in 0..<names.count{
            if(i == 0){
                HighLabel.text = names[i]
                HighScore.text = String(points[i])
            }
            else if(i == 1){
                FirstScore.text = names[i]
                FirstValue.text = String(points[i])
            }
            else if(i == 2){
                SecondScore.text = names[i]
                SecondValue.text = String(points[i])
            }
            else if(i == 3){
                ThirdScore.text = names[i]
                ThirdValue.text = String(points[i])
            }
            else if(i == 4){
                FourthScore.text = names[i]
                FourthValue.text = String(points[i])
            }
        
        }
        let encodedNames : Data = NSKeyedArchiver.archivedData(withRootObject: names)
        Default.set(encodedNames, forKey: "Names")
        Default.synchronize()
        
        let encodedPoints : Data = NSKeyedArchiver.archivedData(withRootObject: points)
        Default.set(encodedPoints, forKey: "Points")
        Default.synchronize()
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("prep")
//        if segue.identifier == "playAgain"{
//            let vc = segue.destination as? ViewController
//            vc?.fetchScores = fetchScores
//        }
//    }
    
}
