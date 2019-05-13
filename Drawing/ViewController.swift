//
//  ViewController.swift
//  Drawing
//
//  Created by Reza Mohseni on 5/13/19.
//  Copyright © 2019 rezamohseni. All rights reserved.
//

import UIKit
import Metron

class ViewController: UIViewController {
    var startPoint : CGPoint?
    var endPoint : CGPoint?
    var newStartPoint : CGPoint?
    var newEndPoint : CGPoint?
    var newLine : MyLine? = nil
    var lines : [MyLine]?
    var selectedLineForDrag : MyLine? = nil
    var touchStatus : TouchStatus?
    
    enum TouchStatus{
        case drawLine
        case dragLineStartPoint
        case dragLineEndPoint
    }
    
    class MyLine{
        var shape : CAShapeLayer?
        var startPoint : CAShapeLayer?
        var endPoint : CAShapeLayer?
        var coordinate : (start:(x:CGFloat, y:CGFloat), end:(x:CGFloat, y:CGFloat))?
        var isSticky : Bool?
        
        init() {
            self.shape = CAShapeLayer()
            self.startPoint = CAShapeLayer()
            self.endPoint = CAShapeLayer()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStatus = .drawLine
        let touch = touches.first
        startPoint = touch!.location(in: self.view)
        if let lines = lines{
            for line in lines.reversed(){
                
                //                let shapePath = line.shape?.path?.copy(strokingWithWidth: 10, lineCap: CGLineCap(rawValue: 0)!, lineJoin: CGLineJoin(rawValue: 0)!, miterLimit: 1)
                //                if shapePath!.contains(startPoint!){
                //                    //print("touched...")
                //                    //line.shape?.strokeColor = UIColor.red.cgColor
                //                    //selectedLineForDrag = line
                //                    if line.isDragable {
                //                        line.isDragable = false
                //                        let startPointPath = UIBezierPath(ovalIn: CGRect(center: CGPoint(x: line.coordinate!.start.x, y: line.coordinate!.start.y), edges: 0))
                //                        let endPointPath = UIBezierPath(ovalIn: CGRect(center: CGPoint(x: line.coordinate!.end.x, y: line.coordinate!.end.y), edges: 0))
                //                        line.startPoint?.path = startPointPath.cgPath
                //                        line.endPoint?.path = endPointPath.cgPath
                //                    } else{
                //                        line.isDragable = true
                //                        let startPointPath = UIBezierPath(ovalIn: CGRect(center: CGPoint(x: line.coordinate!.start.x, y: line.coordinate!.start.y), edges: 20))
                //                        let endPointPath = UIBezierPath(ovalIn: CGRect(center: CGPoint(x: line.coordinate!.end.x, y: line.coordinate!.end.y), edges: 20))
                //                        line.startPoint?.path = startPointPath.cgPath
                //                        line.endPoint?.path = endPointPath.cgPath
                //                    }
                //                    break
                //                }
                
                if line.startPoint!.path!.contains(startPoint!){
                    touchStatus = .dragLineStartPoint
                    selectedLineForDrag = line
                    break
                }
                else if line.endPoint!.path!.contains(startPoint!){
                    touchStatus = .dragLineEndPoint
                    selectedLineForDrag = line
                    break
                }
                
            }
        }
    }
    
    func twoPointsDistance(firstPoint : CGPoint, secondPoint : CGPoint) -> Float{
        let deltaX = secondPoint.x - firstPoint.x
        let deltaY = secondPoint.y - firstPoint.y
        return Float(sqrt(pow(deltaX, 2) + pow(deltaY, 2)))
    }
    
    func stickToNearestPoint(currentLine : MyLine, currentPoint : CGPoint,_ pointToUpdate: inout CGPoint) -> (CGPoint? , Float?){
        var nearestPointDistance : Float
        var nearestPoint : CGPoint
        var points : [CGPoint] = Array()
        let linesExceptCurrentLine = lines?.filter({ (line) -> Bool in
            return line !== currentLine
        })
        if linesExceptCurrentLine?.count == 0{
            return (nil,nil)
        }
        for line in linesExceptCurrentLine!{
            let startPoint = CGPoint(x:line.coordinate!.start.x, y:line.coordinate!.start.y )
            let endPoint = CGPoint(x:line.coordinate!.end.x, y:line.coordinate!.end.y )
            points.append(startPoint)
            points.append(endPoint)
        }
        nearestPoint = points[0]
        nearestPointDistance = twoPointsDistance(firstPoint: currentPoint, secondPoint: points[0])
        for i in 1..<points.count{
            let pointsDistance = twoPointsDistance(firstPoint: currentPoint, secondPoint: points[i])
            if pointsDistance < nearestPointDistance {
                nearestPoint = points[i]
                nearestPointDistance = pointsDistance
            }
        }
        if(nearestPointDistance <= 20){
            pointToUpdate = nearestPoint
        }
        return (nearestPoint, nearestPointDistance)
    }
    
    func dragLineStartPoint(){
        let deltaX = endPoint!.x - startPoint!.x
        let deltaY = endPoint!.y - startPoint!.y
        newStartPoint = CGPoint(x:(selectedLineForDrag!.coordinate?.start.x)! + deltaX , y:(selectedLineForDrag!.coordinate?.start.y)! + deltaY)
        newEndPoint = CGPoint(x:(selectedLineForDrag!.coordinate?.end.x)!, y:(selectedLineForDrag!.coordinate?.end.y)!)
        let (_,_) = stickToNearestPoint(currentLine: selectedLineForDrag!, currentPoint: endPoint!, &newStartPoint!)
        let shapePath = UIBezierPath()
        shapePath.move(to: newStartPoint!)
        shapePath.addLine(to: newEndPoint!)
        selectedLineForDrag!.shape?.path = shapePath.cgPath
        let startPointPath = UIBezierPath(ovalIn: CGRect(center: CGPoint(x: newStartPoint!.x, y: newStartPoint!.y), edges: 10))
        selectedLineForDrag!.startPoint?.path = startPointPath.cgPath
    }
    
    func dragLineEndPoint(){
        let deltaX = endPoint!.x - startPoint!.x
        let deltaY = endPoint!.y - startPoint!.y
        newStartPoint = CGPoint(x:(selectedLineForDrag!.coordinate?.start.x)!, y:(selectedLineForDrag!.coordinate?.start.y)!)
        newEndPoint = CGPoint(x:(selectedLineForDrag!.coordinate?.end.x)! + deltaX , y:(selectedLineForDrag!.coordinate?.end.y)! + deltaY)
        let (_,_) = stickToNearestPoint(currentLine: selectedLineForDrag!, currentPoint: endPoint!, &newEndPoint!)
        let shapePath = UIBezierPath()
        shapePath.move(to: newStartPoint!)
        shapePath.addLine(to: newEndPoint!)
        selectedLineForDrag!.shape?.path = shapePath.cgPath
        let endPointPath = UIBezierPath(ovalIn: CGRect(center: CGPoint(x: newEndPoint!.x, y: newEndPoint!.y), edges: 10))
        selectedLineForDrag!.endPoint?.path = endPointPath.cgPath
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        endPoint = touch.location(in: self.view)
        
        if touchStatus == TouchStatus.dragLineStartPoint {
            dragLineStartPoint()
        }
        else if touchStatus == TouchStatus.dragLineEndPoint {
            dragLineEndPoint()
        }
        else if touchStatus == TouchStatus.drawLine {
            
            if(newLine == nil){
                newLine = MyLine()
                newLine?.shape?.strokeColor = UIColor.black.cgColor
                newLine?.shape?.lineWidth = 4
                newLine?.startPoint?.strokeColor = UIColor.red.cgColor
                newLine?.startPoint?.lineWidth = 0
                newLine?.endPoint?.strokeColor = UIColor.red.cgColor
                newLine?.endPoint?.lineWidth = 0
                if lines?.append(newLine!) == nil{
                    lines = [newLine!]
                }
                self.view.layer.addSublayer(newLine!.shape!)
                self.view.layer.addSublayer(newLine!.startPoint!)
                self.view.layer.addSublayer(newLine!.endPoint!)
            }
            let touch = touches.first
            endPoint = touch!.location(in: self.view)
            let (_,_) = stickToNearestPoint(currentLine: newLine!, currentPoint: endPoint!, &endPoint!)
            let shapePath = UIBezierPath()
            shapePath.move(to: startPoint!)
            shapePath.addLine(to: endPoint!)
            newLine?.shape?.path = shapePath.cgPath
            newLine?.shape?.backgroundColor = UIColor.red.cgColor
            let startPointPath = UIBezierPath(ovalIn: CGRect(center: CGPoint(x: startPoint!.x, y: startPoint!.y), edges: 10))
            newLine?.startPoint?.path = startPointPath.cgPath
            newLine?.startPoint?.backgroundColor = UIColor.red.cgColor
            let endPointPath = UIBezierPath(ovalIn: CGRect(center: CGPoint(x: endPoint!.x, y: endPoint!.y), edges: 10))
            newLine?.endPoint?.path = endPointPath.cgPath
            newLine?.endPoint?.backgroundColor = UIColor.red.cgColor
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if newLine != nil{
            newLine?.coordinate = (start:(x:startPoint!.x , y:startPoint!.y), end:(x:endPoint!.x,y:endPoint!.y))
            newLine = nil
        }
        else if selectedLineForDrag != nil{
            selectedLineForDrag?.coordinate = (start:(x:newStartPoint!.x , y:newStartPoint!.y), end:(x:newEndPoint!.x,y:newEndPoint!.y))
            selectedLineForDrag = nil
        }
    }
    
}
