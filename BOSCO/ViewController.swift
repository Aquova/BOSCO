//
//  ViewController.swift
//  BOSCO
//
//  Created by labuser on 11/15/17.
//  Copyright © 2017 labuser. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
   
    let Default:UserDefaults = UserDefaults.standard
    var fetchScores: [Scores]!
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    static let bulletCollision: Int  = 1
    static let shipCollision: Int = 2
    
    let sidePoints = 10
    let centerPoint = 50
    let shootPoint = -2
    var totalPoints = 0
    
    
    var radar : SKShapeNode!
    let padding : CGFloat = 10
    var bullets: [Bullet] = []
    
    var halves = [SCNNode: Bool]()
    
    var spaceships: [SCNNode] = []
    var halvesnodes = [SCNNode: [SCNNode]]()
    var shipnodes = [SCNNode: [SCNNode]]()
    
    var names:[String] = []
    var points:[Int] = []
   
    
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
        
        
        super.viewDidLoad()
        print(fetchScores)
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.scene = SCNScene()
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.overlaySKScene = SKScene(size: sceneView.bounds.size)
        sceneView.overlaySKScene?.scaleMode = .resizeFill

        self.addShips()
        setupRadar()
        updateRadar()
    }

    @IBOutlet var TapGest: UITapGestureRecognizer!
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        totalPoints += shootPoint
//        self.playSoundEffect(ofType: .torpedo)
//        print("did tap 1")
        let bulletsNode = Bullet()
//        print("did tap 2")
        let frame = self.sceneView.session.currentFrame
        let matrix4 = SCNMatrix4(frame!.camera.transform)
        let direction = SCNVector3(-1 * matrix4.m31, -1 * matrix4.m32, -1 * matrix4.m33)
        let position = SCNVector3(matrix4.m41, matrix4.m42, matrix4.m43)
        bulletsNode.position = position
        bulletsNode.physicsBody?.applyForce(direction, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(bulletsNode)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addShips() {
        let scene = SCNScene(named: "art.scnassets/StationLayout.scn")
        let nodeArray = scene!.rootNode.childNodes
        var count = 1
        for node in nodeArray{
            if(node.name == "camera"){
                //skip
            }else{
                var arr: [SCNNode] = []
                node.name = String(count)
                node.geometry = SCNSphere(radius: 0.1)
                node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
                node.physicsBody?.isAffectedByGravity = false
                node.physicsBody?.contactTestBitMask = ViewController.bulletCollision
                node.physicsBody?.categoryBitMask = ViewController.shipCollision
                node.physicsBody?.collisionBitMask = 0
                sceneView.scene.rootNode.addChildNode(node)
                spaceships.append(node)
                halves[node] = false
                for i in (0..<6){
                    
                    let subnode = SCNNode()
                    subnode.name = String(count)+"-"+String(i)
                    subnode.geometry = SCNSphere(radius: 0.05)
                    subnode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
                    subnode.physicsBody?.isAffectedByGravity = false
                    subnode.physicsBody?.contactTestBitMask = ViewController.bulletCollision
                    subnode.physicsBody?.categoryBitMask = ViewController.shipCollision
                    subnode.physicsBody?.collisionBitMask = 0
                    
                    if i == 0{
                        subnode.position = SCNVector3(node.position.x - 0.15, 0, node.position.z+0.26)
                    }else if i == 1{
                        subnode.position = SCNVector3(node.position.x + 0.3, 0, node.position.z)
                    }else if  i == 2{
                        subnode.position = SCNVector3(node.position.x + 0.15, 0, node.position.z+0.26)
                    }else if  i == 3{
                        subnode.position = SCNVector3(node.position.x + 0.15, 0, node.position.z-0.26)
                    }else if  i == 4{
                        subnode.position = SCNVector3(node.position.x - 0.3, 0, node.position.z)
                    }else if  i == 5{
                        subnode.position = SCNVector3(node.position.x - 0.15, 0, node.position.z-0.26)
                    }
                    
                    sceneView.scene.rootNode.addChildNode(subnode)
                    arr.append(subnode)
                    
                }
                shipnodes[node] = arr
                arr.removeAll()
                //print(shipnodes)
                count += 1
            }
        }
        for i in 0..<spaceships.count{
            print(spaceships[i].name)
            print(spaceships[i])
        }
        print(spaceships)
       // print(shipnodes)
    }
    
    // Implementation of radar here: https://github.com/aivantg/ar-invaders
    
    func setupRadar() {
        print("setupRadar")
        let size = sceneView.bounds.size
        radar = SKShapeNode(circleOfRadius: size.width / 2)
        radar.position = CGPoint(x: size.width / 2, y: 0)
        radar.strokeColor = .black
        radar.glowWidth = 5
        radar.fillColor = .white
        radar.alpha = 0.5
        sceneView.overlaySKScene?.addChild(radar)
        
        for i in (1...3) {
            let ring = SKShapeNode(circleOfRadius: CGFloat(CGFloat(i) * size.width * 0.125))
            ring.strokeColor = .black
            ring.glowWidth = 0.2
            ring.name = "Ring"
            ring.position = radar.position
            sceneView.overlaySKScene?.addChild(ring)
        }
        
        // TODO: Problem here, spaceships contains both ships and the nodes, so there's too many blips
        for _ in (0..<spaceships.count) {
            let blip = SKShapeNode(circleOfRadius: 5)
            blip.fillColor = .red
            blip.alpha = 0
            radar.addChild(blip)
        }
    }
    
    func updateRadar() {
        print("Updating Radar")
        let size = sceneView.bounds.size
        for (i, blip) in radar.children.enumerated() {
            if i < spaceships.count {
                let ship = spaceships[i]
                print(i)
                print(ship.position)
                blip.alpha = 1
    
                let relativePosition = sceneView.pointOfView!.convertPosition(ship.position , from: nil)
                var x = relativePosition.x * Float(size.width) * 0.125
                var y = relativePosition.z * Float(size.width) * -0.125
                if x >= 0 {
                    x = min(y, 35)
                } else {
                    x = max(x, -35)
                }

                if y >= 0 {
                    x = min(x,35)
                } else {
                    y = max(y, -35)
                }
                blip.position = CGPoint(x: CGFloat(x), y: CGFloat(y))
            } else {
                blip.alpha = 0
            }
        }
    }
    func switchToHalf(node: SCNNode, hit: SCNNode, Ind: Int) {
        print("switch to half")
        let position = node.position
        node.removeFromParentNode()
        spaceships.remove(at: Ind)
        shipnodes[node]?[0].removeFromParentNode()
        shipnodes[node]?[1].removeFromParentNode()
        shipnodes[node]?[2].removeFromParentNode()
        shipnodes[node]?[3].removeFromParentNode()
        shipnodes[node]?[4].removeFromParentNode()
        shipnodes[node]?[5].removeFromParentNode()
        
        var arr:[SCNNode] = []
        
        let nodeName = (hit.name?.components(separatedBy: "-")[1])!
        let nodeNameFirst = node.name
        var scene :SCNScene!
        
        if(nodeName == "0" || nodeName == "1" || nodeName == "2"){
            scene = SCNScene(named: "art.scnassets/half456.scn")
            for i in (0..<3){
                
                let subnode = SCNNode()
                subnode.name = String(nodeNameFirst!)+"-"+String(i)
                subnode.geometry = SCNSphere(radius: 0.0025)
                subnode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
                subnode.physicsBody?.isAffectedByGravity = false
                subnode.physicsBody?.contactTestBitMask = ViewController.bulletCollision
                subnode.physicsBody?.categoryBitMask = ViewController.shipCollision
                subnode.physicsBody?.collisionBitMask = 0
                if(i == 1){
                    subnode.position = SCNVector3(node.position.x + 0.15, 0, node.position.z-0.26)
                }else if(i == 2){
                    subnode.position = SCNVector3(node.position.x - 0.3, 0, node.position.z)
                }else if(i == 0){
                    subnode.position = SCNVector3(node.position.x - 0.15, 0, node.position.z-0.26)
                }
                sceneView.scene.rootNode.addChildNode(subnode)
                arr.append(subnode)
            }
            halvesnodes[node] = arr
            arr.removeAll()
            
        }else{
            scene = SCNScene(named: "art.scnassets/half123.scn")
            for i in (0..<3){
                
                let subnode = SCNNode()
                subnode.name = (nodeName)+"-"+String(i)
                subnode.geometry = SCNSphere(radius: 0.0025)
                subnode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
                subnode.physicsBody?.isAffectedByGravity = false
                subnode.physicsBody?.contactTestBitMask = ViewController.bulletCollision
                subnode.physicsBody?.categoryBitMask = ViewController.shipCollision
                subnode.physicsBody?.collisionBitMask = 0
                if(i == 0){
                    subnode.position = SCNVector3(node.position.x - 0.15, 0, node.position.z+0.26)
                }else if(i == 1){
                    subnode.position = SCNVector3(node.position.x + 0.15, 0, node.position.z+0.26)
                }else if (i == 2){
                    subnode.position = SCNVector3(node.position.x + 0.3, 0, node.position.z)
                }
                sceneView.scene.rootNode.addChildNode(subnode)
                arr.append(subnode)
            }
            halvesnodes[node] = arr
            arr.removeAll()
        }
        
        let nodeArray = scene!.rootNode.childNodes
        var count = node.name
        for node in nodeArray{
            if(node.name == "camera"){
                //skip
            }else{
                node.name = count
                node.geometry = SCNSphere(radius: 0.4)
                node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
                node.physicsBody?.isAffectedByGravity = false
                node.physicsBody?.contactTestBitMask = ViewController.bulletCollision
                node.physicsBody?.categoryBitMask = ViewController.shipCollision
                node.physicsBody?.collisionBitMask = 0
                node.position = position
                sceneView.scene.rootNode.addChildNode(node)
                spaceships.append(node)
                halves[node] = true
            }
        }
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        //updateRadar()
        
        var isShip: Bool = false
        
        if contact.nodeA.physicsBody?.categoryBitMask == ViewController.shipCollision
            || contact.nodeB.physicsBody?.categoryBitMask == ViewController.shipCollision {
            contact.nodeA.removeFromParentNode()
            contact.nodeB.removeFromParentNode()
            let p = contact.nodeA.position
            for ship in spaceships{
                if(p.x == ship.position.x && p.y == ship.position.y && p.z == ship.position.z){
                    let ind = spaceships.index(of: ship)
                    spaceships.remove(at: ind!)
                    if(shipnodes[ship] != nil){
                        for subnode in shipnodes[ship]! {
                            subnode.removeFromParentNode()
                        }
                    }
                    shipnodes[ship]?.removeAll()
                    isShip = true
                    totalPoints += centerPoint
                }
                if(spaceships.count > 0){
                    
                }else{
                    print("done")
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "highscore", sender: self)
                    }
                }
            }

            if !isShip {
                var s : SCNNode!
                let ind = contact.nodeA.name
                let parsedStation = (ind?.components(separatedBy: "-")[0])!
                for i in 0..<spaceships.count{
                    let foo = spaceships[i]
                    if(parsedStation == foo.name!){
                        s = spaceships[i]
                    }
                }
                if halves[s] == true {
                    print("true")
                    print(contact.nodeA)
                   
                    let index = spaceships.index(of: s)
                    spaceships.remove(at: index!)
                    print(halvesnodes)
                    if(halvesnodes[s] != nil){
                        for i in 0..<halvesnodes[s]!.count {
                            //subnode.removeFromParentNode()
                            halvesnodes[s]![i].removeFromParentNode()
                            print(halvesnodes[s]![i])
                        }
                    }
                    halvesnodes[s]?.removeAll()
                    shipnodes[s]?.removeAll()
                    s.removeFromParentNode()
                }else{
                    print(contact.nodeA)
                    let index = spaceships.index(of: s)
                    switchToHalf(node: spaceships[index!], hit: contact.nodeA, Ind: index!)

                }
                totalPoints += centerPoint
            }
            
            
            updateRadar()
            //end game
            if(spaceships.count > 0){
                
            }else{
                print("done")
                let encodedData : Data = NSKeyedArchiver.archivedData(withRootObject: totalPoints)
                Default.set(encodedData, forKey: "userPoints")
                Default.synchronize()
                
                let encodedNames : Data = NSKeyedArchiver.archivedData(withRootObject: names)
                Default.set(encodedNames, forKey: "Names")
                Default.synchronize()
                
                let encodedPoints : Data = NSKeyedArchiver.archivedData(withRootObject: points)
                Default.set(encodedPoints, forKey: "Points")
                Default.synchronize()
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "highscore", sender: self)
                }
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("prep")
//        if segue.identifier == "highScore"{
//            let vc = segue.destination as? ScoreViewController
//            vc?.fetchScores = fetchScores
//        }
//    }
}

