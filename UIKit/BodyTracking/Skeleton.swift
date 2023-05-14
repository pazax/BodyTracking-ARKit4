//
//  Skeleton.swift
//  BodyTracking
//
//  Created by Artyom Mihailovich on 1/24/21.
//

import RealityKit
import ARKit

class BodySkeleton: Entity {
    
    var joints: [String: Entity] = [:]
    
    required init(for bodyAnchor: ARBodyAnchor) {
        super.init()
        
        for jointName in ARSkeletonDefinition.defaultBody3D.jointNames {
            let isLeftSide: Bool = jointName.contains("left")
            
            let jointRadius: Float = 0.05
            let jointColor: UIColor = .green
            
            let jointEntity = makeJoint(jointName: jointName, radius: jointRadius, color: jointColor, isLeftSide: isLeftSide)
            joints[jointName] = jointEntity
            
            if let entity = jointEntity {
                self.addChild(entity)
            }
        }
        self.updatePositionJoint(with: bodyAnchor)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    func makeJoint(jointName: String, radius: Float, color: UIColor, isLeftSide: Bool) -> Entity? {
        
        if jointName.contains("left_hand") || jointName.contains("right_hand") || jointName.contains("eye") || jointName.contains("nose") || jointName.contains("chin") || jointName.contains("jaw") || jointName.contains("neck") || jointName.contains("head") || jointName.contains("toes"){
            return nil // Return nil to hide the hand joints
        }
        
        var jointColor = color
        
        if isLeftSide {
            jointColor = .blue
        } else {
            jointColor = .red
        }
        
        var jointRadius = radius
        
        switch jointName {
        case "left_hand_joint":
            jointRadius = 0.02 // Custom radius for left_hand_joint
        case "right_hand_joint":
            jointRadius = 0.02 // Custom radius for right_hand_joint
        //case _ where jointName.hasPrefix("spine") || jointName.hasPrefix("right_hand"):
        //    jointRadius = 0.05
        //    jointColor = .yellow
        case "head_joint":
            jointRadius = 0.1 // Custom radius for head_joint
        default:
            // Use the provided radius for other joints
            break
        }
        
        let mesh = MeshResource.generateSphere(radius: jointRadius)
        let material = SimpleMaterial(color: jointColor, roughness: 0.8, isMetallic: true)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        return modelEntity
    }

    
    func updatePositionJoint(with bodyAnchor: ARBodyAnchor){
        let rootPosition = simd_make_float3(bodyAnchor.transform.columns.3)
        
        for jointName in ARSkeletonDefinition.defaultBody3D.jointNames {
            if let jointEntity = joints[jointName], let jointTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: jointName)) {
                let jointOffset = simd_make_float3(jointTransform.columns.3)
                
                jointEntity.position = rootPosition + jointOffset
                jointEntity.orientation = Transform(matrix: jointTransform).rotation
            }
        }
    }
}
