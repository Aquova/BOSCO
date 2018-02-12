//
//  Spaceship.swift
//  BOSCO
//
//  Created by labuser on 11/15/17.
//  Copyright © 2017 labuser. All rights reserved.
//

import Foundation
import SceneKit

class SpaceshipNode {
    var positionInScene: SCNVector3!
    
    class func addShipMaterial() -> SCNGeometry {
        var shipGeometry = SCNGeometry()
        shipGeometry = SCNSphere(radius: 0.08)
        //shipGeometry = SCNCylinder(radius:  0.10, height:  0.02)
        let edge = SCNMaterial()
        edge.shininess = 50.0
        edge.diffuse.contents = UIColor(red:0.00, green:0.84, blue:0.84, alpha:1.0)
        edge.specular.contents = UIColor.gray

        let surface = SCNMaterial()
        surface.shininess = 50.0
        surface.specular.contents = UIColor.gray
        shipGeometry.materials = [edge, surface, surface]
        return shipGeometry
    }
    
    class func Spaceship(_ ship: SCNGeometry, _ categoryBitMask: Int) -> SCNNode {
        let node = SCNNode()
        let shipNode = SCNNode(geometry: ship)
        shipNode.eulerAngles = SCNVector3(0, 0, CGFloat(0.5 * .pi))
        
        shipNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        shipNode.physicsBody?.isAffectedByGravity = false
        
        shipNode.physicsBody!.categoryBitMask = categoryBitMask
        shipNode.physicsBody!.collisionBitMask = 0
        shipNode.physicsBody!.contactTestBitMask = ViewController.bulletCollision
        node.addChildNode(shipNode)
        return node
    }
    
    class func ship() -> SCNNode {
        let shipGeometry = addShipMaterial()
        //let shipScene = SCNScene(named: "art.scnassets/ship.scn")!
        //let shipTopLevelNode = shipScene.rootNode.childNodes[0]
        //var shipNode = SCNNode()
        //return shipScene!
        return self.Spaceship(shipGeometry, ViewController.shipCollision)
        
    }
}
