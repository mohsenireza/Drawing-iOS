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
    var linePointsRadius : CGFloat = 5
    var touchStartPoint : CGPoint?
    var touchCurrentPoint : CGPoint?
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
        var lineSegment : LineSegment?
        var lineSegmentShape : CAShapeLayer?
        var startPoint : Circle?
        var startPointShape : CAShapeLayer?
        var endPoint : Circle?
        var endPointShape : CAShapeLayer?
        var coordinate : (start:(x:CGFloat, y:CGFloat), end:(x:CGFloat, y:CGFloat))?
        var isSticky : Bool?
        
        init() {
            self.lineSegmentShape = CAShapeLayer()
            self.startPointShape = CAShapeLayer()
            self.endPointShape = CAShapeLayer()
            self.lineSegment = LineSegment(a: .zero, b: .zero)
        }
        
        func setLineSegment(lineSegment : LineSegment){
            self.lineSegment = lineSegment
            self.lineSegmentShape?.path = lineSegment.path
        }
        
        func setStartPoint(startPoint : Circle){
            self.startPoint = startPoint
            self.startPointShape?.path = startPoint.path
        }
        
        func setEndPoint(endPoint : Circle){
            self.endPoint = endPoint
            self.endPointShape?.path = endPoint.path
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStatus = .drawLine
        let touch = touches.first
        touchStartPoint = touch!.location(in: self.view)
        let (_,_) = snapToNearestPoint(currentPoint: touchStartPoint!, &touchStartPoint!)
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
                if line.startPoint!.path!.contains(touchStartPoint!){
                    touchStatus = .dragLineStartPoint
                    selectedLineForDrag = line
                    break
                }
                else if line.endPoint!.path!.contains(touchStartPoint!){
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
    
    func snapToNearestPoint(currentLine : MyLine, currentPoint : CGPoint,_ pointToUpdate: inout CGPoint) -> (CGPoint? , Float?){
        var nearestPointDistance : Float
        var nearestPoint : CGPoint
        var points : [CGPoint] = Array()
        let linesExceptCurrentLine = lines?.filter({ (line) -> Bool in
            return line !== currentLine
        })
        if linesExceptCurrentLine == nil || linesExceptCurrentLine?.count == 0{
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
    
    func snapToNearestPoint(currentPoint : CGPoint,_ pointToUpdate: inout CGPoint) -> (CGPoint? , Float?){
        var nearestPointDistance : Float
        var nearestPoint : CGPoint
        var points : [CGPoint] = Array()
        if lines == nil || lines?.count == 0 {
            return (nil,nil)
        }
        for line in lines!{
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
        let deltaX = touchCurrentPoint!.x - touchStartPoint!.x
        let deltaY = touchCurrentPoint!.y - touchStartPoint!.y
        newStartPoint = CGPoint(x:(selectedLineForDrag!.coordinate?.start.x)! + deltaX , y:(selectedLineForDrag!.coordinate?.start.y)! + deltaY)
        newEndPoint = CGPoint(x:(selectedLineForDrag!.coordinate?.end.x)!, y:(selectedLineForDrag!.coordinate?.end.y)!)
        let (_,_) = snapToNearestPoint(currentLine: selectedLineForDrag!, currentPoint: touchCurrentPoint!, &newStartPoint!)
        let lineSegment = LineSegment(a: newStartPoint!, b: newEndPoint!)
        selectedLineForDrag!.setLineSegment(lineSegment: lineSegment)
        let startPoint = Circle(center: CGPoint(x: newStartPoint!.x, y: newStartPoint!.y), radius: linePointsRadius)
        selectedLineForDrag!.setStartPoint(startPoint: startPoint)
    }
    
    func dragLineEndPoint(){
        let deltaX = touchCurrentPoint!.x - touchStartPoint!.x
        let deltaY = touchCurrentPoint!.y - touchStartPoint!.y
        newStartPoint = CGPoint(x:(selectedLineForDrag!.coordinate?.start.x)!, y:(selectedLineForDrag!.coordinate?.start.y)!)
        newEndPoint = CGPoint(x:(selectedLineForDrag!.coordinate?.end.x)! + deltaX , y:(selectedLineForDrag!.coordinate?.end.y)! + deltaY)
        let (_,_) = snapToNearestPoint(currentLine: selectedLineForDrag!, currentPoint: touchCurrentPoint!, &newEndPoint!)
        let lineSegment = LineSegment(a: newStartPoint!, b: newEndPoint!)
        selectedLineForDrag!.setLineSegment(lineSegment: lineSegment)
        let endPoint = Circle(center: CGPoint(x: newEndPoint!.x, y: newEndPoint!.y), radius: linePointsRadius)
        selectedLineForDrag!.setEndPoint(endPoint: endPoint)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        touchCurrentPoint = touch.location(in: self.view)
        
        if touchStatus == TouchStatus.dragLineStartPoint {
            dragLineStartPoint()
        }
        else if touchStatus == TouchStatus.dragLineEndPoint {
            dragLineEndPoint()
        }
        else if touchStatus == TouchStatus.drawLine {
            
            if(newLine == nil){
                newLine = MyLine()
                newLine?.lineSegmentShape?.strokeColor = UIColor.black.cgColor
                newLine?.lineSegmentShape?.lineWidth = 4
                newLine?.startPointShape?.strokeColor = UIColor.red.cgColor
                newLine?.startPointShape?.lineWidth = 0
                newLine?.endPointShape?.strokeColor = UIColor.red.cgColor
                newLine?.endPointShape?.lineWidth = 0
                if lines?.append(newLine!) == nil{
                    lines = [newLine!]
                }
                self.view.layer.addSublayer(newLine!.lineSegmentShape!)
                self.view.layer.addSublayer(newLine!.startPointShape!)
                self.view.layer.addSublayer(newLine!.endPointShape!)
            }
            let touch = touches.first
            touchCurrentPoint = touch!.location(in: self.view)
            let (_,_) = snapToNearestPoint(currentLine: newLine!, currentPoint: touchCurrentPoint!, &touchCurrentPoint!)
            let lineSegment = LineSegment(a: touchStartPoint!, b: touchCurrentPoint!)
            newLine?.setLineSegment(lineSegment: lineSegment)
            let startPoint = Circle(center: CGPoint(x: touchStartPoint!.x, y: touchStartPoint!.y), radius: linePointsRadius)
            newLine?.setStartPoint(startPoint: startPoint)
            let endPoint = Circle(center: CGPoint(x: touchCurrentPoint!.x, y: touchCurrentPoint!.y), radius: linePointsRadius)
            newLine?.setEndPoint(endPoint: endPoint)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if newLine != nil{
            newLine?.coordinate = (start:(x:touchStartPoint!.x , y:touchStartPoint!.y), end:(x:touchCurrentPoint!.x,y:touchCurrentPoint!.y))
            newLine = nil
        }
        else if selectedLineForDrag != nil{
            selectedLineForDrag?.coordinate = (start:(x:newStartPoint!.x , y:newStartPoint!.y), end:(x:newEndPoint!.x,y:newEndPoint!.y))
            selectedLineForDrag = nil
        }
    }
    
}
